import 'package:amategeko/enume/models/question_model.dart';
import 'package:amategeko/screens/quizzes/result_screen.dart';
import 'package:amategeko/widgets/play_quiz_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../widgets/count_down.dart';
import '../homepages/noficationtab1.dart';

class OpenQuiz extends StatefulWidget {
  final String quizId;
  final String title;
  // ignore: prefer_typing_uninitialized_variables
  final quizNumber;
  final String? quizType;
  final List<Map<String, dynamic>> questions;

  const OpenQuiz(
      {super.key,
      required this.quizId,
      required this.title,
      this.quizNumber,
      required this.questions,
      this.quizType});

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
    String questionImgUrl = questionData['questionImgUrl'];
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
      // Disable screen recording
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  void handleScreenshot() {
    if (!mounted) return;
    setState(() {
      isQuizVisible = false;
    });
  }

  @override
  void dispose() {
    if (_controller.isAnimating || _controller.isCompleted) {
      _controller.dispose();
    }
    if (userRole != "Admin") {
      screenshotCallback!.dispose();
    }
    _controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Gukora Ikizamini",
          style:
              TextStyle(letterSpacing: 1.25, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const NotificationTab1(),
                ),
              );
            },
          )
        ],
        centerTitle: true,
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
    return FloatingActionButton.extended(
      backgroundColor: kPrimaryLightColor,
      onPressed: () {
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
        'Soza Exam',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.normal,
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
        setState(() {
          btnText = "Soza Exam";
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
      color: Colors.black, // or any other color to cover the screen
      child: const Center(
        child: Text(
          'Screenshots and screen videos are not allowed.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget buildQuizContent() {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 30, top: 10),
              child: Text(
                "Exam No:${widget.quizNumber}",
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 20,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.questions.isEmpty
                    ? "TQ: No questionfor this exam!" // Display loading message
                    : "TQ:${widget.questions.length} question(s)",
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 18,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.punch_clock,
                size: 40,
                color: kPrimaryColor,
              ),
              Countdown(
                  animation:
                      StepTween(begin: limitTime, end: 0).animate(_controller)),
            ],
          ),
        ),
        PageView.builder(
          controller: _controller1,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.questions.length, // Use the local JSON data
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 80),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    QuizPlayTile(
                      questionModel: getQuestionModelFromLocalData(
                          widget.questions[index]),
                      index: index,
                      quizId: widget.quizId,
                      quizTitle: widget.title,
                      userRole: userRole.toString(),
                      quizType: widget.quizType,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RawMaterialButton(
                          onPressed: onPreviousPressed,
                          shape: const StadiumBorder(),
                          fillColor: Colors.blue,
                          padding: const EdgeInsets.all(14.0),
                          elevation: 0.0,
                          child: Text(
                            btnTextPrevious,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                        RawMaterialButton(
                          onPressed: onNextPressed,
                          shape: const StadiumBorder(),
                          fillColor: Colors.blue,
                          padding: const EdgeInsets.all(14.0),
                          elevation: 0.0,
                          child: Text(
                            btnText,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  final String quizId;
  final String quizTitle;
  final String userRole;
  final String? quizType;

  const QuizPlayTile(
      {super.key,
      required this.questionModel,
      required this.index,
      required this.quizId,
      required this.quizTitle,
      required this.userRole,
      this.quizType});

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
    Size size = MediaQuery.of(context).size;
    Color backgroundColor =
        Colors.white; // Initialize it with the default color
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (widget.quizType == "Free" && widget.index == 0)
              ? Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Text(
                    "NB:Guhitamo ukanda mu kavi nkuko muri exam ya provisoire kuri machine biba bimeze!",
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              : SizedBox(),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Q.${widget.questionModel.question}",
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
          Center(
            child: Stack(
              children: <Widget>[
                (widget.questionModel.questionImgUrl.isEmpty)
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Image.asset(
                            widget.questionModel.questionImgUrl,
                            fit: BoxFit.cover,
                          )),
                        ],
                      ),
              ],
            ),
          ),
          OptionTile(
            correctAnswer: widget.questionModel.correctOption,
            option: Icon(Icons.check),
            description: widget.questionModel.option1,
            optionSelected: optionSelected,
            onPressed: () {
              if (!widget.questionModel.answered) {
                // Check if the selected option is correct
                if (widget.questionModel.option1 ==
                    widget.questionModel.correctOption) {
                  optionSelected = widget.questionModel.option1;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                } else {
                  optionSelected = widget.questionModel.option1;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  if (!mounted) return;
                  setState(() {
                    isInCorrectOption = true;
                  });
                }
                if (!mounted) return;
                setState(() {
                  // Set the background color of the OptionTile
                  backgroundColor =
                      optionSelected == widget.questionModel.correctOption
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red.withOpacity(0.7);
                });
              }
            },
            backgroundColor: backgroundColor, // Pass the background color here
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          OptionTile(
            correctAnswer: widget.questionModel.correctOption,
            option: const Icon(
              (Icons.check),
            ),
            description: widget.questionModel.option2,
            optionSelected: optionSelected,
            onPressed: () {
              if (!widget.questionModel.answered) {
                //check correct
                if (widget.questionModel.option2 ==
                    widget.questionModel.correctOption) {
                  optionSelected = widget.questionModel.option2;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                } else {
                  optionSelected = widget.questionModel.option2;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  if (!mounted) return;
                  setState(() {
                    isInCorrectOption = true;
                  });
                }
                if (!mounted) return;
                setState(() {
                  // Set the background color of the OptionTile
                  backgroundColor =
                      optionSelected == widget.questionModel.correctOption
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red.withOpacity(0.7);
                });
              }
            },
            backgroundColor: backgroundColor,
          ),
          const SizedBox(
            height: 5,
          ),
          OptionTile(
            correctAnswer: widget.questionModel.correctOption,
            option: const Icon(
              (Icons.check),
            ),
            description: widget.questionModel.option3,
            optionSelected: optionSelected,
            onPressed: () {
              if (!widget.questionModel.answered) {
                //check correct
                if (widget.questionModel.option3 ==
                    widget.questionModel.correctOption) {
                  optionSelected = widget.questionModel.option3;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                } else {
                  optionSelected = widget.questionModel.option3;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  if (!mounted) return;
                  setState(() {
                    isInCorrectOption = true;
                  });
                }
                if (!mounted) return;
                setState(() {
                  // Set the background color of the OptionTile
                  backgroundColor =
                      optionSelected == widget.questionModel.correctOption
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red.withOpacity(0.7);
                });
              }
            },
            backgroundColor: backgroundColor,
          ),
          const SizedBox(
            height: 5,
          ),
          OptionTile(
            correctAnswer: widget.questionModel.correctOption,
            option: const Icon(
              (Icons.check),
            ),
            onPressed: () {
              if (!widget.questionModel.answered) {
                //check correct
                if (widget.questionModel.option4 ==
                    widget.questionModel.correctOption) {
                  optionSelected = widget.questionModel.option4;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                } else {
                  optionSelected = widget.questionModel.option4;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  if (!mounted) return;
                  setState(() {
                    isInCorrectOption = true;
                  });
                }
              if (!mounted) return;
              setState(() {
              backgroundColor =
                    optionSelected == widget.questionModel.correctOption
                        ? Colors.green.withOpacity(0.7)
                        : Colors.red.withOpacity(0.7);
                });
              }
            },
            description: widget.questionModel.option4,
            optionSelected: optionSelected,
            backgroundColor: backgroundColor,
          ),
          const SizedBox(
            height: 20,
          ),
          isInCorrectOption
              ? Text(
                  "Igisubizo cy'ukuri ni: ${widget.questionModel.correctOption}",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
