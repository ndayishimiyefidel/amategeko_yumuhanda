import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';
import '../../utils/constants.dart';
import '../../utils/insttruction.dart';
import '../../widgets/ProgressWidget.dart';
import '../../widgets/apptext.dart';
import '../../widgets/fcmWidget.dart';
import 'open_quiz.dart';
import '../../ads/interestial_ad.dart';
import '../../ads/reward_video_manager.dart';

class NewQuiz extends StatefulWidget {
  const NewQuiz({Key? key}) : super(key: key);

  @override
  State<NewQuiz> createState() => _NewQuizState();
}

class _NewQuizState extends State<NewQuiz> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  String? userRole;
  String? adminPhone;

  late String phone;
  String userToken = "";
  bool hasCode = false;
  final InterestialAds adManager = InterestialAds();
  @override
  void initState() {
    _messaging.getToken().then((value) {});

    //check code
    getCurrUserData(); //get login data
    requestPermission(); //request permission
    loadFCM(); //load fcm
    listenFCM(); //list fcm
    getToken(); //get admin token
    FirebaseMessaging.instance;
    //load ads
    adManager.loadInterstitialAd();
    super.initState();
  }

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      phone = preferences.getString("phone")!;
      userToken = preferences.getString("fcmToken")!;
    });
    print(currentuserid);
    print(userRole);
    checkQuizCode(currentuserid);
  }

  Future<void> checkQuizCode(String userId) async {
    final url = API.checkCode; // Replace with your PHP script URL

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        if (data['success'] == true) {
          if (data['hasCode'] == true) {
            if (!mounted) return;
            setState(() {
              hasCode = true;
            });
          } else {
            if (!mounted) return;
            setState(() {
              hasCode = false;
            });
          }
        } else {
          // Handle other error cases
        }
      } else {
        // Handle HTTP request errors
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      // You can show an error message or perform other error handling as needed
    }
  }

  Future<void> getToken() async {
    final url = API.getToken; // Replace with your PHP script URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final adminData = data['data'];
          userToken = adminData['fcmToken'];
          adminPhone = adminData['phone'];
          print(adminPhone);
        } else {
          // Handle the case when there is no admin or other errors
        }
      } else {
        // Handle HTTP request errors
        print("failed to connect to server");
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
    }
  }

  Widget quizList() {
    return FutureBuilder(
      future:
          DefaultAssetBundle.of(context).loadString('assets/files/data.json'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No data available.');
        } else {
          final String jsonData = snapshot.data as String;
          final exams = json.decode(jsonData)['exams'];

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.79,
            child: ListView.builder(
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                return QuizTile(
                  index: index,
                  quizId: exam['quizId'],
                  imgurl: exam['examImgUrl'],
                  title: exam['title'],
                  quizType: exam['examType'],
                  totalQuestion: 20, // You may need to update this
                  userRole: userRole.toString(),
                  userToken: userToken,
                  senderName: currentusername,
                  currentUserId: currentuserid,
                  phone: phone,
                  adminPhone: adminPhone.toString(),
                  questions: List<Map<String, dynamic>>.from(exam['questions']),
                );
              },
            ),
          );
        }
      },
    );
  }

  void _showInterstitialAd() {
    // Show the interstitial ad when needed
    adManager.showInterstitialAd();
  }

  @override
  void dispose() {
    adManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appbar
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            children: [
              quizList(),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        floatingActionButton: (userRole != "Admin" && hasCode == false)
            ? FloatingActionButton.extended(
                label: const Row(
                  children: [
                    Text(
                      AppText.appcodeText,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return SingleChildScrollView(
                          child: AlertDialog(
                            title: Column(
                              children: [
                                Text(
                                  AppText.requestCode,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Column(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          AppText.firstInstruction,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.blueAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          AppText.secondInstruction,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.redAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          AppText.thirdInstruction,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.blueAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                    InstructionItems(
                                      title: AppText.fourthInstruction,
                                      phoneNumbers: [
                                        '0788659575',
                                        '0728877442'
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow,
                                    elevation: 3),
                                onPressed: () async {
                                  //show ad here
                                  _showInterstitialAd();
                                  // Request code action
                                  requestCode(userToken, currentuserid,
                                      currentusername, "Exam");
                                },
                                child: const Text(
                                  AppText.requestCodeButton,
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    onPressed: () async {
                                      // Direct phone call action
                                      await FlutterPhoneDirectCaller.callNumber(
                                          "*182*8*1*329494*1500#");
                                    },
                                    child: const Text(
                                      AppText.directPhoneCallButton,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                },
              )
            : null);
  }

  Future<void> requestCode(
      String userId, String quizId, String senderName, String title) async {
    final url = API.requestCode;
    final sabaCodeUrl = API.sabaCode;
    final int exam = 0;
    String body = AppText.requestCodeBody(senderName, phone);

    String notificationTitle = AppText.requestCodeTitle;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': currentuserid, 'ex_type': exam.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  AppText.requestCodeSuccessMessage,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppText.requestCodeSuccessCloseButtonText),
                  )
                ],
              );
            },
          );
        } else {
          try {
            final res = await http.post(
              Uri.parse(sabaCodeUrl),
              body: {
                'userId': currentuserid.toString(),
                'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
                "phone": phone.toString(),
                "name": currentusername,
                "ex_type": exam.toString()
              },
            );

            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              if (data['requestSent'] == true) {
                sendPushMessage(userToken, body, notificationTitle);
                isLoading = false;

                Size size = MediaQuery.of(context).size;
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                        AppText.requestCodeSuccessAlertMessage,
                      ),
                      actions: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          width: size.width * 0.7,
                          height: size.height * 0.07,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                              ),
                              onPressed: () async {
                                await FlutterPhoneDirectCaller.callNumber(
                                    "*182*8*1*329494*1500#");
                              },
                              child: Text(
                                AppText.requestCodeSuccessButtonText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child:
                              Text(AppText.requestCodeSuccessCloseButtonText),
                        )
                      ],
                    );
                  },
                );
              } else {
                Fluttertoast.showToast(
                  msg: AppText.requestCodeErrorMessage,
                  textColor: Colors.red,
                  fontSize: 10,
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: "Failed to connect to the API",
                textColor: Colors.red,
                fontSize: 10,
              );
            }
          } catch (e) {
            print("Error: $e");
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to connect to the API",
          textColor: Colors.red,
          fontSize: 10,
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}

class QuizTile extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String imgurl;
  final String title;
  final String quizId;
  final String quizType;
  final int totalQuestion;
  final String userRole;
  final String userToken;
  final String adminPhone;
  final String senderName;
  final String phone;
  final bool isNew = false;
  final String currentUserId;
  final int index;

  QuizTile({
    Key? key,
    required this.imgurl,
    required this.title,
    required this.quizId,
    required this.quizType,
    required this.totalQuestion,
    required this.userToken,
    required this.senderName,
    required this.phone,
    required this.currentUserId,
    required this.userRole,
    required this.adminPhone,
    required this.index,
    required this.questions,
  }) : super(key: key);

  @override
  State<QuizTile> createState() => _QuizTileState();
}

