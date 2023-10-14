import 'dart:io';

import 'package:amategeko/screens/groups/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/text_field_container.dart';
import '../../services/auth.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/MainDrawer.dart';
import '../../widgets/fcmWidget.dart';
import '../homepages/notificationtab.dart';

class GroupList extends StatefulWidget {
  const GroupList({Key? key}) : super(key: key);

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<dynamic>? groupStream;
  bool isLoading = false;
  DatabaseService databaseService = DatabaseService();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  AuthService authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  //shared preferences
  late SharedPreferences preferences;
  late String? currentuserid;
  late String currentusername;
  String userRole = "";
  late String photo;
  late String phone;
  String userToken = "";
  String? adminPhone;
  late String email;

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      photo = preferences.getString("photo")!;
      phone = preferences.getString("phone")!;
      email = preferences.getString("email")!;
    });
  }

  getToken() async {
    //delete quiz
    await FirebaseFirestore.instance
        .collection("Users")
        .where("role", isEqualTo: "Admin")
        .get()
        .then((value) {
      if (value.size == 1) {
        Map<String, dynamic> adminData = value.docs.first.data();
        userToken = adminData["fcmToken"];
        adminPhone = adminData["phone"];
        print("Admin Token is  $userToken");
      }
    });
  }

  @override
  void initState() {
    getCurrUserData();

    _messaging.getToken().then((value) {
      print(value);
    });
    getToken();
    databaseService.getGroupList().then((value) {
      setState(() {
        groupStream = value;
      });
    });
    super.initState();
  }

  Widget documentsList() {
    return StreamBuilder(
      stream: groupStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return groupStream == null
                  ? const Center(
                      child: Text(
                        "No Document Available right now ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return FileTile(
                          docId:
                              snapshot.data.docs[index].reference.id.toString(),
                          linkUrl: snapshot.data.docs[index]
                              .data()["linkUrl"]
                              .toString(),
                          groupName: snapshot.data.docs[index]
                              .data()["groupName"]
                              .toString(),
                          groupType: snapshot.data.docs[index]
                              .data()["groupType"]
                              .toString(),
                          userRole: userRole,
                          currentUserId: currentuserid.toString(),
                          groupPrice: snapshot.data.docs[index]
                              .data()["groupPrice"]
                              .toString(),
                          userToken: userToken,
                          adminPhone: adminPhone.toString(),
                          senderName: currentusername,
                          userPhone: phone,
                          email: email,
                          photoUrl: photo,
                          groupId: snapshot.data.docs[index]
                              .data()["quizId"]
                              .toString(),
                        );
                      },
                    );
            }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
        elevation: 0,
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: const Text(
          "Group List",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.25,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Notifications(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 25,
              ),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
      body: documentsList(),
      floatingActionButton: userRole == "Admin"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateGroup();
                    },
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class FileTile extends StatefulWidget {
  final String docId;
  final String linkUrl;
  final String groupName;
  final String groupType;
  final String groupPrice;
  final String userToken;
  final String adminPhone;
  final String senderName;
  final String userRole;
  final String currentUserId;
  final String userPhone;
  final String email;
  final String photoUrl;
  final String groupId;

  const FileTile({
    Key? key,
    required this.docId,
    required this.linkUrl,
    required this.groupName,
    required this.groupType,
    required this.userRole,
    required this.currentUserId,
    required this.groupPrice,
    required this.userToken,
    required this.adminPhone,
    required this.senderName,
    required this.userPhone,
    required this.email,
    required this.photoUrl,
    required this.groupId,
  }) : super(key: key);

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  bool _isLoading = false;
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: kPrimaryColor,
                width: size.width * 0.003,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: InkWell(
              onTap: () {},
              splashColor: kPrimaryColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            //removing overflow on row widget
                            child: Column(
                              children: [
                                Text(widget.groupName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.start),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                // Text(
                                //   "Group Category: ${widget.groupType}",
                                //   textAlign: TextAlign.start,
                                //   style: const TextStyle(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.normal,
                                //     color: Colors.blueGrey,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          widget.userRole == "Admin"
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    // _getEditIcon(),
                                    SizedBox(
                                      height: size.height * 0.03,
                                    ),
                                    _isLoading
                                        ? const CircularProgressIndicator()
                                        : Container(
                                            child: null,
                                          ),
                                    _getDeleteIcon(),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    _joinGroupIcon(),
                                    SizedBox(
                                      height: size.height * 0.03,
                                    ),
                                    _isLoading
                                        ? const CircularProgressIndicator()
                                        : Container(
                                            child: null,
                                          ),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _joinGroupIcon() {
    return GestureDetector(
      child: const Text(
        "Join",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      onTap: () {
        setState(() {
          _isLoading = true;
        });
        if (widget.groupType == "Facebook") {
          //join group automatically
          setState(() {
            _isLoading = false;
          });
          _launchURL(widget.linkUrl);
        } else {
          ///check whether you already have code.
          FirebaseFirestore.instance
              .collection("Quiz-codes")
              .where("userId", isEqualTo: widget.currentUserId)
              .where("isOpen", isEqualTo: true)
              .where("isQuiz", isEqualTo: false)
              .get()
              .then((value) {
            if (value.size == 1) {
              setState(() {
                _isLoading = false;
              });
              _launchURL(widget.linkUrl);
            } else {
              //show dialogue
              final TextEditingController codeController =
                  TextEditingController();
              String code = "";
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Column(
                        children: [
                          const Text(
                            "CODE VERIFICATION",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Kugirango ubashe kwinjira muri ${widget.groupName}group whatsapp icyo usabwa nukwishyura ${widget.groupPrice.isEmpty ? 1000 : widget.groupPrice}frw kuri  ${widget.adminPhone.isEmpty ? 0788659575 : widget.adminPhone} cyangwa kuri momo pay 329494 tugusobanurira amategeko y'umuhanda ndetse n'imitego ituma harabatsindwa kuberako batayimenye.",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      content: Form(
                        key: _formkey,
                        child: TextFieldContainer(
                          child: TextFormField(
                            autofocus: false,
                            maxLength: 6,
                            controller: codeController,
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              codeController.text = value!;
                            },
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              icon: Icon(
                                Icons.code_off_outlined,
                                color: kPrimaryColor,
                              ),
                              hintText: "Shyiramo code...",
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              code = val;
                            },
                            autovalidateMode: AutovalidateMode.disabled,
                            validator: (input) => input!.isEmpty
                                ? 'Kwinjira muri group bisaba kode'
                                : null,
                          ),
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor, elevation: 3),
                          onPressed: () async {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              checkValidCode(
                                widget.currentUserId,
                                code,
                                widget.groupId,
                              );
                            }
                          },
                          child: const Text(
                            "Injira group",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryLightColor,
                              elevation: 3),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            requestCode(widget.userToken, widget.currentUserId,
                                widget.senderName, widget.groupName);
                          },
                          child: const Text(
                            "Saba Kode",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.normal),
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
            }
          });
        }
      },
    );
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
        .collection("Groups")
        .doc(docId)
        .delete()
        .then((value) {
      setState(() {
        _isLoading = false;
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text("Group deleted successfully"),
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

  //check code

  Future<void> checkValidCode(
      String currentUserId, String code, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("code", isEqualTo: code)
        .where("isQuiz", isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print(doc.reference.id);
        FirebaseFirestore.instance
            .collection("Quiz-codes")
            .doc(doc.reference.id)
            .update({"isOpen": true}).then((value) {
          if (querySnapshot.size == 1) {
            //join group whatsapp
            setState(() {
              _isLoading = false;
              _launchURL(widget.linkUrl);
            });
          } else {
            setState(() {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text(
                          "Invalid code for this group code ,Double check and try again"),
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
          }
        });
      }
    });
  }

//request code
  Future<void> requestCode(String userToken, String currentUserId,
      String senderName, String title) async {
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName  naho nimero ya telefoni ni ${widget.userPhone} .\n  Namaze kwishyura amafaranga ${widget.groupPrice.isEmpty ? 1500 : widget.groupPrice} frw kuri nimero ${widget.adminPhone.isEmpty ? 0788659575 : widget.adminPhone} yo kwinjira muri group whatsapp.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Group Whatsapp Code";

    //make sure that request is not already sent
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("isQuiz", isEqualTo: false)
        .get()
        .then((value) {
      if (value.size == 1) {
        setState(() {
          _isLoading = false;
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
          "email": widget.email,
          "phone": widget.userPhone,
          "photoUrl": widget.photoUrl,
          "quizId": widget.groupId,
          "quizTitle": title,
          "code": "",
          "isQuiz": false,
          "isOpen": false,
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
        };
        FirebaseFirestore.instance
            .collection("Quiz-codes")
            .add(checkCode)
            .then((value) {
          //send push notification
          sendPushMessage(userToken, body, notificationTitle);
          setState(() {
            _isLoading = false;
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                        "Your request sent successfully, we will let you once your information is processed."),
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
    });
  }

  _launchURL(String url) async {
    if (Platform.isIOS) {
      setState(() {
        _isLoading = false;
      });
    } else {
      //web platform, android
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        setState(() {
          _isLoading = false;
        });
      } else {
        throw 'Could not launch $url';
      }
      setState(() {
        _isLoading = false;
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text("whatsapp not installed")));
      });
    }
  }
}
