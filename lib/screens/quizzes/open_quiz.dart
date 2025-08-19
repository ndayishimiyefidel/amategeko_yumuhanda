import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';
import '../../widgets/count_down.dart';
import '../../ads/ad_manager.dart'; // Import ad manager
import '../../enume/models/question_model.dart';
import 'result_screen.dart';
import '../../components/amabwiriza.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../widgets/disclaimer_widget.dart'; // Import disclaimer widget

class OpenQuiz extends StatefulWidget {
  final String quizId;
  final String title;
  // ignore: prefer_typing_uninitialized_variables
  final quizNumber;
  final String? quizType;
  final String? examType;
  final List<Map<String, dynamic>> questions;

  const OpenQuiz(
      {super.key,
      required this.quizId,
      required this.title,
      this.quizNumber,
      required this.questions,
      this.quizType,
      this.examType});

  @override
  State<OpenQuiz> createState() => _OpenQuizState();
}

int total = 0;
int _correct = 0;
int _incorrect = 0;
int _notAttempted = 0;
String op1 = "";
String op2 = "";
String op3 = "";
String op4 = "";
String qn = "";
String correctOp = "";
String questionImgUrl = "";
bool ans = false;

class _OpenQuizState extends State<OpenQuiz>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late SharedPreferences preferences;
  String? userRole;
  // Ad manager is now handled globally

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userRole = preferences.getString("role")!;
    });
  }

  bool isQuizVisible = true;
  ScreenshotCallback? screenshotCallback;
  late AnimationController _controller;
  final limitTime = 1200;
  int currentPageIndex = 0;

  QuestionModel getQuestionModelFromLocalData(
      Map<String, dynamic> questionData) {
    // Extract the necessary information from the questionData map
    String question = questionData['question'];
    String option1 = questionData['option1'];
    String option2 = questionData['option2'];
    String option3 = questionData['option3'];
    String option4 = questionData['option4'];
    String correctOption = questionData[
        'correctAnswer']; // Use 'correctAnswer' for the correct option
    // String questionImgUrl = questionData['questionImgUrl'];
    String questionImgUrl = questionData.containsKey('questionImgUrl')
        ? questionData['questionImgUrl']
        : '';
    bool answered = false; // You can set the initial value as needed

    // Create a new QuestionModel with the extracted data
    QuestionModel questionModel = QuestionModel(
      question,
      option1,
      option2,
      option3,
      option4,
      correctOption,
      answered,
      questionImgUrl,
      "",
    );

    return questionModel;
  }

  bool btnPressed = false;
  String btnText = "Next";
  String btnTextPrevious = "Previous";
  bool answered = false;
  late PageController _controller1;

