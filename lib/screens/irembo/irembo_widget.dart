import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth.dart';

class IremboUsersList extends StatefulWidget {
  // final String secondaryText;
  final String name, time, userId, myPhone, identity, myAddress;

  const IremboUsersList(
      {super.key,
      required this.name,
      required this.time,
      required this.identity,
      required this.userId,
      required this.myPhone,
      required this.myAddress});

  @override
  _IremboUsersListState createState() => _IremboUsersListState();
}

class _IremboUsersListState extends State<IremboUsersList> {
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
      onTap: () {},
      child: Container(
        height: 150,
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Name: ${widget.name}"),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("Phone: ${widget.myPhone}"),
                                      const SizedBox(
                                        width: 60,
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          bool hasBeenCalled =
                                              await _hasUserBeenCalled();
                                          if (!hasBeenCalled) {
                                            bool? confirmed =
                                                await _showCallConfirmationDialog(
                                                    context);
                                            if (confirmed == true) {
                                              await FlutterPhoneDirectCaller
                                                  .callNumber(widget.myPhone);
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
                                                  .callNumber(widget.myPhone);
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
                                            final callColor = hasBeenCalled
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
                                  "ID: ${widget.identity}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  "Akarere: ${widget.myAddress}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic),
                                ),
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
                              AuthService().deleteIremboUser(widget.userId);
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