class _QuizTileState extends State<QuizTile> {
  bool _isLoading = false;
  bool isAlreadyOpened = false;
  late SharedPreferences preferences;
  @override
  void initState() {
    RewardedVideoAdManager.loadRewardAd();
    super.initState();
  }

  void showRewardedAd() {
    bool adShown = RewardedVideoAdManager.showRewardAd();

    if (!adShown) {
      print('Rewarded Ad is not loaded yet.');
    }
  }

  @override
  void dispose() {
    RewardedVideoAdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: kPrimaryColor,
                width: size.width * 0.006,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: InkWell(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            widget.imgurl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text("${widget.index + 1}. ${widget.title}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.start),
                      _isLoading
                          ? circularprogress()
                          : Container(
                              child: null,
                            ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            side:
                                const BorderSide(color: Colors.green, width: 1),
                          ),
                          onPressed: () async {
                            showRewardedAd();
                            if (widget.quizType == "Free" ||
                                widget.userRole == "Admin") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return OpenQuiz(
                                      quizId: widget.quizId,
                                      title: widget.title,
                                      quizNumber: widget.index + 1,
                                      questions: widget.questions,
                                      quizType: widget.quizType,
                                      examType: "Kinyarwanda",
                                    );
                                  },
                                ),
                              );
                            } else {
                              final isOpenUrl = API.isQuizOpen;
                              preferences =
                                  await SharedPreferences.getInstance();
                              isAlreadyOpened =
                                  preferences.getBool("isOpened") ?? false;
                              print("isOpened $isAlreadyOpened");
                              if (isAlreadyOpened == true) {
                                try {
                                  final response = await http.post(
                                    Uri.parse(isOpenUrl),
                                    body: {'userId': widget.currentUserId},
                                  );
                                  if (response.statusCode == 200) {
                                    final data = json.decode(response.body);

                                    if (data['isOpen'] == false) {
                                      isAlreadyOpened = await preferences
                                          .setBool("isOpened", false);
                                    }
                                  } else {
                                    print("Failed to connect to API");
                                  }
                                } catch (e) {
                                  // Handle exceptions
                                  print("Error: $e");
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return OpenQuiz(
                                        quizId: widget.quizId,
                                        title: widget.title,
                                        quizNumber: widget.index + 1,
                                        questions: widget.questions,
                                        quizType: widget.quizType,
                                        examType: "Kinyarwanda",
                                      );
                                    },
                                  ),
                                );
                              }
                              try {
                                final response = await http.post(
                                  Uri.parse(isOpenUrl),
                                  body: {'userId': widget.currentUserId},
                                );
                                if (response.statusCode == 200) {
                                  final data = json.decode(response.body);
                                  // print("Response Data ${data.isOpen}");
                                  if (data['isOpen'] == true) {
                                    isAlreadyOpened = await preferences.setBool(
                                        "isOpened", true);

                                    // print("Response Data $isAlreadyOpened");

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return OpenQuiz(
                                            quizId: widget.quizId,
                                            title: widget.title,
                                            quizNumber: widget.index + 1,
                                            questions: widget.questions,
                                            quizType: widget.quizType,
                                            examType: "Kinyarwanda",
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    isAlreadyOpened = await preferences.setBool(
                                        "isOpened", false);
                                    print("Response Data $isAlreadyOpened");
                                    // Request not sent
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Text(
                                                  AppText.accessMessage,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                              ],
                                            ),
                                          );
                                        });
                                  }
                                } else {
                                  print("Failed to connect to API");
                                }
                              } catch (e) {
                                // Handle exceptions
                                print("Error: $e");
                              }
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.userRole == "Admin"
                                    ? AppText.openExam
                                    : AppText.startExam,
                                style: const TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 2,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: size.width * 0.02,
                              ),
                              const Icon(
                                Icons.start,
                                size: 30,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
