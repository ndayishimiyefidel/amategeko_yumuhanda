import 'package:amategeko/backend/apis/db_connection.dart';
import 'package:amategeko/utils/constants.dart';
import 'package:amategeko/utils/generate_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class IremboUsersList extends StatefulWidget {
  // final String secondaryText;
  final String name, time, userId, myPhone, identity, myAddress, type;
  final String? code, category;

  const IremboUsersList(
      {super.key,
      required this.name,
      required this.time,
      required this.identity,
      required this.userId,
      required this.myPhone,
      required this.myAddress,
      this.code,
      required this.type,
      this.category});

  @override
  State createState() => _IremboUsersListState();
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

  @override
  void initState() {
    super.initState();
    getCurrUser();
  }

  getCurrUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentUserPhone = preferences.getString("phone")!;
      userRole = preferences.getString("role")!;
    });
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
  // Future<void> _setUserCalledStatus(bool called) async {
  //   try {
  //     await firestore
  //         .collection('Users')
  //         .doc(widget.userId)
  //         // ignore: avoid_print
  //         .update({'called': called}).then((value) => {print("Updated")});
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error updating user's call status: $e");
  //     }
  //     // Handle the error if needed
  //   }
  // }

  void _copyToClipboard(String textToCopy) {
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$textToCopy copied to clipboard')),
    );
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
        height: 200,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Name: ${widget.name}"),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Phone: ${widget.myPhone}"),
                                      IconButton(
                                        onPressed: () {
                                          _copyToClipboard(widget.myPhone);
                                        },
                                        icon: const Icon(
                                          Icons.copy,
                                          size: 25,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          bool hasBeenCalled =
                                              await _hasUserBeenCalled();
                                          if (!hasBeenCalled) {
                                            bool? confirmed =
                                                // ignore: use_build_context_synchronously
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
                                                // ignore: use_build_context_synchronously
                                                await _showCallConfirmationDialog(
                                                    context);
                                            if (confirmed == true) {
                                              await FlutterPhoneDirectCaller
                                                  .callNumber(widget.myPhone);
                                              // await _setUserCalledStatus(
                                              //     true); // Set the user as called after the call is made
                                              // setState(
                                              //     () {}); // Update the state to reflect the change
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ID: ${widget.identity}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _copyToClipboard(widget.identity);
                                      },
                                      icon: const Icon(
                                        Icons.copy,
                                        size: 25,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                widget.type == "Permit"
                                    ? Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Code: ${widget.code}"),
                                            IconButton(
                                              onPressed: () {
                                                _copyToClipboard(
                                                    widget.code.toString());
                                              },
                                              icon: const Icon(
                                                Icons.copy,
                                                size: 25,
                                                color: kPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                widget.type == "Permit"
                                    ? Text(
                                        "Category: ${widget.category}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                            fontStyle: FontStyle.italic),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                          IconButton(
                            color: Colors.red,
                            onPressed: () async {
                              //AuthService().deleteIremboUser(widget.userId);
                              final url = API.deleteIremboUser;
                              GenerateUser.deleteUserCode(
                                  context,
                                  widget.userId,
                                  url,
                                  widget.name,
                                  "deleted successfully!");
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
