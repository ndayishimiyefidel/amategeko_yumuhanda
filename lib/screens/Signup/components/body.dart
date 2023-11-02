import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/text_field_container.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import '../../HomeScreen.dart';
import '../../Login/components/check_deviceid.dart';
import '../../Login/login_screen.dart';
import '../../Signup/components/background.dart';

class SignUp extends StatefulWidget {
  final String? referralCode;

  const SignUp({Key? key, this.referralCode}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final String defaultPhotoUrl =
      "https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg";
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  bool isRegistered = false;

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  String name = "", phoneNumber = "", emailAddress = "", password = "";

  late SharedPreferences preferences;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloading = false;
  final userRole = "User";
  String? deviceId;
  String? deviceEmail;

  List<dynamic> accounts = [];


 

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print("Referral code");
      print(widget.referralCode);
    }
    _messaging.getToken().then((value) {
      fcmToken = value;
    });
    //get device id
    retrieveDeviceId().then((_) {
      // The device ID retrieval is completed, so now call checkLoginState()
      if (isRegistered == true) {
        // If already registered, navigate to the login page
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      }
    });

    // Check if user is registered
  }

  String? currentuserid;

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
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

  String sanitizeName(String name) {
    // Remove spaces and convert to lowercase
    return name.replaceAll(' ', '').toLowerCase();
  }

  String generateRandomEmail(String name) {
    // Sanitize the name
    String sanitized = sanitizeName(name);
    // Generate a random number for email uniqueness
    int randomNum = Random().nextInt(9999);

    // Create a random email using sanitized name and random number
    return '$sanitized$randomNum@gmail.com';
  }

  void _registerUser() async {
    if (deviceId == "") {
      Fluttertoast.showToast(msg: "Error no device Id");
    } else {
      if (_formkey.currentState!.validate()) {
        setState(() {
          isloading = true;
        });
        preferences = await SharedPreferences.getInstance();
        var firebaseUser = FirebaseAuth.instance.currentUser;
        //
        //showInterstitialAd();
        final QuerySnapshot checkToken = await FirebaseFirestore.instance
            .collection("Users")
            .where("deviceId", isEqualTo: deviceId)
            .where("password", isEqualTo: password.toString().trim())
            .get();
        final List<DocumentSnapshot> document = checkToken.docs;
        // Generate a random email based on the user's name
        String randomEmail =
            generateRandomEmail(nameEditingController.text.toString().trim());

        if (kDebugMode) {
          print(randomEmail);
        }

        if (document.isEmpty) {
          await _auth
              .createUserWithEmailAndPassword(
                  email: randomEmail, password: password.toString().trim())
              .then((auth) async {
            firebaseUser = auth.user;
          }).catchError((err) {
            setState(() {
              isloading = false;
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(err.message)));
          });

          if (firebaseUser != null) {
            final QuerySnapshot result = await FirebaseFirestore.instance
                .collection("Users")
                .where("uid", isEqualTo: firebaseUser!.uid)
                .where("phone",isEqualTo: phoneNumber.trim())
                .where("password",isEqualTo:password.trim())
                .get();

            final List<DocumentSnapshot> documents = result.docs;
            if (documents.isEmpty) {
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc(firebaseUser!.uid)
                  .set({
                "uid": firebaseUser!.uid,
                "userEmail": firebaseUser!.email,
                "name": name.toString().trim(),
                "phone": phoneNumber.trim(),
                "password": password.trim(),
                "photoUrl": defaultPhotoUrl,
                "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
                "state": 1,
                "role": userRole,
                "fcmToken": fcmToken,
                "deviceId": deviceId,
                "referralCode": widget.referralCode //1.emmy
              });
              setState(() {
                isRegistered = true;
              });
              final currentuser = firebaseUser;
              await preferences.setString("uid", currentuser!.uid);
              await preferences.setString("name", name.toString().trim());
              await preferences.setString("photo", defaultPhotoUrl);
              await preferences.setString("phone", phoneNumber.trim());
              await preferences.setString("role", userRole.toString().trim());
              await preferences.setString(
                  "email", currentuser.email.toString());
            } else {
              //get user detail for current user
              await preferences.setString("uid", documents[0]["uid"]);
              await preferences.setString("name", documents[0]["name"]);
              await preferences.setString("photo", documents[0]["photoUrl"]);
              await preferences.setString("phone", documents[0]["phone"]);
              await preferences.setString("role", documents[0]["role"]);
              await preferences.setString("email", documents[0]["userEmail"]);
              setState(() {
                isloading = false;
              });
              Fluttertoast.showToast(
                  msg: "Account with this credentials is already created");
            }

            setState(() {
              isloading = false;
            });
            Route route = MaterialPageRoute(
                builder: (c) => HomeScreen(
                      currentuserid: firebaseUser!.uid,
                      userRole: userRole,
                    ));
            // ignore: use_build_context_synchronously
            Navigator.push(context, route);
          } else {
            setState(() {
              isloading = false;
            });
            Fluttertoast.showToast(msg: "Sign up Failed");
          }
        } else {
          ///device already exists

          setState(() {
            isloading = false;
          });
          Fluttertoast.showToast(
              textColor: Colors.red,
              fontSize: 18,
              msg:
                  "Device Already registered in the app, please contact the administrator");
        }
      }
    }
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
          key: _formkey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: size.height * 0.1),
                const Text(
                  "IYANDIKISHE Nk'UMUNTU MUSHYA USHAKA KWIGA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.03),
                SvgPicture.asset(
                  "assets/icons/signup.svg",
                  height: size.height * 0.35,
                ),
                SizedBox(height: size.height * 0.03),
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
                SizedBox(height: size.height * 0.03),
                TextFieldContainer(
                  child: TextFormField(
                    controller: nameEditingController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      name = val;
                      if (kDebugMode) {
                        print(name);
                      }
                    },
                    validator: (nameValue) {
                      if (nameValue!.isEmpty) {
                        return 'This field is mandatory';
                      }
                      if (nameValue.length < 3) {
                        return 'name must be at least 3+ characters ';
                      }
                      const String p = "^[a-zA-Z\\s]+";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(nameValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid name';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: kPrimaryColor,
                      ),
                      hintText: "Andika amazina yawe",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // TextFieldContainer(
                //   child: TextFormField(
                //     controller: emailEditingController,
                //     keyboardType: TextInputType.emailAddress,
                //     textInputAction: TextInputAction.next,
                //     onChanged: (val) {
                //       emailAddress = val;
                //       print(emailAddress);
                //     },
                //     validator: (emailValue) {
                //       if (emailValue!.isEmpty) {
                //         return 'This field is mandatory';
                //       }
                //       String p =
                //           "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
                //       RegExp regExp = new RegExp(p);
                //
                //       if (regExp.hasMatch(emailValue)) {
                //         // So, the email is valid
                //         return null;
                //       }
                //
                //       return 'This is not a valid email';
                //     },
                //     cursorColor: kPrimaryColor,
                //     decoration: const InputDecoration(
                //       icon: Icon(
                //         Icons.email,
                //         color: kPrimaryColor,
                //       ),
                //       hintText: "Andika imeli yawe",
                //       border: InputBorder.none,
                //     ),
                //   ),
                // ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: phoneNumberEditingController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      phoneNumber = val;
                      if (kDebugMode) {
                        print(phoneNumber);
                      }
                    },
                    validator: (phoneValue) {
                      if (phoneValue!.isEmpty) {
                        return 'This field is mandatory';
                      }

                      const String p = "^07[2,389]\\d{7}";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(phoneValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid phone number';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.phone_outlined,
                        color: kPrimaryColor,
                      ),
                      hintText: "Andika Telefoni yawe",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: passwordEditingController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      password = val;
                    },
                    // validator: (pwValue) {
                    //   if (pwValue!.isEmpty) {
                    //     return 'This field is mandatory';
                    //   }
                    //   if (pwValue.length < 6) {
                    //     return 'Password must be at least 6 characters';
                    //   }
                    //
                    //   return null;
                    // },
                    validator: (pwValue) {
                      if (pwValue!.isEmpty) {
                        return 'This field is mandatory';
                      }

                      const String p = "^07[2,389]\\d{7}";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(pwValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid phone number';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      hintText: "Andika telephone nanone",
                      icon: Icon(
                        Icons.phone,
                        color: kPrimaryColor,
                      ),
                      // suffixIcon: IconButton(
                      //   icon: Icon(
                      //     _passwordVisible
                      //         ? Icons.visibility_off
                      //         : Icons.visibility,
                      //     color: kPrimaryColor,
                      //   ),
                      //   onPressed: () {
                      //     setState(() {
                      //       _passwordVisible = !_passwordVisible;
                      //     });
                      //   },
                      // ),
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
                        if (phoneNumber == password) {
                          _registerUser();
                        } else {
                          Fluttertoast.showToast(
                              msg: "Phone number must be the same!");
                        }
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
                isloading
                    ? oldcircularprogress()
                    : Container(
                        child: null,
                      ),
                currentuserid == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Usanzwe ufite konti ? ",
                            style: TextStyle(color: kPrimaryColor),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const LoginScreen();
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              "Injira",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.1),
                        ],
                      )
                    : const SizedBox(),
              ]),
        ),
      ),
    );
  }
}
