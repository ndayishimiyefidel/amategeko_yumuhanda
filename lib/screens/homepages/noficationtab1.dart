import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/notification_list.dart';
import '../../utils/constants.dart';

class NotificationTab1 extends StatefulWidget {
  const NotificationTab1({super.key});

  @override
  _NotificationTab1State createState() => _NotificationTab1State();
}

class _NotificationTab1State extends State<NotificationTab1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List allUsers = [];
  var allUsersList;
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  late String quizTitle;
  late SharedPreferences preferences;

  @override
  initState() {
    super.initState();
    getCurrUserId();
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentuserphoto = preferences.getString("photo")!;
      userRole = preferences.getString("role")!;
      phoneNumber = preferences.getString("phone")!;
      print("user role is $userRole");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Quiz-codes")
                  .where("code", isNotEqualTo: "")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                    child: Center(
                      child: userRole == "Admin"
                          ? const Text(
                              "No available notification right now",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            )
                          : const Text(
                              "There is no notifications for you",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                    child: const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                        kPrimaryColor,
                      )),
                    ),
                  );
                } else {
                  snapshot.data!.docs
                      .removeWhere((i) => i["userId"] == currentuserid);
                  allUsersList = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return UsersNotificationList(
                        name: snapshot.data!.docs[index]["name"],
                        image: snapshot.data!.docs[index]["photoUrl"],
                        time: snapshot.data!.docs[index]["createdAt"],
                        email: snapshot.data!.docs[index]["email"],
                        userId: snapshot.data!.docs[index]["userId"],
                        phone: snapshot.data!.docs[index]["phone"],
                        quizId: snapshot.data!.docs[index]["quizId"],
                        quizTitle: snapshot.data!.docs[index]["quizTitle"],
                        code: snapshot.data!.docs[index]["code"],
                        docId:
                            snapshot.data!.docs[index].reference.id.toString(),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}