//initial state
  @override
  void initState() {
    super.initState();
    _notAttempted = 0;
    _correct = 0;
    _incorrect = 0;
    _controller1 = PageController(initialPage: 0);
    //call current data
    getCurrUserData();
    //load ads
    // Ads are initialized in main.dart

    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: limitTime));
    _controller.addListener(() {
      if (_controller.isCompleted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Results(
                  correct: _correct,
                  incorrect: _incorrect,
                  total: widget.questions.length);
            },
          ),
        );
      }
    });
    _controller.forward();
    if (userRole != "Admin") {
      screenshotCallback = ScreenshotCallback();
      screenshotCallback!.addListener(handleScreenshot);
      // Disable screen recording with error handling
      try {
        ScreenProtector.preventScreenshotOn();
      } catch (e) {
        print('ScreenProtector error: $e');
      }
    }

    // Show exam disclaimer on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DisclaimerWidget.showExamDisclaimerDialog(context);
    });
  }

  void handleScreenshot() {
    if (!mounted) return;
    setState(() {
      isQuizVisible = false;
    });
  }

  void showRewardedAd() {
    bool adShown = AdManager.showRewardedAd(context: 'exam_completion');

    if (!adShown) {
      print('Rewarded Ad is not loaded yet.');
    }
  }

  @override
  void dispose() {
    if (_controller.isAnimating || _controller.isCompleted) {
      _controller.dispose();
    }
    if (userRole != "Admin") {
      screenshotCallback?.dispose();
    }
    _controller1.dispose();
    // Ads are disposed globally
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: ModernAppBar(
        title: widget.examType == 'English'
            ? 'Take the Test'
            : (widget.examType == 'French'
                ? 'Passer l\'examen'
                : 'Take the Test'),
        subtitle: 'Exam No: ${widget.quizNumber}',
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
          )
        ],
      ),
      body: userRole != "Admin"
          ? isQuizVisible
              ? buildQuizContent()
              : buildHiddenContent()
          : buildQuizContent(),
      //floating action button
      floatingActionButton: isQuizVisible ? buildFloatingActionButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 24, right: 24, top: 24),
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.05,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        onPressed: () {
          showRewardedAd();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Results(
                correct: _correct,
                incorrect: _incorrect,
                total: widget.questions.length,
              ),
            ),
          );
        },
        label: const Text(
          'Finish Exam',
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.check_circle_rounded, size: 18),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Modify the onPressed callback for the "Next" button.
  void onNextPressed() {
    if (currentPageIndex < (widget.questions.length) - 1) {
      // If there are more questions, move to the next question.
      currentPageIndex++;
      _controller1.animateToPage(
        currentPageIndex, // Use the updated index
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInExpo,
      );
      if (currentPageIndex == (widget.questions.length) - 1) {
        if (!mounted) return;
        showRewardedAd();
        setState(() {
          btnText = "Finish Exam";
        });
      }
      if (!mounted) return;
      setState(() {
        btnPressed = false;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Results(
            correct: _correct,
            incorrect: _incorrect,
            total: widget.questions.length,
            arguments: {
              'examType': widget.examType ?? 'Kinyarwanda',
              'quizId': widget.quizId,
              'examName': widget.title,
            },
          ),
        ),
      );
    }
  }

  // Modify the onPressed callback for the "Previous" button.
  void onPreviousPressed() {
    if (currentPageIndex > 0) {
      if (!mounted) return;
      setState(() {
        btnText = "Next";
      });
      // If there are previous questions, move to the previous question.
      currentPageIndex--; //
      _controller1.animateToPage(
        currentPageIndex, // Use the updated index
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInExpo,
      );
      if (!mounted) return;
      setState(() {
        btnPressed = false;
      });
    }
  }

  Widget buildHiddenContent() {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Security Alert',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Screenshots and screen recordings are not allowed during exams.',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuizContent() {
    return Container(
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
      child: Column(
        children: [
          // Header Section with Progress and Timer
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withValues(alpha: 0.1),
                  kPrimaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                // Progress Bar
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        (currentPageIndex + 1) / widget.questions.length,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Progress and Timer Info - compact single row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Q${currentPageIndex + 1}/${widget.questions.length}",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$_correct',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$_incorrect',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.timer_rounded,
                          color: kPrimaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Countdown(
                          animation: StepTween(begin: limitTime, end: 0)
                              .animate(_controller),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Question Content
          Expanded(
            child: PageView.builder(
              controller: _controller1,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 4, bottom: 0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        QuizPlayTile(
                          questionModel: getQuestionModelFromLocalData(
                              widget.questions[index]),
                          index: index,
                          quizId: widget.quizId,
                          quizTitle: widget.title,
                          userRole: userRole.toString(),
                          quizType: widget.quizType,
                          examType: widget.examType,
                        ),
                        const SizedBox(height: 8),

                        // Navigation Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (index > 0)
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                child: OutlinedButton(
                                  onPressed: onPreviousPressed,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kPrimaryColor,
                                    side: BorderSide(color: kPrimaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 0),
                                    minimumSize: Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "Previous",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        fontFamily: 'Poppins'),
                                  ),
                                ),
                              ),
                            if (index > 0) const SizedBox(width: 8),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: ElevatedButton(
                                onPressed: onNextPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 0),
                                  elevation: 2,
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  btnText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildScoreItem(String label, int count, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: color.withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: color.withValues(alpha: 0.3)),
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           count.toString(),
  //           style: TextStyle(
  //             color: color,
  //             fontWeight: FontWeight.bold,
  //             fontSize: 20,
  //           ),
  //         ),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             color: color,
  //             fontSize: 12,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  final String quizId;
  final String quizTitle;
  final String userRole;
  final String? quizType, examType;

  const QuizPlayTile(
      {super.key,
      required this.questionModel,
      required this.index,
      required this.quizId,
      required this.quizTitle,
      required this.userRole,
      this.quizType,
      this.examType});

  @override
  State<QuizPlayTile> createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";
  bool hasInternetConnection = true;
  bool isInCorrectOption = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Question Header

          // Free Quiz Notice
          if (widget.quizType == "Free" && widget.index == 0)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.examType == 'English'
                          ? 'NB: Choosing to press on the knee as in the provisional exam on the machine happens!'
                          : (widget.examType == 'French'
                              ? 'NB: Choisir d\'appuyer sur le genou comme dans l\'examen provisoire sur la machine se produit!'
                              : 'NB: Guhitamo ukanda mu kazu nkuko muri exam ya provisoire kuri machine biba bimeze!'),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          //if (widget.quizType == "Free" && widget.index == 0)

          // Question Text
          Text(
            widget.questionModel.question,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),

          // Question Image
          if (widget.questionModel.questionImgUrl.isNotEmpty)
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.questionModel.questionImgUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // if (widget.questionModel.questionImgUrl.isNotEmpty)
          const SizedBox(height: 2),

          // Options
          _buildOptionTile(
            widget.questionModel.option1,
            widget.questionModel.correctOption,
            optionSelected,
            () => _handleOptionSelection(widget.questionModel.option1),
            backgroundColor,
          ),

          const SizedBox(height: 4),

          _buildOptionTile(
            widget.questionModel.option2,
            widget.questionModel.correctOption,
            optionSelected,
            () => _handleOptionSelection(widget.questionModel.option2),
            backgroundColor,
          ),

          const SizedBox(height: 4),

          _buildOptionTile(
            widget.questionModel.option3,
            widget.questionModel.correctOption,
            optionSelected,
            () => _handleOptionSelection(widget.questionModel.option3),
            backgroundColor,
          ),

          const SizedBox(height: 4),

          _buildOptionTile(
            widget.questionModel.option4,
            widget.questionModel.correctOption,
            optionSelected,
            () => _handleOptionSelection(widget.questionModel.option4),
            backgroundColor,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    String option,
    String correctOption,
    String selectedOption,
    VoidCallback onPressed,
    Color backgroundColor,
  ) {
    final isSelected = optionSelected == option;
    final isCorrect = option == correctOption;
    final showResult = widget.questionModel.answered;

    Color tileColor = Colors.grey.withValues(alpha: 0.05);
    Color borderColor = Colors.grey.withValues(alpha: 0.3);
    Color textColor = Colors.black87;

    if (showResult) {
      if (isCorrect) {
        tileColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
        textColor = Colors.green.shade700;
      } else if (isSelected && !isCorrect) {
        tileColor = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
      }
    } else if (isSelected) {
      tileColor = kPrimaryColor.withValues(alpha: 0.1);
      borderColor = kPrimaryColor;
      textColor = kPrimaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: !widget.questionModel.answered ? onPressed : null,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: showResult
                    ? (isCorrect
                        ? Colors.green
                        : (isSelected && !isCorrect
                            ? Colors.red
                            : Colors.grey.withValues(alpha: 0.3)))
                    : (isSelected
                        ? kPrimaryColor
                        : Colors.grey.withValues(alpha: 0.3)),
                shape: BoxShape.rectangle,
              ),
              child: showResult
                  ? Icon(
                      isCorrect
                          ? Icons.check
                          : (isSelected && !isCorrect ? Icons.close : null),
                      color: Colors.white,
                      size: 14,
                    )
                  : (isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
                      : null),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              option,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: textColor,
                fontWeight: (isSelected || (showResult && isCorrect))
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleOptionSelection(String selectedOption) {
    if (!widget.questionModel.answered) {
      setState(() {
        optionSelected = selectedOption;

        if (selectedOption == widget.questionModel.correctOption) {
          widget.questionModel.answered = true;
          _correct = _correct + 1;
          _notAttempted = _notAttempted - 1;
        } else {
          widget.questionModel.answered = true;
          _incorrect = _incorrect + 1;
          _notAttempted = _notAttempted - 1;
          isInCorrectOption = true;
        }
      });
    }
  }
}
