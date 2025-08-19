import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rwanda_traffic_rules/screens/user_progress/user_progress_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';
import '../../ads/ad_manager.dart'; // Import ad manager
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/apis/db_connection.dart';
import '../../components/amabwiriza.dart';
import 'exams.dart';

class Results extends StatefulWidget {
  final int correct, incorrect, total;
  final Map<String, dynamic>? arguments;

  const Results({
    super.key,
    required this.correct,
    required this.incorrect,
    required this.total,
    this.arguments,
  });

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  String status = "";
  double percentage = 0.0;
  String? currentUserId;
  String? currentUsername;
  String? examType;
  String? quizId;
  String? examName;

  _checkFailed() {
    if (widget.correct < 16) {
      if (kDebugMode) {
        print("failed");
      }
      status = "Failed";
    } else {
      status = "Passed";
      if (kDebugMode) {
        print("passed");
      }
    }

    // Calculate percentage
    percentage = (widget.correct / widget.total) * 100;
  }

  @override
  void initState() {
    super.initState();
    _checkFailed();
    _getUserData();
    //_saveExamResult();
    // Ads are initialized in main.dart
  }

  Future<void> _getUserData() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = preferences.getString("uid");
      currentUsername = preferences.getString("name") ?? "User";
      _saveExamResult();
    });
  }

  Future<void> _saveExamResult() async {
    // print("🔍 DEBUG: currentUserId: $currentUserId");

    // print("🔍 DEBUG: quizId: ${widget.arguments?['quizId']}");
    // print("🔍 DEBUG: examType: $widget.arguments?['examType']");
    // print("🔍 DEBUG: examName: $widget.arguments?['examName']");

    if (currentUserId == null) return;

    try {
      // Get exam details from widget arguments
      final examType = widget.arguments?['examType'] ?? 'Kinyarwanda';
      final quizId = widget.arguments?['quizId'] ?? 'quiz_1';
      final examName = widget.arguments?['examName'] ?? 'Practice Exam';

      final response = await http.post(
        Uri.parse(API.saveExamResult),
        body: {
          'userId': currentUserId!,
          'quizId': quizId,
          'examType': examType,
          'examName': examName,
          'score': widget.correct.toString(),
          'totalQuestions': widget.total.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('Exam result saved successfully');
        } else {
          print('Failed to save exam result: ${data['message']}');
        }
      } else {
        print('Error saving exam result: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception saving exam result: $e');
    }
  }

  void showRewardedAd() {
    bool adShown = AdManager.showRewardedAd(context: 'exam_completion');

    if (!adShown) {
      print('Rewarded Ad is not loaded yet.');
    }
  }

  @override
  void dispose() {
    AdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Results',
        subtitle: 'Exam Score',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          IconButton(
            icon: const Icon(
              Icons.rule_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => AmabwirizaList(),
                ),
              );
            },
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 2, bottom: 2),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: status == "Passed"
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        status == "Passed"
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: status == "Passed" ? Colors.green : Colors.red,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Exam Completed!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "You have $status the exam",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
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
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_rounded,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Your Score",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Circular Progress Indicator
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              status == "Passed" ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "${widget.correct}/${widget.total}",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                            Text(
                              "${percentage.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Score Details
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreDetail(
                            "Correct",
                            widget.correct.toString(),
                            Colors.green,
                            Icons.check_circle_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildScoreDetail(
                            "Incorrect",
                            widget.incorrect.toString(),
                            Colors.red,
                            Icons.cancel_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Performance Analysis
              Container(
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
                          Icons.insights_rounded,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Performance Analysis",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisItem(
                      "Accuracy Rate",
                      "${percentage.toStringAsFixed(1)}%",
                      percentage >= 80
                          ? Colors.green
                          : percentage >= 60
                              ? Colors.orange
                              : Colors.red,
                    ),
                    _buildAnalysisItem(
                      "Passing Score",
                      "16/20 (80%)",
                      Colors.blue,
                    ),
                    _buildAnalysisItem(
                      "Your Result",
                      status,
                      status == "Passed" ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showRewardedAd();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Exams()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Take Another Exam",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showRewardedAd();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserProgressScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: BorderSide(color: kPrimaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "View Your Progress",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDetail(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
