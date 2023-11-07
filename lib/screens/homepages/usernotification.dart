import 'dart:convert';
import 'package:amategeko/widgets/fcmWidget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../backend/apis/db_connection.dart';
import '../../components/notification_list.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as http;

class UserNotification extends StatefulWidget {
  const UserNotification({super.key});

  @override
  State createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {
  // List allUsers = [];
  var allUsersList = [];
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  late String quizTitle;
  late SharedPreferences preferences;
  late String photo, email;
  String? adminPhone;
  late String phone;
  bool isloading = false;
  String userToken = "";
  bool hasCode = false;

  @override
  initState() {
    getCurrUserData();
    requestPermission(); //request permission
    loadFCM(); //load fcm
    listenFCM(); //list fcm
    fetchById();
    getToken(); //get admin token
    FirebaseMessaging.instance;
    super.initState();
  }

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      phone = preferences.getString("phone")!;
      userToken = preferences.getString("fcmToken")!;
    });

    checkQuizCode(currentuserid.toString());
  }

  Future<void> checkQuizCode(String userId) async {
    final url = API.checkCode;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        if (data['success'] == true) {
          if (data['hasCode'] == true) {
            if (!mounted) return;
            setState(() {
              hasCode = true;
            });
          } else {
            if (!mounted) return;
            setState(() {
              hasCode = false;
            });
          }
        } else {
          // Handle other error cases
        }
      } else {
        // Handle HTTP request errors
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      // You can show an error message or perform other error handling as needed
    }
  }

  Future<void> getToken() async {
    final url = API.getToken; // Replace with your PHP script URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final adminData = data['data'];
          userToken = adminData['fcmToken'];
          adminPhone = adminData['phone'];
          print(adminPhone);
        } else {
          // Handle the case when there is no admin or other errors
        }
      } else {
        // Handle HTTP request errors
        print("failed to connect to server");
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
    }
  }

  Future<void> requestCode(
      String userId, String quizId, String senderName, String title) async {
    final url = API.requestCode;
    final sabaCodeUrl = API.sabaCode;
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName naho nimero ya telefoni ni  Namaze kwishyura amafaranga 1500 kuri 0788659575 yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': currentuserid},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print('Response Body: $data');
        if (data['success'] == true) {
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
        } else {
          try {
            final res = await http.post(
              Uri.parse(sabaCodeUrl),
              body: {
                'userId': currentuserid.toString(),
                'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
                "phone": phone.toString(),
                "name": currentusername
              },
            );
            print(res.body);
            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              print('Response Body: $data');
              if (data['requestSent'] == true) {
                //handle if not sent
                sendPushMessage(userToken, body, notificationTitle);
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
                              child: const Text("Okay"))
                        ],
                      );
                    });
              } else {
                Fluttertoast.showToast(
                  msg: "Faild to request code",
                  textColor: Colors.red,
                  fontSize: 14,
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: "Faild to connect to api",
                textColor: Colors.red,
                fontSize: 14,
              );
            }
          } catch (e) {
            // Handle exceptions
            print("Error: $e");
            // You can show an error message or perform other error handling as needed
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Faild to connect to api",
          textColor: Colors.red,
          fontSize: 14,
        );
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      // You can show an error message or perform other error handling as needed
    }
  }

  Future<void> fetchById() async {
    final userId = "?userId=$currentuserid";
    final apiUrl = API.fetchById + userId;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // Append the new data to the existing list
          setState(() {
            allUsersList.addAll(List<Map<String, dynamic>>.from(data['data']));
            isloading = false;
          });
        } else {
          print("Failed to execute query");
        }
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: !isloading
            ? Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (allUsersList.isEmpty)
                      SizedBox(
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
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: size.height * 0.1,
                                        ),
                                        const Text(
                                          "Nta kode ufite ifungura exam saba code",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.height * 0.02,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          width: size.width * 0.7,
                                          height: size.height * 0.06,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      kPrimaryColor),
                                              onPressed: () {
                                                requestCode(
                                                    userToken,
                                                    currentuserid.toString(),
                                                    currentusername.toString(),
                                                    "Exams");
                                              },
                                              child: const Text(
                                                "Saba Code ifungura exam",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                      )
                    else
                      Column(
                        children: [
                          ListView.builder(
                            padding: const EdgeInsets.only(top: 16),
                            itemCount: allUsersList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final data = allUsersList[index];
                              return UsersNotificationList(
                                name: data["name"] ?? '',
                                time: data["createdAt"],
                                userId: data["userId"],
                                phone: data["phone"] ?? '',
                                code: data["code"],
                                endTime: data["endTime"] ?? "1684242113231",
                                docId: data['id'],
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
