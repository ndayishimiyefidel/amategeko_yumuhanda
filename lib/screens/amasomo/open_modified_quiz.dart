import 'dart:async';

import 'package:amategeko/enume/models/question_model.dart';
import 'package:amategeko/screens/amasomo/play_modified_quiz.dart';
import 'package:amategeko/screens/quizzes/quizzes.dart';
import 'package:amategeko/screens/quizzes/result_screen.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/count_down.dart';
import '../homepages/noficationtab1.dart';
import 'edit_quiz_question.dart';

class OpenModifiedQuiz extends StatefulWidget {
  final String courseId;
  // ignore: prefer_typing_uninitialized_variables
  final title;
  // ignore: prefer_typing_uninitialized_variables
  final quizNumber;

  OpenModifiedQuiz({required this.courseId, this.title, this.quizNumber});

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

class _OpenModifiedQuizState extends State<OpenModifiedQuiz>
     with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Timer? interstitialTimer;
  InterstitialAd? _interstitialAd;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2864387622629553/2309153588',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('InterstitialAd is not loaded yet.');
    }
  }
  DatabaseService databaseService = DatabaseService();
  QuerySnapshot? questionSnapshot;
  late AnimationController _controller;
  final limitTime = 1200;
  int currentPageIndex = 0;

  QuestionModel getQuestionModelFromDatasnapshot(
      DocumentSnapshot questionSnapshot) {
    QuestionModel questionModel =
        QuestionModel(qn, op1, op2, op3, op4, correctOp, ans, questionImgUrl);
    questionModel.question = questionSnapshot['question'];
    questionModel.questionImgUrl = questionSnapshot['quizPhotoUrl'];
    List<String> options = [
      questionSnapshot["option1"],
      questionSnapshot["option2"],
      questionSnapshot["option3"],
      questionSnapshot["option4"],
    ];
    //options.shuffle(); //random question
    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];
    questionModel.correctOption = questionSnapshot["correctAnswer"];
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
    _controller1 = PageController(initialPage: 0);
    databaseService.getModifiedQuizQuestion(widget.courseId).then((value) {
      questionSnapshot = value;
      _notAttempted = 0;
      _correct = 0;
      _incorrect = 0;
      total = questionSnapshot!.docs.length;
      setState(() {});
    });
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: limitTime));
    _controller.addListener(() {
      if (_controller.isCompleted) {
        showInterstitialAd();
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

    loadInterstitialAd();
    super.initState();
  }


  // onPressed callback for the "Next" button.
  void onNextPressed() {
    if (currentPageIndex < (questionSnapshot?.docs.length ?? 0) - 1) {
      // If there are more questions, move to the next question.
      currentPageIndex++;
      if (kDebugMode) {
        print("current page $currentPageIndex");
      }
      if (currentPageIndex == 4) {
        showInterstitialAd(); //show ads on question 10
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
      if (currentPageIndex == (questionSnapshot?.docs.length)! - 1) {
        setState(() {
          btnText = "Soza Quiz";
        });
      }
      setState(() {
        btnPressed = false;
      });
    } else {
      // If there are no more questions, navigate to the Results screen.

      showInterstitialAd();

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
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 35, top: 10),
                child: Text(
                  "TQ:${questionSnapshot == null ? 0 : questionSnapshot!.docs.length} question(s)",
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 25,
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
                    animation: StepTween(begin: limitTime, end: 0)
                        .animate(_controller)),
              ],
            ),
          ),

            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("courses")
                  .doc(widget.courseId)
                  .collection("courseQuiz")
                  .get(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                default:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return PageView.builder(
                        controller: _controller1,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: questionSnapshot?.docs.length ?? 0,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 80),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                   ModifiedQuizPlayTile(
                                      questionModel:
                                          getQuestionModelFromDatasnapshot(
                                              questionSnapshot!.docs[currentPageIndex]),
                                      index: currentPageIndex,
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
                                              color: Colors.white,
                                              fontSize: 18),
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
                                              color: Colors.white,
                                              fontSize: 18),
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
                        });
                  }
              }
            }),
        ],
      ),

      //floating action button
      floatingActionButton: FloatingActionButton.extended(
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
      ),
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(5)),
                              clipBehavior: Clip.hardEdge,
                              // display new updated image
                              child: Image.network(
                                widget.questionModel.questionImgUrl,
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
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                //check correct
                if (widget.questionModel.option1 ==
                    widget.questionModel.correctOption) {
                  optionSelected = widget.questionModel.option1;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                } else {
                  optionSelected = widget.questionModel.option1;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;

                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(
                            "Igisubizo cy'ukuri: ${widget.questionModel.correctOption}",
                            style: const TextStyle(
                                color: Colors.green, fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Close"))
                          ],
                        );
                      });

                  setState(() {});
                }
              }
            },
            child: OptionModifiedTile(
              correctAnswer: widget.questionModel.correctOption,
              option: const Icon(
                (Icons.check),
              ),
              description: widget.questionModel.option1,
              optionSelected: optionSelected,
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          GestureDetector(
            onTap: () {
              print("correct option: ${widget.questionModel.correctOption}");
              if (!widget.questionModel.answered) {
                //check correct
                if (widget.questionModel.option2 ==
                    widget.questionModel.correctOption) {
                  optionSelected = widget.questionModel.option2;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;

                  setState(() {});
                } else {
                  optionSelected = widget.questionModel.option2;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(
                            "Igisubizo cy'ukuri: ${widget.questionModel.correctOption}",
                            style: const TextStyle(
                                color: Colors.green, fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Close"))
                          ],
                        );
                      });
                  setState(() {});
                }
              }
            },
            child: OptionModifiedTile(
              correctAnswer: widget.questionModel.correctOption,
              option: const Icon(Icons.check),
              description: widget.questionModel.option2,
              optionSelected: optionSelected,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                //check correct
                if (widget.questionModel.option3 ==
                    widget.questionModel.correctOption) {
                  optionSelected = widget.questionModel.option3;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                } else {
                  optionSelected = widget.questionModel.option3;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(
                            "Igisubizo cy'ukuri: ${widget.questionModel.correctOption}",
                            style: const TextStyle(
                                color: Colors.green, fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Close"))
                          ],
                        );
                      });
                }
              }
            },
            child: OptionModifiedTile(
              correctAnswer: widget.questionModel.correctOption,
              option: Icon(Icons.check),
              description: widget.questionModel.option3,
              optionSelected: optionSelected,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              if (!widget.questionModel.answered) {
                //check correct
                if (widget.questionModel.option4 ==
                    widget.questionModel.correctOption) {
                  optionSelected = widget.questionModel.option4;
                  widget.questionModel.answered = true;
                  _correct = _correct + 1;
                  _notAttempted = _notAttempted - 1;
                  setState(() {});
                } else {
                  optionSelected = widget.questionModel.option4;
                  widget.questionModel.answered = true;
                  _incorrect = _incorrect + 1;
                  _notAttempted = _notAttempted - 1;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(
                            "Igisubizo cy'ukuri: ${widget.questionModel.correctOption}",
                            style: const TextStyle(
                                color: Colors.green, fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Close"))
                          ],
                        );
                      });
                  setState(() {});
                }
              }
            },
            child: OptionModifiedTile(
              correctAnswer: widget.questionModel.correctOption,
              option: const Icon(Icons.check),
              description: widget.questionModel.option4,
              optionSelected: optionSelected,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
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
                quizId: widget.quizId,
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
        deleteDoc(widget.quizId, widget.questionModel.question);
      },
    );
  }

  Future<void> deleteDoc(String docId, String question) async {
    await FirebaseFirestore.instance
        .collection("courses")
        .doc(docId)
        .collection("courseQuiz")
        .where("question", isEqualTo: question)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete().then((value) {
          //question delete
          setState(() {
            _isLoading = false;
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text("question deleted successfully"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("ok"))
                    ],
                  );
                });
          });
        });
      });
    });
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
