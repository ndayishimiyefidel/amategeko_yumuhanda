import 'edit_quiz.dart';
import 'open_quiz.dart';
import '../../utils/constants.dart';
import '../../widgets/fcmWidget.dart';
import 'package:flutter/material.dart';
import '../../widgets/ProgressWidget.dart';
import 'package:amategeko/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amategeko/screens/questions/add_question.dart';
import 'package:amategeko/components/text_field_container.dart';

class NewQuiz extends StatefulWidget {
  const NewQuiz({Key? key}) : super(key: key);

  @override
  State<NewQuiz> createState() => _NewQuizState();
}

class _NewQuizState extends State<NewQuiz> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<dynamic>? quizStream;
  bool isLoading = false;
  DatabaseService databaseService = DatabaseService();
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
  }

  getToken() async {
    //delete quiz
    await FirebaseFirestore.instance
        .collection("Users")
        .where("role", isEqualTo: "Admin")
        .get()
        .then((value) {
      if (value.size == 1) {
        Map<String, dynamic> adminData = value.docs.first.data();
        userToken = adminData["fcmToken"];
        adminPhone = adminData["phone"];
        print("Admin Token is  $userToken");
      }
    });
  }

  Widget quizList() {
    return StreamBuilder(
      stream: quizStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          case ConnectionState.none:
            return const Text('Error,No internet');
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return snapshot.data == null
                  ? const Center(
                      child: Text(
                        "There is no available quiz at this time ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        ///calculate number of question in specific quiz
                        ///in this time i will use collection group
                        ///

                        return QuizTile(
                          index: index,
                          quizId: snapshot.data!.docs[index].data()['quizId'],
                          imgurl:
                              snapshot.data!.docs[index].data()["quizImgUrl"],
                          title: snapshot.data.docs[index].data()["quizTitle"],
                          desc: snapshot.data.docs[index].data()["quizDesc"],
                          quizType:
                              snapshot.data.docs[index].data()["quizType"],
                          totalQuestion: totalQuestion,
                          userRole: userRole!,
                          userToken: userToken,
                          senderName: currentusername,
                          currentUserId: currentuserid,
                          phone: phone,
                          email: email,
                          photoUrl: photo,
                          quizPrice:
                              snapshot.data.docs[index].data()["quizPrice"],
                          adminPhone: adminPhone.toString(),
                        );
                      });
            }
        }
      },
    );
  }

  @override
  void initState() {
    ////
    ///update

    _messaging.getToken().then((value) {
      print("My token is $value");
    });
    databaseService.getNewQuizData().then((value) async {
      setState(() {
        quizStream = value;
      });
    });

    getCurrUserData(); //get login data
    requestPermission(); //request permission
    loadFCM(); //load fcm
    listenFCM(); //list fcm
    getToken(); //get admin token
    FirebaseMessaging.instance.subscribeToTopic("Traffic-Notification");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar
      key: _scaffoldKey,
      body: quizList(),
    );
  }
}

class QuizTile extends StatefulWidget {
  final String imgurl;
  final String title;
  final String desc;
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
  final String quizPrice;
  final String email, photoUrl;
  final int index;

  const QuizTile({
    Key? key,
    required this.imgurl,
    required this.title,
    required this.desc,
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
    required this.quizPrice,
    required this.adminPhone,
    required this.index,
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
                width: size.width * 0.003,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: InkWell(
              splashColor: kPrimaryColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Image.network(
                        widget.imgurl.toString(),
                        height: size.height * 0.2,
                        width: size.width * 0.9,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Text("${widget.index + 1}. ${widget.title}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Text(
                        widget.desc,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.blueGrey,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),

                      // Text(
                      //   "Exam PRICE:  ${widget.quizPrice}",
                      //   textAlign: TextAlign.start,
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.green,
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: size.height * 0.02,
                      // ),
                      // Text(
                      //   "Exam : ${widget.examno}",
                      //   textAlign: TextAlign.start,
                      //   style: const TextStyle(
                      //     fontSize: 22,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.blue,
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: size.height * 0.03,
                      // ),
                      //button
                      _isLoading
                          ? circularprogress()
                          : Container(
                              child: null,
                            ),
                      if (widget.userRole != "Admin")
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              side: const BorderSide(
                                  color: Colors.green, width: 1),
                            ),
                            onPressed: () {
                              if (widget.quizType == "Free") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return OpenQuiz(
                                        quizId: widget.quizId,
                                        title: widget.title,
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
                                            title: Column(
                                              children: [
                                                const Text(
                                                  "CODE VERIFICATION",
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  "Kugirango ubashe kwinjira muri exam icyo usabwa nukwishyura ${widget.quizPrice.isEmpty ? 1500 : widget.quizPrice}frw kuri ${widget.adminPhone} cyangwa kuri momo pay 329494 tugusobanurira amategeko y'umuhanda ndetse n'imitego ituma harabatsindwa kuberako batayimenye.",
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontStyle: FontStyle.italic,
                                                    color: kPrimaryColor,
                                                  ),
                                                ),
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
                                                        "Type Your code...",
                                                    border: InputBorder.none,
                                                  ),
                                                  onChanged: (val) {
                                                    code = val;
                                                  },
                                                  autovalidateMode:
                                                      AutovalidateMode.disabled,
                                                  validator: (input) =>
                                                      input!.isEmpty
                                                          ? 'Enter Code Please'
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
                                                  "Continue",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        kPrimaryLightColor,
                                                    elevation: 3),
                                                onPressed: () async {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });
                                                  requestCode(
                                                      widget.userToken,
                                                      widget.currentUserId,
                                                      widget.senderName,
                                                      widget.title);
                                                },
                                                child: const Text(
                                                  "Request Code",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal),
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
                                const Text(
                                  "Start Exam",
                                  style: TextStyle(
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
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return OpenQuiz(
                                              quizId: widget.quizId,
                                              title: widget.title,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "View",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.1,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryLightColor,
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return EditQuiz(
                                              quizId: widget.quizId,
                                              quizTitle: widget.title,
                                              quizType: widget.quizType,
                                              quizImage: widget.imgurl,
                                              quizDesc: widget.desc,
                                              quizPrice: widget.quizPrice,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Edit Quiz",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.03,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return AddQuestion(
                                              quizId: widget.quizId,
                                              quizTitle: widget.title,
                                              isNew: true,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Add",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.03,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryLightColor),
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      deleteQuiz(widget.quizId);
                                    },
                                    child: const Text(
                                      "Delete Quiz",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
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

//delete quiz
  Future<void> deleteQuiz(String docId) async {
    await FirebaseFirestore.instance
        .collection("Quizmaker")
        .doc(docId)
        .collection("QNA")
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
                    content: const Text("Quiz deleted successfully!"),
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
        });
      });
      FirebaseFirestore.instance.collection("Quizmaker").doc(docId).delete();
    });
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
      querySnapshot.docs.forEach((doc) {
        print(doc.reference.id);
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
      });
    });
  }

//request code
  Future<void> requestCode(String userToken, String currentUserId,
      String senderName, String title) async {
    String body =
        "Hello Sir,My Name is $senderName  and My phone number is ${widget.phone} \n I have completed to pay for exam called $title .\n"
        "so can generate code for me. Thank you I'm waiting.";
    String notificationTitle = "Requesting Quiz Code";

    //make sure that request is not already sent
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("isQuiz", isEqualTo: true)
        .get()
        .then((value) {
      if (value.size == 1) {
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
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                        "Your request sent successfully, we will let you once your information is processed."),
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
        });
      }
    });
  }
}
