import 'dart:async';
import 'package:amategeko/utils/generate_code.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:amategeko/enume/models/question_model.dart';
import 'package:amategeko/screens/quizzes/result_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../backend/apis/db_connection.dart';
import '../../utils/constants.dart';
import '../../widgets/count_down.dart';
import '../../widgets/play_quiz_widget.dart';
import '../homepages/noficationtab1.dart';
import 'edit_quiz_question.dart';

class OpenModifiedQuiz extends StatefulWidget {
  final String courseId;
  // ignore: prefer_typing_uninitialized_variables
  final title;
  // ignore: prefer_typing_uninitialized_variables
  final quizNumber;

  const OpenModifiedQuiz(
      {super.key, required this.courseId, this.title, this.quizNumber});

  @override
  State<OpenModifiedQuiz> createState() => _OpenModifiedQuizState();
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
String id = "";

class _OpenModifiedQuizState extends State<OpenModifiedQuiz>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController _controller;
  final limitTime = 1200;
  int currentPageIndex = 0;
  List<Map<String, dynamic>> allQuestionList = [];

  Future<void> fetchAlCourseQuestion() async {
    final apiUrl = API.getCourseQuiz + "?courseId=${widget.courseId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Response data:$data");

        if (data['success'] == true) {
          if (!mounted) return;
          setState(() {
            allQuestionList.clear();
            allQuestionList
                .addAll(List<Map<String, dynamic>>.from(data['data']));
            print("allQuestionList: $allQuestionList");
          });
        } else {
          print("Failed to execute query");
        }
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print("Error occurs: $e");
    }
  }

  QuestionModel getQuestionModelFromList(int index) {
    QuestionModel questionModel = QuestionModel(
      qn,
      op1,
      op2,
      op3,
      op4,
      correctOp,
      ans,
      questionImgUrl,
      id,
    );

    questionModel.question = allQuestionList[index]['question'];
    questionModel.questionImgUrl = allQuestionList[index]['quizPhotoUrl'];
    questionModel.id = allQuestionList[index]['id'];

    List<String> options = [
      allQuestionList[index]["option1"],
      allQuestionList[index]["option2"],
      allQuestionList[index]["option3"],
      allQuestionList[index]["option4"],
    ];

    // Shuffle options if needed
    // options.shuffle();

    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];

    questionModel.correctOption = allQuestionList[index]["correctAnswer"];
    questionModel.answered = false;

    return questionModel;
  }

  bool btnPressed = false;
  late PageController _controller1;
  String btnText = "Next";
  String btnTextPrevious = "Previous";
  bool answered = false;

  @override
  void initState() {
    fetchAlCourseQuestion();
    _controller1 = PageController(initialPage: 0);
    _notAttempted = 0;
    _correct = 0;
    _incorrect = 0;
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: limitTime));
    _controller.addListener(() {
      if (_controller.isCompleted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Results(
                  correct: _correct, incorrect: _incorrect, total: total);
            },
          ),
        );
      }
    });
    _controller.forward();

    super.initState();
  }

  // onPressed callback for the "Next" button.
  void onNextPressed() {
    if (currentPageIndex < (allQuestionList.length) - 1) {
      currentPageIndex++;
      if (kDebugMode) {
        print("current page $currentPageIndex");
      }
      if (currentPageIndex == 4) {
        //show ads on question 10
        _controller1.animateToPage(
          currentPageIndex, // Use the updated index
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInExpo,
        );
      }
      _controller1.animateToPage(
        currentPageIndex, // Use the updated index
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInExpo,
      );
      if (currentPageIndex == (allQuestionList.length) - 1) {
        setState(() {
          btnText = "Soza Quiz";
        });
      }
      setState(() {
        btnPressed = false;
      });
    } else {
      // If there are no more questions, navigate to the Results screen

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Results(
            correct: _correct,
            incorrect: _incorrect,
            total: total,
          ),
        ),
      );
    }
  }

  // Modify the onPressed callback for the "Previous" button.
  void onPreviousPressed() {
    if (currentPageIndex > 0) {
      setState(() {
        btnText = "Next";
      });
      // If there are previous questions, move to the previous question.
      currentPageIndex--; // Decrement the current page index
      _controller1.animateToPage(
        currentPageIndex, // Use the updated index
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInExpo,
      );
      setState(() {
        btnPressed = false;
      });
    }
  }

  @override
  void dispose() {
    if (_controller.isAnimating || _controller.isCompleted) {
      _controller.dispose();
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
          "Gukora Imyitozo",
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
      body: allQuestionList.isNotEmpty
          ? Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 10),
                      child: Text(
                        "TQ:${allQuestionList.isEmpty ? 0 : allQuestionList.length} question(s)",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 18,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.punch_clock,
                        size: 30,
                        color: kPrimaryColor,
                      ),
                      Countdown(
                          animation: StepTween(begin: limitTime, end: 0)
                              .animate(_controller)),
                    ],
                  ),
                ),
                PageView.builder(
                    controller: _controller1,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allQuestionList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 80),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ModifiedQuizPlayTile(
                                questionModel: getQuestionModelFromList(index),
                                index: index,
                                quizId: widget.courseId,
                                quizTitle: "Testing Quiz",
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                    }),
              ],
            )
          : Container(
              child: Center(child: Text("No quiz available for this course")),
            ),

      //floating action button
      floatingActionButton: allQuestionList.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: kPrimaryLightColor,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Results(
                        correct: _correct, incorrect: _incorrect, total: total),
                  ),
                );
              },
              label: const Text(
                "Soza Imyitozo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            )
          : SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class ModifiedQuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  final String quizId;
  final String quizTitle;

  const ModifiedQuizPlayTile(
      {super.key,
      required this.questionModel,
      required this.index,
      required this.quizId,
      required this.quizTitle});

  @override
  State<ModifiedQuizPlayTile> createState() => _ModifiedQuizPlayTileState();
}

