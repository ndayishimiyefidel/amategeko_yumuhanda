import 'package:amategeko/widgets/fcmWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/notification_list.dart';
import '../../utils/constants.dart';

class UserNotification extends StatefulWidget {
  const UserNotification({super.key});

  @override
 State createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {

  // List allUsers = [];
  var allUsersList=[];
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  late String quizTitle;
  late SharedPreferences preferences;
  late String photo,email;
  String? adminPhone;
  late String phone;
  bool isloading=false;
  String userToken = "";
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  initState() {
_messaging.getToken().then((value) {
    });
    getCurrUserId();
     //check code//get login data
    requestPermission(); //request permission
    loadFCM(); //load fcm
    listenFCM(); //list fcm
    getToken(); //get admin token
    FirebaseMessaging.instance;
     super.initState();
  }
    getToken() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .where("role", isEqualTo: "Admin")
        .get()
        .then((value) {
      if (value.size == 1) {
        Map<String, dynamic> adminData = value.docs.first.data();
        userToken = adminData["fcmToken"];
        adminPhone = adminData["phone"];
      }
    });
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentuserphoto = preferences.getString("photo")!;
      userRole = preferences.getString("role")!;
      phoneNumber = preferences.getString("phone")!;
      email = preferences.getString("email")!;
    });
  }


Future<void> requestCode(String userToken, String currentUserId,
      String senderName, String title) async {
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName naho nimero ya telefoni ni  Namaze kwishyura amafaranga 1500 kuri 0788659575 yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    //make sure that request is not already sent
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("isQuiz", isEqualTo: true)
        .get()
        .then((value) {
      if (value.size != 0) {
        setState(() {
          isloading = false;
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
          "email": email,
          "phone": phone,
          "photoUrl": photo,
          "quizId": "gM34wj99547j4895",
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
            isloading = false;
            Size size = MediaQuery.of(context).size;
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                        "Ubusabe bwawe bwakiriwe neza, Kugirango ubone kode ikwinjiza muri exam banza wishyure."),
                    actions: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: size.width * 0.7,
                        height: size.height * 0.07,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor),
                            onPressed: () async {
                              //direct phone call
                              await FlutterPhoneDirectCaller.callNumber(
                                  "*182*8*1*329494*1500#");
                            },
                            child: const Text(
                              "Ishyura 1500 Rwf.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
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
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Quiz-codes")
                  .where("userId",
                      isEqualTo: currentuserid)
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
                          : Center( 
                            child: Column(children: [
                              SizedBox(height: size.height*0.1,),
                              const Text(
                                "Nta kode ufite ifungura exam saba code",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(height: size.height*0.02,),
                              Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              width: size.width * 0.7,
                              height: size.height * 0.06,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child:
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimaryColor),
                                      onPressed: () {
                                        requestCode(userToken, currentuserid.toString(), currentusername.toString(), "Exams");
                                      },
                                      child: const Text(
                                        "Saba Code ifungura exam",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              ),
                            ),
                          
                            ],),
                          )
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
                        // image: snapshot.data!.docs[index]["photoUrl"],
                        time: snapshot.data!.docs[index]["createdAt"],
                        email: snapshot.data!.docs[index]["email"],
                        userId: snapshot.data!.docs[index]["userId"],
                        phone: snapshot.data!.docs[index]["phone"],
                        // quizId: snapshot.data!.docs[index]["quizId"],
                        quizTitle: snapshot.data!.docs[index]["quizTitle"],
                        code: snapshot.data!.docs[index]["code"],
                        isQuiz: snapshot.data!.docs[index]["isQuiz"],
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
