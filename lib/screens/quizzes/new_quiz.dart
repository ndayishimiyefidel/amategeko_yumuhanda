import 'dart:async';
import 'dart:convert';
import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/ProgressWidget.dart';
import '../../widgets/banner_widget.dart';
import '../../widgets/fcmWidget.dart';
import 'open_quiz.dart';

class NewQuiz extends StatefulWidget {
  const NewQuiz({Key? key}) : super(key: key);

  @override
  State<NewQuiz> createState() => _NewQuizState();
}

class _NewQuizState extends State<NewQuiz> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<dynamic>? quizStream;
  bool isLoading = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  AuthService authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  late String email;
  late String photo;
  String? userRole;
  String? adminPhone;
  int examno = 0;

  late String phone;
  String userToken = "";
  late int totalQuestion = 0;
  bool hasCode = false;

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      photo = preferences.getString("photo")!;
      phone = preferences.getString("phone")!;
      email = preferences.getString("email")!;
    });
    FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentuserid.toString())
        .where("isOpen", isEqualTo: true)
        .get()
        .then((value) {
      if (value.size == 1) {
        setState(() {
          hasCode = true;
        });
      }
    });
  }

  getToken() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .where("role", isEqualTo: "Admin")
        .get()
        .then((value) {
      if (value.size == 1) {
        Map<String, dynamic> adminData = value.docs.first.data();
        userToken = adminData["fcmToken"];
        adminPhone = adminData["phone"];
      }
    });
  }

  Widget quizList() {
  return FutureBuilder(
    future: DefaultAssetBundle.of(context).loadString('assets/files/data.json'),
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
        return  SizedBox(height: MediaQuery.of(context).size.height*0.79,
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
                  totalQuestion:20, // You may need to update this
                  userRole: userRole.toString(),
                  userToken: userToken,
                  senderName: currentusername,
                  currentUserId: currentuserid,
                  phone: phone,
                  email: email,
                  photoUrl: photo,
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
  void initState() {
    _messaging.getToken().then((value) {
    });
   
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
              const AdBannerWidget(),
              const SizedBox(
                height: 5,
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

  Future<void> requestCode(String userToken, String currentUserId,
      String senderName, String title) async {
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName naho nimero ya telefoni ni  Namaze kwishyura amafaranga 1500 kuri 0788659575 yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    //make sure that request is not already sent
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("isQuiz", isEqualTo: true)
        .get()
        .then((value) {
      if (value.size == 0) {
        Map<String, dynamic> checkCode = {
          "userId": currentUserId,
          "name": senderName,
          "email": email,
          "phone": phone,
          "photoUrl": photo,
          "quizId": "gM34wj99547j4895",
          "quizTitle": title,
          "code": "",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "isOpen": false,
          "isQuiz": true,
        };
        FirebaseFirestore.instance
            .collection("Quiz-codes")
            .add(checkCode)
            .then((value) {
          //send push notification
          sendPushMessage(userToken, body, notificationTitle);
          setState(() {
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
          });
        });
      } else {
        setState(() {
          isLoading = false;
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
        });
      }
    });
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
  final String email, photoUrl;
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
    required this.email,
    required this.photoUrl,
    required this.userRole,
    required this.adminPhone,
    required this.index, required this.questions,
  }) : super(key: key);

  @override
  State<QuizTile> createState() => _QuizTileState();
}

class _QuizTileState extends State<QuizTile> {
  bool _isLoading = false;
  final _formkey = GlobalKey<FormState>();

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
                          child: Image.asset(widget.imgurl,
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
                              side: const BorderSide(
                                  color: Colors.green, width: 1),
                            ),
                            onPressed: () {
                              if (widget.quizType == "Free" || widget.userRole=="Admin") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return OpenQuiz(
                                        quizId: widget.quizId,
                                        title: widget.title,
                                        quizNumber: widget.index + 1,
                                        questions: widget.questions,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                ///check whether you already have code.
                                FirebaseFirestore.instance
                                    .collection("Quiz-codes")
                                    .where("userId",
                                        isEqualTo: widget.currentUserId)
                                    .where("isOpen", isEqualTo: true)
                                    .where("isQuiz", isEqualTo: true)
                                    .get()
                                    .then((value) {
                                  if (value.size == 1) {
                                    //open quiz without code.
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return OpenQuiz(
                                            quizId: widget.quizId,
                                            title: widget.title,
                                            quizNumber: widget.index + 1,
                                            questions: widget.questions,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    ///display dialogue to enter exam code.

                                    final TextEditingController codeController =
                                        TextEditingController();
                                    String code = "";
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Column(
                                              children: [
                                                Text(
                                                  "CODE VERIFICATION",
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  "Shyiramo code wahawe umaze kwishyura application niba nta kode ufite kanda hepfo mwibara ry'ubururu uyisabe.",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                              ],
                                            ),
                                            content: Form(
                                              key: _formkey,
                                              child: TextFieldContainer(
                                                child: TextFormField(
                                                  autofocus: false,
                                                  controller: codeController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onSaved: (value) {
                                                    codeController.text =
                                                        value!;
                                                  },
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  decoration:
                                                      const InputDecoration(
                                                    icon: Icon(
                                                      Icons.code_off_outlined,
                                                      color: kPrimaryColor,
                                                    ),
                                                    hintText:
                                                        "Shyiramo kode ya appplication ",
                                                    border: InputBorder.none,
                                                  ),
                                                  onChanged: (val) {
                                                    code = val;
                                                  },
                                                  autovalidateMode:
                                                      AutovalidateMode.disabled,
                                                  validator: (input) => input!
                                                          .isEmpty
                                                      ? 'Gukomeza bisaba Kode'
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        kPrimaryColor,
                                                    elevation: 3),
                                                onPressed: () async {
                                                  if (_formkey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    checkValidCode(
                                                      widget.currentUserId,
                                                      code,
                                                      widget.quizId,
                                                    );
                                                  }
                                                },
                                                child: const Text(
                                                  "Emeza",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Close"))
                                            ],
                                          );
                                        });
                                  }
                                });
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text( widget.userRole=="Admin" ?"Fungur Exam":"Tangira Exam",
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


  Future<void> checkValidCode(
      String currentUserId, String code, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("code", isEqualTo: code)
        .where("isQuiz", isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (kDebugMode) {
          print(doc.reference.id);
        }
        FirebaseFirestore.instance
            .collection("Quiz-codes")
            .doc(doc.reference.id)
            .update({"isOpen": true}).then((value) {
          if (querySnapshot.size == 1) {
            setState(() {
              _isLoading = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return OpenQuiz(
                      quizId: widget.quizId,
                      title: widget.title,
                      quizNumber: widget.index + 1,
                      questions: widget.questions,
                    );
                  },
                ),
              );
            });
          } else {
            setState(() {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text(
                          "Invalid code for this quiz,Double check and try again"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Close"))
                      ],
                    );
                  });
            });
          }
        });
      }
    });
  }

//request code
  Future<void> requestCode(String userToken, String currentUserId,
      String senderName, String title) async {
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName  naho nimero ya telefoni ni ${widget.phone} .\n  Namaze kwishyura amafaranga 1500 frw kuri nimero ${widget.adminPhone.isEmpty ? 0788659575 : widget.adminPhone} yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    //make sure that request is not already sent
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("isQuiz", isEqualTo: true)
        .get()
        .then((value) {
      if (value.size != 0) {
        setState(() {
          _isLoading = false;
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
        });
      } else {
        Map<String, dynamic> checkCode = {
          "userId": currentUserId,
          "name": senderName,
          "email": widget.email,
          "phone": widget.phone,
          "photoUrl": widget.photoUrl,
          "quizId": widget.quizId,
          "quizTitle": title,
          "code": "",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "isOpen": false,
          "isQuiz": true,
        };
        FirebaseFirestore.instance
            .collection("Quiz-codes")
            .add(checkCode)
            .then((value) {
          //send push notification
          sendPushMessage(userToken, body, notificationTitle);
          setState(() {
            _isLoading = false;
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
                          child: const Text("Close"))
                    ],
                  );
                });
          });
        });
      }
    });
  }
}
