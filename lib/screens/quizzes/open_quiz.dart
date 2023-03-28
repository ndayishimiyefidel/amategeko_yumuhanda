import 'package:amategeko/enume/models/question_model.dart';
import 'package:amategeko/screens/quizzes/quizzes.dart';
import 'package:amategeko/screens/quizzes/result_screen.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:amategeko/widgets/play_quiz_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/count_down.dart';
import '../homepages/noficationtab1.dart';
import '../questions/edit_question.dart';

class OpenQuiz extends StatefulWidget {
  final String quizId;
  final String title;

  OpenQuiz({required this.quizId, required this.title});

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
    with SingleTickerProviderStateMixin {
  DatabaseService databaseService = DatabaseService();
  QuerySnapshot? questionSnapshot;
  late AnimationController _controller;
  final limitTime = 1200;

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
    options.shuffle(); //random question
    questionModel.option1 = options[0];
    questionModel.option2 = options[1];
    questionModel.option3 = options[2];
    questionModel.option4 = options[3];
    questionModel.correctOption = questionSnapshot["option1"];
    questionModel.answered = false;
    return questionModel;
  }

  @override
  void dispose() {
    if (_controller.isAnimating || _controller.isCompleted) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    print("${widget.quizId}");
    databaseService.getQuizQuestion(widget.quizId).then((value) {
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

  @override
  Widget build(BuildContext context) {
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
          "Taking Quiz",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "TITLE:${widget.title}",
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
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "TQ:${questionSnapshot == null ? 0 : questionSnapshot!.docs.length} question(s)",
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
              questionSnapshot == null
                  ? Container(
                      child: Center(
                        child:
                            Text("No Question for this Quiz ${widget.title}"),
                      ),
                    )
                  : FutureBuilder<QuerySnapshot>(builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const CircularProgressIndicator();
                        default:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // snapshot.data!.docs
                            //     .map((DocumentSnapshot document) {
                            //   Map<String, dynamic> data =
                            //       document.data()! as Map<String, dynamic>;
                            //   print(data);
                            //
                            //   print(document.id);
                            // });
                            return ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: const ClampingScrollPhysics(),
                                itemCount: questionSnapshot!.docs.length,
                                itemBuilder: (context, index) {
                                  return QuizPlayTile(
                                    questionModel:
                                        getQuestionModelFromDatasnapshot(
                                            questionSnapshot!.docs[index]),
                                    index: index,
                                    quizId: widget.quizId,
                                    quizTitle: widget.title,
                                  );
                                });
                          }
                      }
                    }),
            ],
          ),
        ),
      ),
      //floating action button
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.check_outlined,
          size: 35,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Results(
                  correct: _correct, incorrect: _incorrect, total: total),
            ),
          );
        },
      ),
    );
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  final String quizId;
  final String quizTitle;

  QuizPlayTile(
      {required this.questionModel,
      required this.index,
      required this.quizId,
      required this.quizTitle});

  @override
  State<QuizPlayTile> createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
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
                      : Container(
                          child: Row(
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
            child: OptionTile(
              correctAnswer: widget.questionModel.correctOption,
              option: "A",
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
            child: OptionTile(
              correctAnswer: widget.questionModel.correctOption,
              option: "B",
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
            child: OptionTile(
              correctAnswer: widget.questionModel.correctOption,
              option: "C",
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
            child: OptionTile(
              correctAnswer: widget.questionModel.correctOption,
              option: "D",
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
              return EditQuestion(
                quizId: widget.quizId,
                question: widget.questionModel.question,
                questionUrl: widget.questionModel.questionImgUrl,
                option1: widget.questionModel.option1,
                option2: widget.questionModel.option2,
                option3: widget.questionModel.option3,
                option4: widget.questionModel.option4,
                quizTitle: widget.quizTitle,
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
        .collection("Quizmaker")
        .doc(docId)
        .collection("QNA")
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
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) {
                              return Quizzes();
                            }));
                          },
                          child: const Text("Close"))
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
