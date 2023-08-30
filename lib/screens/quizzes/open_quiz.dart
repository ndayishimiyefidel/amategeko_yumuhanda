import 'dart:async';

import 'package:amategeko/enume/models/question_model.dart';
import 'package:amategeko/screens/quizzes/quizzes.dart';
import 'package:amategeko/screens/quizzes/result_screen.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:amategeko/widgets/play_quiz_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/count_down.dart';
import '../homepages/noficationtab1.dart';
import '../questions/edit_question.dart';

class OpenQuiz extends StatefulWidget {
  final String quizId;
  final String title;
  final quizNumber;

  const OpenQuiz(
      {super.key, required this.quizId, required this.title, this.quizNumber});

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
  late BannerAd _bannerAd;
  bool isBannerLoaded = false;
  bool isBannerVisible = false;
  Timer? bannerTimer;

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

  //shared preferences
  late SharedPreferences preferences;
  String? userRole;
  ConnectivityResult? _connectivityResult;

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      userRole = preferences.getString("role")!;
    });
  }

  bool isQuizVisible = true;
  late ScreenshotCallback screenshotCallback;
  DatabaseService databaseService = DatabaseService();
  QuerySnapshot? questionSnapshot;
  late AnimationController _controller;
  final limitTime = 1200;
  int currentQuestionIndex = 0;

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

  bool btnPressed = false;
  String btnText = "Next";
  String btnTextPrevious = "Previous";
  bool answered = false;
  PageController? _controller1;

  @override
  void initState() {
    super.initState();
    // Enable Firestore offline persistence
    if (kIsWeb) {
      FirebaseFirestore.instance.enablePersistence().catchError((err) {
        print("Firebase persistence error: $err");
      });
    }

    // Initialize connectivity
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _connectivityResult = result;
      });
    });

    // Initialize shared preferences
    SharedPreferences.getInstance().then((prefs) {
      setState(() {});
    });
    _controller1 = PageController(initialPage: 0);
    //interestial ads
    loadInterstitialAd();
    // Start the timer to show the interstitial ad every 4 minutes
    // interstitialTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
    //   showInterstitialAd();
    // });

    //banner add
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2864387622629553/7276208106',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
        // Add other banner ad listener callbacks as needed.
      ),
    );

    _bannerAd.load();
    // Initialize the banner timer
    bannerTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      setState(() {
        isBannerVisible = true;
      });
    });
    // addCorrectOptionField();
    getCurrUserData();
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
    if (userRole != "Admin") {
      screenshotCallback = ScreenshotCallback();
      screenshotCallback.addListener(handleScreenshot);
      // Disable screen recording
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  Future<void> addCorrectOptionField() async {
    // Step 1: Get current timestamp in milliseconds since epoch
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    // Step 2: Convert milliseconds to DateTime
    DateTime currentDateTime =
        DateTime.fromMillisecondsSinceEpoch(currentTimestamp);

    // Step 3: Add 2 months to the DateTime object
    DateTime updatedDateTime = currentDateTime.add(const Duration(days: 20));

    // Step 4: Convert the updated DateTime object back to milliseconds
    int updatedTimestamp = updatedDateTime.millisecondsSinceEpoch;

    CollectionReference quizmakerCollectionRef = FirebaseFirestore.instance
        .collection('Quiz-codes'); // Updated collection name

    QuerySnapshot quizmakerQuerySnapshot = await quizmakerCollectionRef.get();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (QueryDocumentSnapshot quizmakerDoc in quizmakerQuerySnapshot.docs) {
      batch.update(quizmakerDoc.reference,
          {'endTime': updatedTimestamp.toString()}); // Update the main document

      // If there's no nested collection, you don't need to query or update anything inside it.
    }

    await batch.commit();
  }

  void handleScreenshot() {
    setState(() {
      isQuizVisible = false;
    });
  }

  @override
  void dispose() {
    if (_controller.isAnimating || _controller.isCompleted) {
      _controller.dispose();
    }
    //screenshotCallback.removeListener(handleScreenshot);
    if (userRole != "Admin") {
      screenshotCallback.dispose();
    }

    // Dispose the banner timer when the widget is disposed
    _bannerAd.dispose();
    bannerTimer?.cancel();
    super.dispose();
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
        //showInterstitialAd();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Results(
              correct: _correct,
              incorrect: _incorrect,
              total: total,
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
              padding: const EdgeInsets.only(left: 0, top: 10),
              child: Text(
                "Exam No:${widget.quizNumber}",
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
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: Text(
                questionSnapshot == null
                    ? "TQ: Loading question(s)..." // Display loading message
                    : "TQ:${questionSnapshot!.docs.length} question(s)",
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
                  animation:
                      StepTween(begin: limitTime, end: 0).animate(_controller)),
            ],
          ),
        ),
        FutureBuilder<QuerySnapshot>(builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return PageView.builder(
                    controller: _controller1!,
                    onPageChanged: (page) {
                      if (page == questionSnapshot!.docs.length - 1) {
                        setState(() {
                          btnText = "Soza Exam";
                        });
                      }
                      setState(() {
                        answered = false;
                      });
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: questionSnapshot?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 80),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              QuizPlayTile(
                                questionModel: getQuestionModelFromDatasnapshot(
                                    questionSnapshot!.docs[index]),
                                index: index,
                                quizId: widget.quizId,
                                quizTitle: widget.title,
                                userRole: userRole.toString(),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RawMaterialButton(
                                    onPressed: () {
                                      if (_controller1!.page?.toInt() ==
                                          questionSnapshot!.docs.length - 1) {
                                      } else {
                                        _controller1!.previousPage(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            curve: Curves.easeInExpo);

                                        setState(() {
                                          btnPressed = false;
                                        });
                                      }
                                    },
                                    shape: const StadiumBorder(),
                                    fillColor: Colors.blue,
                                    padding: const EdgeInsets.all(18.0),
                                    elevation: 0.0,
                                    child: Text(
                                      btnTextPrevious,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                  RawMaterialButton(
                                    onPressed: () {
                                      if (_controller1!.page?.toInt() ==
                                          questionSnapshot!.docs.length - 1) {
                                        showInterstitialAd();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Results(
                                                  correct: _correct,
                                                  incorrect: _incorrect,
                                                  total: total),
                                            ));
                                      } else {
                                        // if (_controller1!.page?.toInt() == 16) {
                                        //   showInterstitialAd();
                                        // }
                                        _controller1!.nextPage(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            curve: Curves.easeInExpo);

                                        setState(() {
                                          btnPressed = false;
                                        });
                                      }
                                    },
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
                              )
                            ],
                          ),
                        ),
                      );
                    });
              }
          }
        }),
        // if (isBannerVisible && isBannerLoaded) BannerAdWidget(ad: _bannerAd),
      ],
    );
  }
}

