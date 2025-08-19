import 'package:rwanda_traffic_rules/widgets/ModernAppBar.dart';
import '../quizzes/exams.dart';
import '../quizzes/examen_fr.dart';
import '../../utils/constants.dart';
import '../quizzes/exam_english.dart';
import 'package:flutter/material.dart';
import '../../ads/ad_manager.dart'; // Import ad manager
import '../../widgets/MainDrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/amabwiriza.dart';

class OpenExamPage extends StatefulWidget {
  const OpenExamPage({super.key});

  @override
  State createState() => _OpenExamPageState();
}

class _OpenExamPageState extends State<OpenExamPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //shared preferences
  late SharedPreferences preferences;
  String currentuserid = "";
  String currentusername = "User";
  String userRole = "";

  String phone = "";
  String? referralCode;
  // Ad manager is now handled globally

  void getCurrUserData() async {
    try {
      preferences = await SharedPreferences.getInstance();

      if (mounted) {
        setState(() {
          currentuserid = preferences.getString("uid") ?? "";
          currentusername = preferences.getString("name") ?? "User";
          userRole = preferences.getString("role") ?? "";
          phone = preferences.getString("phone") ?? "";
        });
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
    // Ads are initialized in main.dart
  }

  void showRewardedAd() {
    bool adShown = AdManager.showRewardedAd(context: 'exam_completion');

    if (!adShown) {
      print('Rewarded Ad is not loaded yet.');
    }
  }

  void _showInterstitialAd() {
    // Show the interstitial ad when needed
    AdManager.showInterstitialAd(context: 'exam_navigation');
  }

  @override
  void dispose() {
    super.dispose();
    // Ads are disposed globally
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
        elevation: 0,
        child: MainDrawer(),
      ),
      appBar: ModernAppBar(
        title: 'Exam Center',
        subtitle: 'Choose your preferred exam language',
        onMenuPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
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
          child: Column(
            children: [
              // Header Section
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(24),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [
              //         kPrimaryColor.withValues(alpha: 0.1),
              //         kPrimaryColor.withValues(alpha: 0.05),
              //       ],
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //     ),
              //     borderRadius: const BorderRadius.only(
              //       bottomLeft: Radius.circular(32),
              //       bottomRight: Radius.circular(32),
              //     ),
              //   ),
              //   child: Column(
              //     children: [
              //       Row(
              //         children: [
              //           Container(
              //             padding: const EdgeInsets.all(12),
              //             decoration: BoxDecoration(
              //               color: kPrimaryColor.withValues(alpha: 0.15),
              //               borderRadius: BorderRadius.circular(12),
              //             ),
              //             child: Icon(
              //               Icons.quiz_rounded,
              //               color: kPrimaryColor,
              //               size: 32,
              //             ),
              //           ),
              //           const SizedBox(width: 16),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   "Exam Center",
              //                   style: TextStyle(
              //                     color: kPrimaryColor,
              //                     fontWeight: FontWeight.bold,
              //                     fontSize: 24,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 4),
              //                 Text(
              //                   "Choose your preferred exam language",
              //                   style: TextStyle(
              //                     color: Colors.grey[600],
              //                     fontSize: 14,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),

              //       const SizedBox(height: 20),

              //       // Welcome Card
              //       Container(
              //         padding: const EdgeInsets.all(20),
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           borderRadius: BorderRadius.circular(16),
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.grey.withValues(alpha: 0.1),
              //               blurRadius: 10,
              //               offset: const Offset(0, 4),
              //             ),
              //           ],
              //         ),
              //         child: Row(
              //           children: [
              //             Container(
              //               padding: const EdgeInsets.all(8),
              //               decoration: BoxDecoration(
              //                 color: kPrimaryColor.withValues(alpha: 0.1),
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: Icon(
              //                 Icons.person_rounded,
              //                 color: kPrimaryColor,
              //                 size: 24,
              //               ),
              //             ),
              //             const SizedBox(width: 12),
              //             Expanded(
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     "Welcome, $currentusername!",
              //                     style: const TextStyle(
              //                       fontSize: 18,
              //                       fontWeight: FontWeight.bold,
              //                       color: Colors.black87,
              //                     ),
              //                   ),
              //                   const SizedBox(height: 4),
              //                   Text(
              //                     "Ready to test your knowledge?",
              //                     style: TextStyle(
              //                       fontSize: 14,
              //                       color: Colors.grey[600],
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // Exam Options
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Kinyarwanda Exam
                    _buildExamCard(
                      title: "Kinyarwanda Exam",
                      subtitle: "Take exam in Kinyarwanda",
                      icon: Icons.language_rounded,
                      color: kPrimaryColor,
                      onTap: () {
                        _showInterstitialAd();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Exams(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // English Exam
                    _buildExamCard(
                      title: "English Exam",
                      subtitle: "Take exam in English",
                      icon: Icons.translate_rounded,
                      color: Colors.blue,
                      onTap: () {
                        _showInterstitialAd();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExamEnglish(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // French Exam
                    _buildExamCard(
                      title: "French Exam",
                      subtitle: "Take exam in French",
                      icon: Icons.language_rounded,
                      color: Colors.purple,
                      onTap: () {
                        _showInterstitialAd();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExamFrench(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // Instructions Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: kPrimaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Exam Instructions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInstructionItem(
                            "1. Choose your preferred exam language",
                            "Select from Kinyarwanda, English, or French exams",
                            Icons.language_rounded,
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionItem(
                            "2. Read questions carefully",
                            "Take your time to understand each question before answering",
                            Icons.quiz_rounded,
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionItem(
                            "3. Submit your answers",
                            "Review your answers before submitting the exam",
                            Icons.check_circle_rounded,
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionItem(
                            "4. View your results",
                            "See your score and review correct answers",
                            Icons.analytics_rounded,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showRewardedAd();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AmabwirizaList(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.rule_rounded, size: 18),
                              label: Text(
                                "View Full Instructions",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: userRole == "Admin"
      //     ? FloatingActionButton.extended(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const CreateQuiz(),
      //             ),
      //           );
      //         },
      //         backgroundColor: kPrimaryColor,
      //         foregroundColor: Colors.white,
      //         icon: const Icon(Icons.add),
      //         label: const Text(
      //           "Create Quiz",
      //           style: TextStyle(fontWeight: FontWeight.bold),
      //         ),
      //       )
      //     : null,
    );
  }

  Widget _buildExamCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: kPrimaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
