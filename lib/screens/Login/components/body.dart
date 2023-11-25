import 'dart:async';
import 'dart:convert';

import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/HomeScreen.dart';
import 'package:amategeko/screens/Login/components/background.dart';
import 'package:amategeko/screens/Signup/signup_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../backend/apis/db_connection.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import 'check_deviceid.dart';
import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late SharedPreferences preferences;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  TextEditingController passwordEditingController = TextEditingController();
  String password = "";

  bool isLoading = false;
  String? deviceId;
  bool checkedValue = false;

  @override
  void initState() {
    super.initState();
    _messaging.getToken().then((value) {
      fcmToken = value;
      if (kDebugMode) {
        print("My fcm token is: $fcmToken");
      }
    });

    // Await the retrieveDeviceId() function here
    retrieveDeviceId();
    getCurrUserId();
  }

  String? currentuserid;

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      currentuserid = preferences.getString("uid");
      if (kDebugMode) {
        print(currentuserid);
      }
    });
  }

  Future<void> retrieveDeviceId() async {
    deviceId = await DeviceIdManager.getDeviceId();
    if (kDebugMode) {
      print("Device ID: $deviceId");
    }
  }

  Future<void> signupNavigator() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const SignUpScreen();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.1),
              const Text(
                "KWINJIRA MURI APULIKASIYO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.35,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ICYITONDERWA:",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    const Text(
                      "Niba ufite ikibazo mugukoesha iyi apulikasiyo kandi ukaba ukeneye ubufasha wahamagara kuri izi nimero zikurikira:",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.only(left: 62),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await FlutterPhoneDirectCaller.callNumber(
                                  "0788659575");
                            },
                            child: const Text(
                              "0788659575",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await FlutterPhoneDirectCaller.callNumber(
                                  "0728877442");
                            },
                            child: const Text(
                              "0728877442",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextFieldContainer(
                child: TextFormField(
                  controller: passwordEditingController,
                  keyboardType: TextInputType.number,
                  autocorrect: true,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (val) {
                    password = val;
                  },
                  validator: (pwValue) {
                    if (pwValue!.isEmpty) {
                      return 'This field is mandatory';
                    }
                    if (pwValue.length < 6) {
                      return 'phone must be at least 6 characters';
                    }

                    return null;
                  },
                  cursorColor: kPrimaryColor,
                  decoration: const InputDecoration(
                    hintText: "Andika nimero yawe",
                    icon: Icon(
                      Icons.call,
                      color: kPrimaryColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: size.width * 0.3,
                height: size.height * 0.06,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor),
                    onPressed: () {
                      loginUser();
                    },
                    child: const Text(
                      "Emeza",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              isLoading
                  ? oldcircularprogress()
                  : Container(
                      child: null,
                    ),
              currentuserid != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Niba uri mushya?   ",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const SignUpScreen();
                                },
                              ),
                            );
                          },
                          child: const Text(
                            "Iyandikishe",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    )
                  : const SizedBox(),
              SizedBox(
                height: size.height * 0.01,
              ),
              GestureDetector(
                onTap: () {
                  _launchURL(
                      "https://doc-hosting.flycricket.io/rwanda-traffic-rules-privacy-policy/4ffe9e57-7316-45d0-b5aa-7749fa65ea19/privacy");
                },
                child: const Text(
                  "Privacy Policy",
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              GestureDetector(
                onTap: () {
                  _launchURL(
                      "https://doc-hosting.flycricket.io/rwanda-traffic-rules-terms-of-use/a8f1833a-7c5c-4493-bdce-6184680f081c/terms");
                },
                child: const Text(
                  "Terms and condition of use",
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
              ),
              SizedBox(
                height: size.height * 0.06,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void loginUser() async {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        preferences = await SharedPreferences.getInstance();
        final loginUrl = API.login; // Set the URL to your login.php script

        final response = await http.post(
          Uri.parse(loginUrl),
          body: {
            'password': password.toString().trim(),
          },
        );

        if (response.statusCode == 200) {
          final loginResult = json.decode(response.body);
          print(loginResult);
          if (loginResult['success'] == true) {
            ///update fcm
            // Successful login
            final userData = loginResult;
            final String userRole = userData['role'];

            //update in db.

            print("Fcm Token :$fcmToken");

            try {
              final fcmTokenUrl = API.updateFcmToken;
              final response = await http.post(
                Uri.parse(fcmTokenUrl),
                body: {'docId': userData["uid"], 'fcmToken': fcmToken},
              );

              if (response.statusCode == 200) {
                // Your logic for a successful response
                final fcmResult = json.decode(response.body);
                if (fcmResult['success'] == true) {
                } else {}
              } else {
                print("Error: Failed to connect to api");
              }
            } catch (e) {
              print("Error: $e");
            }

            await preferences.setString("uid", userData["uid"]);
            await preferences.setString("name", userData["name"]);
            await preferences.setString("role", userData["role"]);
            await preferences.setString("phone", userData["phone"]);
            await preferences.setString("fcmToken", fcmToken!);

            setState(() {
              isLoading = false;
            });

            Route route = MaterialPageRoute(
              builder: (c) => HomeScreen(
                currentuserid: userData["uid"],
                userRole: userRole,
              ),
            );

            if (userRole == "Admin" ||
                userRole == "Ambassador" ||
                userRole == "Caller") {
              setState(() {
                Navigator.push(context, route);
              });
            } else {
              if (userData.containsKey("deviceId") &&
                  userData["deviceId"] != null) {
                final String userDeviceId = userData['deviceId'];
                if (userDeviceId == deviceId) {
                  setState(() {
                    Navigator.push(context, route);
                  });
                } else {
                  Fluttertoast.showToast(
                    msg:
                        "Ntabwo mwiyandikishije mukoreshe iyi telephone, nimukoreshe telephone mwakoresheje mwiyandikisha",
                    textColor: Colors.red,
                    fontSize: 14,
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg:
                      "Ntabwo kwinjira bishoboka ongera wiyandikishe ukanze ahanditse iyandikishe!",
                  textColor: Colors.red,
                  fontSize: 12,
                );
              }
            }
          } else {
            // Login failed
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
              msg: loginResult['message'] ?? "Ntabwo mwiyandikishe",
              textColor: Colors.red,
              fontSize: 18,
            );
          }
        } else {
          // Failed to connect to login API
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            textColor: Colors.red,
            fontSize: 18,
            msg: "Failed to connect to login API",
          );
        }
      }
    } catch (e) {
      // Handle exceptions here
      print("Login Error: $e");
      // You can show an error message or perform other error handling as needed
    }
  }

  // void loginUser() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     preferences = await SharedPreferences.getInstance();
  //     FirebaseFirestore.instance
  //         .collection("Users")
  //         .where("password", isEqualTo: password)
  //         .get()
  //         .then((QuerySnapshot querySnapshot) async {
  //       if (querySnapshot.size > 0) {
  //         var firstDoc = querySnapshot.docs.last;
  //         if (firstDoc.data() != null) {
  //           Map<String, dynamic> data = firstDoc.data() as Map<String, dynamic>;

  //           String userRole = data['role'];

  //           if (data.containsKey('role') &&
  //               (data['role'] == "Admin" ||
  //                   data['role'] == "Ambassador" ||
  //                   data['role'] == "Caller")) {
  //             await preferences.setString("uid", data["uid"]);
  //             await preferences.setString("name", data["name"]);
  //             await preferences.setString("photo", data["photoUrl"]);
  //             await preferences.setString("email", data["userEmail"]);
  //             await preferences.setString("role", data["role"]);
  //             await preferences.setString("phone", data["phone"]);

  //             setState(() {
  //               isLoading = false;
  //               isLoggedIn = true; // Update login state
  //             });
  //             preferences.setBool('isLoggedIn', isLoggedIn);
  //             Route route = MaterialPageRoute(
  //               builder: (c) => HomeScreen(
  //                 currentuserid: data["uid"],
  //                 userRole: userRole,
  //               ),
  //             );
  //             setState(() {
  //               Navigator.push(context, route);
  //             });
  //           } else {
  //             if (data.containsKey("deviceId") &&
  //                 data["deviceId"] == deviceId) {
  //               await preferences.setString("uid", data["uid"]);
  //               await preferences.setString("name", data["name"]);
  //               await preferences.setString("photo", data["photoUrl"]);
  //               await preferences.setString("email", data["userEmail"]);
  //               await preferences.setString("role", data["role"]);
  //               await preferences.setString("phone", data["phone"]);
  //               if (kDebugMode) {
  //                 print("db device id");
  //                 print(data["deviceId"]);
  //               }

  //               setState(() {
  //                 isLoading = false;
  //                 isLoggedIn = true; // Update login state
  //               });
  //               preferences.setBool('isLoggedIn', isLoggedIn);
  //               Route route = MaterialPageRoute(
  //                 builder: (c) => HomeScreen(
  //                   currentuserid: data["uid"],
  //                   userRole: userRole,
  //                 ),
  //               );
  //               setState(() {
  //                 Navigator.push(context, route);
  //               });
  //             } else {
  //               setState(() {
  //                 isLoading = false;
  //               });
  //               Fluttertoast.showToast(
  //                 msg:
  //                     "Not registered on this device, please use the device you have registered before.",
  //                 textColor: Colors.red,
  //                 fontSize: 18,
  //               );
  //             }
  //           }
  //         }
  //       } else {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         Fluttertoast.showToast(
  //           msg: "Login Failed, No such user matching with your credentials",
  //           textColor: Colors.red,
  //           fontSize: 18,
  //         );
  //       }
  //     });
  //   }
  // }
}
