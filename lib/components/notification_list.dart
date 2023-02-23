import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/fcmWidget.dart';

class UsersNotificationList extends StatefulWidget {
  final String name;

  // final String secondaryText;
  final String image;
  final String time;
  final String quizId, quizTitle;
  final String userId;
  final String email;
  final String phone;
  final String code, docId;

  const UsersNotificationList({
    super.key,
    required this.name,
    required this.image,
    required this.time,
    required this.email,
    required this.userId,
    required this.phone,
    required this.quizId,
    required this.quizTitle,
    required this.code,
    required this.docId,
  });

  @override
  _UsersNotificationListState createState() => _UsersNotificationListState();
}

class _UsersNotificationListState extends State<UsersNotificationList> {
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late String currentUserPhone;
  String? userRole;
  late String phoneNumber;
  late SharedPreferences preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrUser(); //get login data
    requestPermission(); //request permission
    loadFCM(); //load fcm
    listenFCM(); //li st fcm
    //get admin token
    FirebaseMessaging.instance.subscribeToTopic("Traffic-Notification");
  }

  getCurrUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentuserphoto = preferences.getString("photo")!;
      currentUserPhone = preferences.getString("phone")!;
      userRole = preferences.getString("role");
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    int timestamp = int.parse(widget.time);
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var dateTimeFormat =
        DateFormat('dd/MM/yyyy, hh:mm a').format(date); // 12/31/2000, 10:00 PM
    return InkWell(
      onTap: () {
        // _getEditIcon();
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return OpenNotification(
        //     notificationId: widget.docId,
        //   );
        // }));
      },
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.image),
                        maxRadius: 30,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: size.width * 0.03,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userRole == "Admin"
                                ? widget.name
                                : "Quiz Title: ${widget.quizTitle}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            userRole == "Admin"
                                ? widget.phone
                                : "Quiz-code: ${widget.code}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            userRole == "Admin" ? widget.email : dateTimeFormat,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic),
                          ),
                          Text(
                            userRole == "Admin"
                                ? "Quiz Title : ${widget.quizTitle}"
                                : "",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic),
                          ),
                          Text(
                            userRole == "Admin"
                                ? "Quiz code: ${widget.code}"
                                : "",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.03,
                  ),
                  userRole == "Admin"
                      ? Expanded(
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _getGenerateIcon(),
                                SizedBox(
                                  height: size.height * 0.03,
                                ),
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : Container(
                                        child: null,
                                      ),
                                _getDeleteIcon(),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          child: null,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getGenerateIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: Colors.green,
        radius: 14.0,
        child: Icon(
          Icons.generating_tokens_outlined,
          color: Colors.white,
          size: 20.0,
          semanticLabel: "generate",
        ),
      ),
      onTap: () {
        setState(() {
          _isLoading = true;
        });
        _generateCode(widget.docId);
        print("document id :${widget.docId}");
      },
    );
  }

  String generatedCode = randomNumeric(6);

  Future<void> _generateCode(String docId) async {
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .doc(docId)
        .update({"code": generatedCode}).then((value) {
      _getToken();
      setState(() {
        _isLoading = false;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                    "Generated code for ${widget.quizTitle} quiz  is $generatedCode. ${widget.name} get notified to his device"),
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

  //get fcm token
  _getToken() async {
    String userToken;
    await FirebaseFirestore.instance
        .collection("Users")
        .where("uid", isEqualTo: widget.userId)
        .get()
        .then((value) {
      setState(() {
        _isLoading = false;
        if (value.size == 1) {
          Map<String, dynamic> fcmToken = value.docs.first.data();
          userToken = fcmToken["fcmToken"];
          print("user device fcm Token is  $userToken");
          //send push notification to user
          String body =
              "Dear ${widget.name}, Your code for exams is $generatedCode"
              "please keep it secret,don't share with someone else.Thank you for choosing us,Enjoy!";
          String notificationTitle = "Quiz App Generating Code";
          sendPushMessage(userToken, body, notificationTitle);
        }
      });
    });
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
        deleteDoc(widget.docId);
      },
    );
  }

  Future<void> deleteDoc(String docId) async {
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .doc(docId)
        .delete()
        .then((value) {
      setState(() {
        _isLoading = false;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text("Notification deleted successfully"),
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
}