class _ModifiedQuizPlayTileState extends State<ModifiedQuizPlayTile> {
  String optionSelected = "";
  bool hasInternetConnection = true;
  bool isInCorrectOption = false;
  bool _isLoading = false;
  final apiUrl = API.hostUser;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color backgroundColor = Colors.white;
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Q${widget.index + 1}. ${widget.questionModel.question}",
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      child: null,
                    ),
              userRole == "Admin"
                  ? Column(
                      children: [
                        _getEditIcon(),
                        SizedBox(
                          height: size.height * 0.05,
                        ),
                        _getDeleteIcon(),
                      ],
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(0.0),
            child: Center(
              child: Stack(
                children: <Widget>[
                  (widget.questionModel.questionImgUrl.isEmpty)
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Material(
                                // display new updated image
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                clipBehavior: Clip.hardEdge,
                                // display new updated image
                                child: Image.network(
                                  apiUrl +
                                      "/${widget.questionModel.questionImgUrl}",
                                  width: size.width * 0.5,
                                  height: size.height * 0.2,
                                  fit: BoxFit.cover,
                                )),
                          ],
                        ),
                ],
              ),
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
          // Text(answerCorrect),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: Colors.green,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 20.0,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Edit1Question(
                id: widget.questionModel.id.toString(),
                courseId: widget.quizId,
                question: widget.questionModel.question,
                questionUrl: widget.questionModel.questionImgUrl,
                option1: widget.questionModel.option1,
                option2: widget.questionModel.option2,
                option3: widget.questionModel.option3,
                option4: widget.questionModel.option4,
                correctOption: widget.questionModel.correctOption,
              );
            },
          ),
        );
      },
    );
  }

  Widget _getDeleteIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 20.0,
        ),
      ),
      onTap: () {
        setState(() {
          _isLoading = true;
        });
        final deleteApiUrl = API.deleteQuestion;
        GenerateUser.deleteUserCode(context, widget.questionModel.id.toString(),
            deleteApiUrl, "quiz 1", "question deleted successfully");
      },
    );
  }

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  String userRole = "";

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
  }
}
