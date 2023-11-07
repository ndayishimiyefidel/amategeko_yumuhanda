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
import '../../widgets/ProgressWidget.dart';
import '../../widgets/fcmWidget.dart';
import 'open_quiz.dart';

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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          final jsonData = json.decode(snapshot.data.toString());
          final exams = jsonData['exams'];
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
                      "Saba Code ya application",
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
                        return AlertDialog(
                          title: const Column(
                            children: [
                              Text(
                                "REQUEST CODE",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "1.Saba code igufasha gufungura application,kugirango uhabwe kode ubanza kwishyura 1500 rwf ukanze mu ibara ry'icyatsi cyangwa ukanze *182*8*1*329494*1500# kuri momo pay",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.blueAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          "2.Iyo Umanze kwishyura ukanda hano hasi handitse saba kode mu ibara ry'umuhondo ibi byose ubikora wafunguye connection",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.redAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          "3.Hanyuma ugategereza hagati y'iminota 2 kugeza kuri 5 ubundi ugasubira inyuma ugakanda ahanditse Tangira Exam ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.blueAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow, elevation: 3),
                              onPressed: () async {
                                //saba code
                                requestCode(userToken, currentuserid,
                                    currentusername, "Exam");
                              },
                              child: const Text(
                                "Saba Code",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  onPressed: () async {
                                    //direct phone call
                                    await FlutterPhoneDirectCaller.callNumber(
                                        "*182*8*1*329494*1500#");
                                  },
                                  child: const Text(
                                    "Kanda hano *182*8*1*329494*1500# wishyure",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName naho nimero ya telefoni ni  Namaze kwishyura amafaranga 1500 kuri 0788659575 yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': currentuserid},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print('Response Body: $data');
        if (data['success'] == true) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text(
                      "Your request have been already sent,Please wait the team is processing it."),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"))
                  ],
                );
              });
        } else {
          try {
            final res = await http.post(
              Uri.parse(sabaCodeUrl),
              body: {
                'userId': currentuserid.toString(),
                'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
                "phone": phone.toString(),
                "name": currentusername
              },
            );
            print(res.body);

            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              print('Response Body: $data');
              if (data['requestSent'] == true) {
                //handle if not sent
                sendPushMessage(userToken, body, notificationTitle);
                isLoading = false;
                Size size = MediaQuery.of(context).size;
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text(
                            "Ubusabe bwawe bwakiriwe neza, Kugirango ubone kode ikwinjiza muri exam banza wishyure."),
                        actions: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            width: size.width * 0.7,
                            height: size.height * 0.07,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor),
                                onPressed: () async {
                                  //direct phone call
                                  await FlutterPhoneDirectCaller.callNumber(
                                      "*182*8*1*329494*1500#");
                                },
                                child: const Text(
                                  "Ishyura 1500 Rwf.",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Okay"))
                        ],
                      );
                    });
              } else {
                Fluttertoast.showToast(
                  msg: "Faild to request code",
                  textColor: Colors.red,
                  fontSize: 14,
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: "Faild to connect to api",
                textColor: Colors.red,
                fontSize: 14,
              );
            }
          } catch (e) {
            // Handle exceptions
            print("Error: $e");
            // You can show an error message or perform other error handling as needed
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Faild to connect to api",
          textColor: Colors.red,
          fontSize: 14,
        );
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      // You can show an error message or perform other error handling as needed
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

  const QuizTile({
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
                                    );
                                  },
                                ),
                              );
                            } else {
                              ///check whether you already have code.
                              final isOpenUrl = API.isQuizOpen;
                              try {
                                final response = await http.post(
                                  Uri.parse(isOpenUrl),
                                  body: {'userId': widget.currentUserId},
                                );
                                if (response.statusCode == 200) {
                                  final data = json.decode(response.body);
                                  if (data['isOpen'] == true) {
                                    // Request already sent
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
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    // Request not sent
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Text(
                                                  "kugirango exam zifunguke kanda hepfo mwibara ry'ubururu uyisabe code ark urbe niba ufite connection.",
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
                                  // Handle HTTP request errors
                                }
                              } catch (e) {
                                // Handle exceptions
                                print("Error: $e");
                                // You can show an error message or perform other error handling as needed
                              }
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.userRole == "Admin"
                                    ? "Fungur Exam"
                                    : "Tangira Exam",
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
