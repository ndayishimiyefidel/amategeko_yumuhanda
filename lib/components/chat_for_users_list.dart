import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/ambassador/view_referrals.dart';
import '../services/auth.dart';

class ChatUsersList extends StatefulWidget {
  // final String secondaryText;
  final String name, role, image, time, userId, email, phone, password;
  final referralCode;
  final String? quizCode, deviceId;

  const ChatUsersList(
      {super.key,
      this.referralCode,
      required this.name,
      required this.image,
      required this.time,
      required this.email,
      required this.userId,
      required this.phone,
      required this.password,
      required this.role,
      this.quizCode,
      this.deviceId});

  @override
  _ChatUsersListState createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late String currentUserPhone;
  String? userRole;
  late String phoneNumber;
  late SharedPreferences preferences;
  bool isLoading = false;
  bool hasBeenCalled = false;

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
    getCurrUser();
  }

  getCurrUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentuserphoto = preferences.getString("photo")!;
      currentUserPhone = preferences.getString("phone")!;
      userRole = preferences.getString("role")!;
    });
  }

  Future<bool?> _showCallConfirmationDialog(BuildContext context) async {
    // bool hasBeenCalled = await _hasUserBeenCalled();
    // if (hasBeenCalled) {
    //   // If user has already been called, show a message or perform any other action
    //   // as needed and return null to prevent the call.
    //   return null;
    // }
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
          .update({'called': called}).then((value) => {print("Updated")});
    } catch (e) {
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
        if (userRole == "Admin" && widget.role == "Ambassador") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ViewReferrals(
              referralCode: widget.referralCode,
              refUid: widget.userId,
            );
          }));
        }
      },
      child: Container(
        height: 150,
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  // Stack(
                  //   children: [
                  //     CircleAvatar(
                  //       backgroundImage: NetworkImage(widget.image),
                  //       maxRadius: 30,
                  //     ),
                  //     Positioned(
                  //       left: 0,
                  //       top: 30,
                  //       child: StatusIndicator(
                  //         uid: widget.userId,
                  //         screen: "chatListScreen",
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   width: 16,
                  // ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(widget.name),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(widget.phone),
                                      const SizedBox(
                                        width: 80,
                                      ),
                                      widget.quizCode != "nocode"
                                          ? SizedBox()
                                          : IconButton(
                                              onPressed: () async {
                                                //     //indirect phone call
                                                //     // launchUrl('tel://${widget.phone}' as Uri);
                                                //     //direct phone call
                                                bool hasBeenCalled =
                                                    await _hasUserBeenCalled();
                                                if (!hasBeenCalled) {
                                                  bool? confirmed =
                                                      await _showCallConfirmationDialog(
                                                          context);
                                                  if (confirmed == true) {
                                                    await FlutterPhoneDirectCaller
                                                        .callNumber(
                                                            widget.phone);
                                                    await _setUserCalled(); // Set the user as called after the call is made
                                                    setState(
                                                        () {}); // Update the state to reflect the change
                                                  }
                                                } else {
                                                  // User has been called before, show a message or perform any other action
                                                  // as needed.
                                                  bool? confirmed =
                                                      await _showCallConfirmationDialog(
                                                          context);
                                                  if (confirmed == true) {
                                                    await FlutterPhoneDirectCaller
                                                        .callNumber(
                                                            widget.phone);
                                                    await _setUserCalledStatus(
                                                        true); // Set the user as called after the call is made
                                                    setState(
                                                        () {}); // Update the state to reflect the change
                                                  }
                                                }
                                              },
                                              icon: FutureBuilder<bool>(
                                                future: _hasUserBeenCalled(),
                                                // Update FutureBuilder here
                                                builder: (context, snapshot) {
                                                  final hasBeenCalled =
                                                      snapshot.data ?? false;
                                                  final callColor =
                                                      hasBeenCalled
                                                          ? Colors.grey
                                                          : Colors.blueAccent;
                                                  return Icon(
                                                    Icons.call,
                                                    size: 30,
                                                    color: callColor,
                                                    weight: 30,
                                                  );
                                                },
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                Text(
                                  widget.email,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  "password: ${widget.password}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic),
                                ),
                                widget.role != "User"
                                    ? Text(
                                        "User Type: ${widget.role}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                            fontStyle: FontStyle.italic),
                                      )
                                    : const SizedBox(),
                                widget.quizCode == "nocode"
                                    ? const SizedBox()
                                    : Text(
                                        "Quiz Code: ${widget.quizCode}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blueAccent,
                                            fontStyle: FontStyle.italic),
                                      ),
                                Text(
                                  "Device Id: ${widget.deviceId ?? "no device"}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.redAccent,
                                      fontStyle: FontStyle.normal),
                                ),
                                // widget.referralCode.isEmpty
                                //     ? const SizedBox()
                                //     : Expanded(
                                //         child: Text(
                                //           "${widget.referralCode}",
                                //           style: TextStyle(
                                //               fontSize: 14,
                                //               color: Colors.grey.shade500,
                                //               fontStyle: FontStyle.italic),
                                //         ),
                                //       ),
                                Text(
                                  "Joined date: $dateTimeFormat",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            color: Colors.red,
                            onPressed: () async {
                              AuthService().deleteUser(widget.userId);
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
