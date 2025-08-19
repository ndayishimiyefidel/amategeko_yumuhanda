import 'package:rwanda_traffic_rules/ads/ad_manager.dart';
import 'package:rwanda_traffic_rules/screens/homepages/open_exam.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';
import '../../backend/apis/db_connection.dart';

class UserProgressScreen extends StatefulWidget {
  const UserProgressScreen({Key? key}) : super(key: key);

  @override
  State<UserProgressScreen> createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends State<UserProgressScreen> {
  List<ExamResult> examResults = [];
  bool isLoading = true;
  String? currentUserId;
  String? currentUsername;
  double overallAverage = 0.0;
  int totalExams = 0;
  int passedExams = 0;
  int failedExams = 0;
  Map<String, List<ExamResult>> examResultsByType = {};

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void showRewardedAd() {
    bool adShown = AdManager.showRewardedAd(context: 'exam_completion');

    if (!adShown) {
      print('Rewarded Ad is not loaded yet.');
    }
  }

  Future<void> _getUserData() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = preferences.getString("uid");
      currentUsername = preferences.getString("name") ?? "User";
    });
    _loadExamResults();
  }

  Future<void> _loadExamResults() async {
    if (currentUserId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      print('🔍 DEBUG: Loading exam results for user: $currentUserId');

      // Fetch exam results from database
      final response = await http.post(
        Uri.parse(API.getUserExamResults),
        body: {
          'userId': currentUserId!,
        },
      ).timeout(const Duration(seconds: 10));

      print('🔍 DEBUG: Response status: ${response.statusCode}');
      print('🔍 DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final results = data['results'] as List;

          setState(() {
            examResults =
                results.map((result) => ExamResult.fromJson(result)).toList();
            _calculateStatistics();
            _organizeResultsByType();
            isLoading = false;
          });

          print('🔍 DEBUG: Loaded ${examResults.length} exam results');
        } else {
          // No results found, show empty state
          setState(() {
            examResults = [];
            _calculateStatistics();
            isLoading = false;
          });
          print('🔍 DEBUG: No exam results found');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('🔍 DEBUG: Error loading exam results: $e');
      setState(() {
        isLoading = false;
      });

      // Show a more user-friendly error message
      String errorMessage = 'Unable to load progress data';
      if (e.toString().contains('FormatException')) {
        errorMessage = 'Server configuration issue. Please try again later.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _calculateStatistics() {
    if (examResults.isEmpty) return;

    // Get unique exams (by quiz_id) with best scores
    final Map<String, ExamResult> bestScores = {};

    for (final result in examResults) {
      final key = result.quizId.isNotEmpty
          ? result.quizId
          : result.id; // Use id as fallback
      if (!bestScores.containsKey(key) ||
          result.percentage > bestScores[key]!.percentage) {
        bestScores[key] = result;
      }
    }

    final bestResults = bestScores.values.toList();

    totalExams = bestResults.length;
    passedExams = bestResults.where((result) => result.passed).length;
    failedExams = totalExams - passedExams;

    if (bestResults.isNotEmpty) {
      double totalPercentage =
          bestResults.fold(0.0, (sum, result) => sum + result.percentage);
      overallAverage = totalPercentage / bestResults.length;
    }
  }

  void _organizeResultsByType() {
    examResultsByType.clear();

    for (final result in examResults) {
      if (!examResultsByType.containsKey(result.examType)) {
        examResultsByType[result.examType] = [];
      }
      examResultsByType[result.examType]!.add(result);
    }
  }

  List<ExamResult> getExamsNeedingImprovement() {
    // Get best scores for each exam
    final Map<String, ExamResult> bestScores = {};

    for (final result in examResults) {
      final key = result.quizId.isNotEmpty
          ? result.quizId
          : result.id; // Use id as fallback
      print('🔍 DEBUG: result.passed: ${result.passed}');
      if (!bestScores.containsKey(key) ||
          result.percentage > bestScores[key]!.percentage) {
        bestScores[key] = result;
      }
    }

    return bestScores.values
        .where((result) => result.percentage < 80.0)
        .toList();
  }

  List<ExamResult> getRecentExams() {
    // Get the most recent attempt for each exam
    final Map<String, ExamResult> latestAttempts = {};

    for (final result in examResults) {
      final key = result.quizId.isNotEmpty
          ? result.quizId
          : result.id; // Use id as fallback
      if (!latestAttempts.containsKey(key) ||
          result.createdAt.isAfter(latestAttempts[key]!.createdAt)) {
        latestAttempts[key] = result;
      }
    }

    final sortedResults = latestAttempts.values.toList();
    sortedResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedResults.take(5).toList();
  }

  double getAverageByType(String examType) {
    final typeResults = examResultsByType[examType] ?? [];
    if (typeResults.isEmpty) return 0.0;

    // Get best scores for this type
    final Map<String, ExamResult> bestScores = {};

    for (final result in typeResults) {
      final key = result.quizId.isNotEmpty
          ? result.quizId
          : result.id; // Use id as fallback
      if (!bestScores.containsKey(key) ||
          result.percentage > bestScores[key]!.percentage) {
        bestScores[key] = result;
      }
    }

    final bestResults = bestScores.values.toList();
    double totalPercentage =
        bestResults.fold(0.0, (sum, result) => sum + result.percentage);
    return totalPercentage / bestResults.length;
  }

  int getExamCountByType(String examType) {
    final typeResults = examResultsByType[examType] ?? [];

    // Count unique exams
    final Set<String> uniqueExams = {};
    for (final result in typeResults) {
      final key = result.quizId.isNotEmpty
          ? result.quizId
          : result.id; // Use id as fallback
      uniqueExams.add(key);
    }

    return uniqueExams.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Your Progress',
        subtitle: 'Exam Performance',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => OpenExamPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.quiz_outlined, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Exams',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPrimaryColor.withValues(alpha: 0.05),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : examResults.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Overall Statistics Card
                        _buildOverallStatsCard(),
                        const SizedBox(height: 16),

                        // Performance by Exam Type
                        _buildExamTypePerformance(),
                        const SizedBox(height: 16),

                        // Recent Exam Results
                        _buildRecentExamsCard(),
                        const SizedBox(height: 16),

                        // Areas for Improvement
                        _buildImprovementCard(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Exam Results Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              'Take your first exam to see your progress here!',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              showRewardedAd();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => OpenExamPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Take an Exam',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withValues(alpha: 0.1),
            kPrimaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: kPrimaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Overall Performance",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      "Based on $totalExams unique exams",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Average Score",
                  "${overallAverage.toStringAsFixed(1)}%",
                  overallAverage >= 80
                      ? Colors.green
                      : overallAverage >= 60
                          ? Colors.orange
                          : Colors.red,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  "Pass Rate",
                  totalExams > 0
                      ? "${((passedExams / totalExams) * 100).toStringAsFixed(1)}%"
                      : "0%",
                  totalExams > 0 && (passedExams / totalExams) >= 0.8
                      ? Colors.green
                      : Colors.orange,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExamTypePerformance() {
    final examTypes = ['Kinyarwanda', 'English', 'French'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language_rounded,
                color: kPrimaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Performance by Language",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: examTypes.map((type) {
              final average = getAverageByType(type);
              final count = getExamCountByType(type);
              final color = type == 'Kinyarwanda'
                  ? Colors.blue
                  : type == 'English'
                      ? Colors.green
                      : Colors.purple;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildLanguagePerformance(type, average, count, color),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePerformance(
      String language, double average, int examCount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            language,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${average.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$examCount exams",
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExamsCard() {
    final recentExams = getRecentExams();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: kPrimaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Recent Exam Results",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentExams.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No recent exam results available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentExams.map((result) => _buildExamResultItem(result)),
        ],
      ),
    );
  }

  Widget _buildExamResultItem(ExamResult result) {
    // Get attempt count for this exam
    final examKey = result.quizId.isNotEmpty ? result.quizId : result.id;
    final attempts = examResults
        .where((r) => (r.quizId.isNotEmpty ? r.quizId : r.id) == examKey)
        .length;

    final isBestScore = result.percentage ==
        examResults
            .where((r) => (r.quizId.isNotEmpty ? r.quizId : r.id) == examKey)
            .map((r) => r.percentage)
            .reduce((a, b) => a > b ? a : b);

    print('🔍 DEBUG: isBestScore: ${result.passed}');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.passed
            ? Colors.green.withValues(alpha: 0.05)
            : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.passed
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: result.passed
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              result.passed ? Icons.check_circle : Icons.cancel,
              color: result.passed ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: result.examType == "Kinyarwanda"
                        ? Colors.blue.withValues(alpha: 0.1)
                        : result.examType == "English"
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.examType,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: result.examType == "Kinyarwanda"
                          ? Colors.blue
                          : result.examType == "English"
                              ? Colors.green
                              : Colors.purple,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.examName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isBestScore)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "BEST SCORE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${result.score}/${result.totalQuestions} (${result.percentage.toStringAsFixed(1)}%)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _formatDate(result.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Attempt ${result.attemptNumber} of $attempts",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: result.passed ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.passed ? "PASS" : "FAIL",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementCard() {
    final improvementExams = getExamsNeedingImprovement();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Areas for Improvement",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (improvementExams.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Great job! You're performing well in all areas.",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...improvementExams.map((exam) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: exam.examType == "Kinyarwanda"
                              ? Colors.blue.withValues(alpha: 0.1)
                              : exam.examType == "English"
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${exam.examType}',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.normal,
                            color: exam.examType == "Kinyarwanda"
                                ? Colors.blue
                                : exam.examType == "English"
                                    ? Colors.green
                                    : Colors.purple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.warning_amber,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${exam.examName} - ${exam.percentage.toStringAsFixed(1)}%",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}

class ExamResult {
  final String id;
  final String userId;
  final String quizId;
  final String examType;
  final String examName;
  final int score;
  final int totalQuestions;
  final double percentage;
  final bool passed;
  final int attemptNumber;
  final int bestScore;
  final DateTime createdAt;

  ExamResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.examType,
    required this.examName,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    required this.attemptNumber,
    required this.bestScore,
    required this.createdAt,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      quizId: json['quiz_id']?.toString() ?? '',
      examType: json['exam_type']?.toString() ?? 'Kinyarwanda',
      examName: json['exam_name']?.toString() ?? 'Practice Exam',
      score: int.tryParse(json['score']?.toString() ?? '0') ?? 0,
      totalQuestions:
          int.tryParse(json['total_questions']?.toString() ?? '0') ?? 0,
      percentage:
          double.tryParse(json['percentage']?.toString() ?? '0.0') ?? 0.0,
      passed: json['passed'] == '1 ' || json['passed'] == true,
      attemptNumber:
          int.tryParse(json['attempt_number']?.toString() ?? '1') ?? 1,
      bestScore: int.tryParse(json['best_score']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
