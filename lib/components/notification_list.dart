import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/apis/db_connection.dart';
import '../utils/generate_code.dart';
import '../widgets/fcmWidget.dart';

class UsersNotificationList extends StatefulWidget {
  final String name;

  // final String secondaryText;
  // final String image;
  final String time;

  // final String quizId;
  final String userId;
  final String phone;
  final String code, docId;
  final bool? isQuiz;
  final String? endTime;

  const UsersNotificationList({
    super.key,
    required this.name,
    required this.time,
    required this.userId,
    required this.phone,
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
  late String fcmToken;

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
    if (!mounted) return;
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentUserPhone = preferences.getString("phone")!;
      userRole = preferences.getString("role");
      fcmToken = preferences.getString("fcmToken")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print("time stamp :${widget.time}");
    int timestamp = int.parse(widget.time);
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var dateTimeFormat =
        DateFormat('dd/MM/yyyy, hh:mm a').format(date); // 12/31/2000, 10:00 PM
    int timestamp1 = (widget.endTime == null || widget.endTime!.isEmpty)
        ? 1692260163454
        : int.parse(widget.endTime.toString());
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
                            userRole == "Admin" ? widget.name : "",
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
        // _generateCode(widget.docId);
        String generatedCode = randomNumeric(6);
        GenerateUser.generateCodeAndNotify(context, widget.docId, generatedCode,
                widget.name, "Generate code is $generatedCode of ", 1)
            .then((value) => {_getToken(), _isLoading = false});
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

    final url = API.setLimitTime;

    if (pickedDate != null && pickedDate != _selectedDate) {
      if (!mounted) return;
      setState(() {
        _selectedDate = pickedDate;
        GenerateUser.setCodeLimit(
                context,
                widget.docId,
                url,
                "Gushyiraho igihe uzarangira kwiga byakunze",
                _selectedDate!.millisecondsSinceEpoch.toString())
            .then((value) => _isLoading = false);
        //_updateEndTimeInFirestore();
      });
    }
  }

  //get fcm token
  _getToken() async {
    String body =
        "Mwiriwe neza ${widget.name}, ubu ngubu wemerewe gukora ibizamini byose ntankomyi kuko wamaze kwishyura.\n Murakoze mukomeze kwiga neza";
    String notificationTitle = "Quiz App Generating Code";
    sendPushMessage(fcmToken, body, notificationTitle);
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
        if (!mounted) return;
        setState(() {
          _isLoading = true;
        });
        final delUrl = API.deleteCode;
        GenerateUser.deleteUserCode(context, widget.docId, delUrl, widget.name,
                ",Code have been deleted succesfully")
            .then((value) => _isLoading = false);
        // deleteDoc(widget.docId);
      },
    );
  }
}