class BannerAdWidget extends StatelessWidget {
  final BannerAd ad;

  const BannerAdWidget({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: size.width.toDouble(),
        height: 50.0, // Set the desired height for the banner ad
        child: AdWidget(ad: ad),
      ),
    );
  }
}

class QuizPlayTile extends StatefulWidget {
  final QuestionModel questionModel;
  final int index;
  final String quizId;
  final String quizTitle;
  final String userRole;

  const QuizPlayTile(
      {super.key,
      required this.questionModel,
      required this.index,
      required this.quizId,
      required this.quizTitle,
      required this.userRole});

  @override
  State<QuizPlayTile> createState() => _QuizPlayTileState();
}

class _QuizPlayTileState extends State<QuizPlayTile> {
  String optionSelected = "";
  bool _isLoading = false;

  bool hasInternetConnection = true;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        hasInternetConnection = false;
      });
    }
  }

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
              widget.userRole == "Admin"
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
                            Expanded(
                              child: Material(
                                  color: Colors.white,
                                  // display new updated image
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(1)),
                                  clipBehavior: Clip.hardEdge,
                                  // display new updated image
                                  child: hasInternetConnection
                                      ? Image.network(
                                          widget.questionModel.questionImgUrl,
                                          width: size.width * 0.1,
                                          height: size.height * 0.2,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, object, stackTrace) =>
                                                  const Center(
                                            child: Text(
                                                "Ibyapa bigaragara iyo ufite internet connection"),
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: widget
                                              .questionModel.questionImgUrl,
                                          width: size.width * 0.1,
                                          height: size.height * 0.2,
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          // Placeholder while loading
                                          errorWidget: (context, url, error) =>
                                              const Center(
                                            child: Text(
                                                "Ibyapa bigaragara iyo ufite internet connection"),
                                          ), // Placeholder on error
                                        )),
                            ),
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
                // correctOption: widget.questionModel.correctOption,
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
}
