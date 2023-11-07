// ignore_for_file: use_build_context_synchronously

import 'package:amategeko/utils/generate_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/apis/db_connection.dart';
import '../screens/ambassador/view_referrals.dart';

class ChatUsersList extends StatefulWidget {
  // final String secondaryText;
  final String name, role, time, userId, phone, password;
  final String? referralCode;
  final String? quizCode, deviceId;

  const ChatUsersList(
      {super.key,
      this.referralCode,
      required this.name,
      required this.time,
      required this.userId,
      required this.phone,
      required this.password,
      required this.role,
      this.quizCode,
      this.deviceId});

  @override
  State createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  late SharedPreferences preferences;
  bool isLoading = false;
  bool hasBeenCalled = false;
  bool isDeleting = false;
  String? deleteMessage;

  Future<bool> _hasUserBeenCalled() async {
    preferences = await SharedPreferences.getInstance();
    hasBeenCalled = preferences.getBool('called_${widget.userId}') ?? false;
    return hasBeenCalled;
  }

  Future<void> _setUserCalled() async {
    preferences = await SharedPreferences.getInstance();
    preferences.setBool("called_${widget.userId}", true);
  }

  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
  }

  Future<bool?> _showCallConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: hasBeenCalled != true
              ? const Text("Call Confirmation")
              : const Text("Call Confirmation Again"),
          content: hasBeenCalled != true
              ? const Text("Are you sure you want to call this person?")
              : const Text(
                  "Are you sure you want to call this person again?",
                  style: TextStyle(color: Colors.brown),
                ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Call"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to update the call status for a user in Firestore
  Future<void> _setUserCalledStatus(bool called) async {
    try {
      await firestore
          .collection('Users')
          .doc(widget.userId)
          // ignore: avoid_print
          .update({'called': called}).then((value) => {print("Updated")});
    } catch (e) {
      // ignore: avoid_print
      print("Error updating user's call status: $e");
      // Handle the error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    int timestamp = int.parse(widget.time);
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var dateTimeFormat = DateFormat('dd/MM/yyyy, hh:mm a').format(date);
    return InkWell(
      splashColor: Colors.brown,
      onTap: () {
        if (widget.role == "Admin" || widget.role == "Ambassador") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ViewReferrals(
              referralCode: widget.referralCode.toString(),
              refUid: widget.userId,
            );
          }));
        }
      },
      child: Card(
        margin: EdgeInsets.all(8), // Add margin for spacing
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.name),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(widget.phone),
                      const SizedBox(width: 60),
                      (widget.quizCode == "nocode")
                          ? const SizedBox()
                          : IconButton(
                              onPressed: () async {
                                bool hasBeenCalled = await _hasUserBeenCalled();
                                bool? confirmed =
                                    await _showCallConfirmationDialog(context);
                                if (confirmed == true) {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      widget.phone);
                                  if (!hasBeenCalled) {
                                    await _setUserCalled();
                                  } else {
                                    await _setUserCalledStatus(true);
                                  }
                                  setState(
                                      () {}); // Update the state to reflect the change
                                }
                              },
                              icon: FutureBuilder<bool>(
                                future: _hasUserBeenCalled(),
                                builder: (context, snapshot) {
                                  final hasBeenCalled = snapshot.data ?? false;
                                  final callColor = hasBeenCalled
                                      ? Colors.grey
                                      : Colors.blueAccent;
                                  return Icon(
                                    Icons.call,
                                    size: 30,
                                    color: callColor,
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                  Text(
                    "password: ${widget.password}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  (widget.quizCode != "nocode")
                      ? Text(
                          "Quiz Code: ${widget.quizCode}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueAccent,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : SizedBox(),
                  (widget.deviceId != "nodevice")
                      ? Text(
                          "Device Id: ${widget.deviceId}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.redAccent,
                            fontStyle: FontStyle.normal,
                          ),
                        )
                      : SizedBox(),
                  Text(
                    "Joined date: $dateTimeFormat",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              color: Colors.red,
              onPressed: () async {
                final url = API.deleteUser;
                GenerateUser.deleteUserCode(context, widget.userId, url,
                    widget.name, "deleted successfully!");
              },
              icon: const Icon(
                Icons.delete,
                size: 30,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
