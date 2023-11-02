import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/fcmWidget.dart';

class UsersNotificationList extends StatefulWidget {
  final String name;

  // final String secondaryText;
  // final String image;
  final String time;

  // final String quizId;
  final String quizTitle;
  final String userId;
  final String email;
  final String phone;
  final String code, docId;
  final bool? isQuiz;
  final String? endTime;

  const UsersNotificationList({
    super.key,
    required this.name,
    // required this.image,
    required this.time,
    required this.email,
    required this.userId,
    required this.phone,
    // required this.quizId,
    required this.quizTitle,
    required this.code,
    required this.docId,
    this.isQuiz,
    this.endTime,
  });

  @override
  State createState() => _UsersNotificationListState();
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
    int timestamp1 = (widget.endTime==null||widget.endTime!.isEmpty ) ? 1692260163454:int.parse(widget.endTime.toString());
    var date1 = DateTime.fromMillisecondsSinceEpoch(timestamp1);
    var dateTimeFormat1 = DateFormat('dd/MM/yyyy, hh:mm a').format(date1);
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userRole == "Admin"
                                ? widget.name
                                : "Title: ${widget.quizTitle}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
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
                              userRole == "Admin"
                                  ? Expanded(
                                      child: IconButton(
                                        onPressed: () async {
                                          //indirect phone call
                                          // launchUrl('tel://${widget.phone}' as Uri);
                                          //direct phone call
                                          await FlutterPhoneDirectCaller
                                              .callNumber(widget.phone);
                                        },
                                        icon: const Icon(
                                          Icons.call,
                                          size: 30,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      child: null,
                                    ),
                            ],
                          ),
                          Text(
                            userRole == "User" ? dateTimeFormat : "",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic),
                          ),
                          Text(
                            userRole == "Admin"
                                ? "Requested Date : $dateTimeFormat"
                                : "",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic),
                          ),
                          Text(
                            userRole == "Admin"
                                ? widget.isQuiz == true
                                    ? "Quiz code: ${widget.code}"
                                    : "code: ${widget.code}"
                                : "",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            userRole == "Admin"
                                ? "End Date Time : $dateTimeFormat1"
                                : "",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic),
                          ),
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
                                  height: size.height * 0.02,
                                ),
                                _isLoading
                                    ? const CircularProgressIndicator()
                                    : Container(
                                        child: null,
                                      ),
                                _setEndTimeIcon(),
                                SizedBox(
                                  height: size.height * 0.02,
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
        if (kDebugMode) {
          print("document id :${widget.docId}");
        }
      },
    );
  }

  Widget _setEndTimeIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: Colors.green,
        radius: 14.0,
        child: Icon(
          Icons.date_range_outlined,
          color: Colors.white,
          size: 20.0,
          semanticLabel: "change time",
        ),
      ),
      onTap: () {
        setState(() {
          _isLoading = true;
        });
        _pickDate();
        if (kDebugMode) {
          print("document id :${widget.docId}");
        }

        //date picker
      },
    );
  }

  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _updateEndTimeInFirestore();
      });
    }
  }

  Future<void> _updateEndTimeInFirestore() async {
    try {
      final CollectionReference collection = FirebaseFirestore.instance.collection(
          'Quiz-codes'); // Replace 'your_collection' with the actual collection name in Firestore

      await collection.doc(widget.docId).update({
        'endTime': _selectedDate?.millisecondsSinceEpoch.toString(),
      });

      // Successfully updated the endTime in Firestore
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Handle error if any
      if (kDebugMode) {
        print('Error updating endTime: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String generatedCode = randomNumeric(6);

  Future<void> _generateCode(String docId) async {
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .doc(docId)
        .update({"code": generatedCode, "isOpen": true}).then((value) {
      setState(() {
        _getToken();
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
          if (kDebugMode) {
            print("user device fcm Token is  $userToken");
          }
          //send push notification to user
          String body =
              "Mwiriwe neza ${widget.name}, ubu ngubu wemerewe gukora ibizamini byose ntankomyi kuko wamaze kwishyura.\n Murakoze mukomeze kwiga neza";
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
        .then((value) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("uid", isEqualTo: docId)
          .get();

      List<DocumentSnapshot> documents = querySnapshot.docs;
      for (DocumentSnapshot doc in documents) {
        // Delete each document that matches the user's UID
        await doc.reference.delete();
      }
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
