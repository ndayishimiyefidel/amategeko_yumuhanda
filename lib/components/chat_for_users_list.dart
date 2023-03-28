import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth.dart';
import '../widgets/StatusIndicator.dart';

class ChatUsersList extends StatefulWidget {
  final String name;

  // final String secondaryText;
  final String image;
  final String time;
  final bool isMessageRead;
  final String userId;
  final String email;
  final String phone;
  final String password;

  const ChatUsersList(
      {super.key,
      required this.name,
      required this.image,
      required this.time,
      required this.isMessageRead,
      required this.email,
      required this.userId,
      required this.phone,
      required this.password});

  @override
  _ChatUsersListState createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late String currentUserPhone;
  late String userRole;
  late String phoneNumber;
  late SharedPreferences preferences;

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
      currentuserphoto = preferences.getString("photo")!;
      currentUserPhone = preferences.getString("phone")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return Chat(
        //     receiverId: widget.userId,
        //     receiverAvatar: widget.image,
        //     receiverName: widget.name,
        //     currUserId: currentuserid,
        //     currUserName: currentusername,
        //     currUserAvatar: currentuserphoto,
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
                      Positioned(
                        left: 0,
                        top: 30,
                        child: StatusIndicator(
                          uid: widget.userId,
                          screen: "chatListScreen",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(widget.name),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(widget.phone),
                                const SizedBox(
                                  height: 6,
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
                              ],
                            ),
                          ),
                          IconButton(
                            color: Colors.red,
                            onPressed: () async {
                              await AuthService()
                                  .deleteUser(widget.email, widget.password);
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
