import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/text_field_container.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import '../../Login/components/check_deviceid.dart';
import '../../Signup/components/background.dart';
import '../ambassador.dart';

class SignUpAmbassador extends StatefulWidget {
  const SignUpAmbassador({super.key});

  @override
  _SignUpAmbassadorState createState() => _SignUpAmbassadorState();
}

class _SignUpAmbassadorState extends State<SignUpAmbassador> {
  final String defaultPhotoUrl =
      "https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg";
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  String name = "", phoneNumber = "", emailAddress = "", password = "";

  late SharedPreferences preferences;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloading = false;
  late bool _passwordVisible;
  String userRole = "";
  String? deviceId;
  String? deviceEmail;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _messaging.getToken().then((value) {
      fcmToken = value;
    });
    //get device id
    retrieveDeviceId();
  }

  Future<void> retrieveDeviceId() async {
    deviceId = await DeviceIdManager.getDeviceId();
    print("Device ID: $deviceId");
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

  String? referralCode;

  Future<String> generateReferralCode() async {
    // Generate a random string
    final randomString = DateTime.now().millisecondsSinceEpoch.toString();

    // Hash the random string using MD5 algorithm
    final bytes = utf8.encode(randomString);
    final md5Hash = md5.convert(bytes);
    final referralCode = md5Hash.toString();

    return referralCode;
  }

  String? selectedUserRole;

  void _registerUser() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });

      if (selectedUserRole == "Ambassador") {
        referralCode = await generateReferralCode();
      }
      preferences = await SharedPreferences.getInstance();
      var firebaseUser = FirebaseAuth.instance.currentUser;

      final QuerySnapshot checkToken = await FirebaseFirestore.instance
          .collection("Users")
          .where("deviceId", isEqualTo: deviceId)
          .where("password", isEqualTo: password.toString().trim())
          .get();
      final List<DocumentSnapshot> document = checkToken.docs;
      // Generate a random email based on the user's name
      String randomEmail =
          generateRandomEmail(nameEditingController.text.toString().trim());

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
              .get();

          final List<DocumentSnapshot> documents = result.docs;
          if (documents.isEmpty) {
            FirebaseFirestore.instance
                .collection("Users")
                .doc(firebaseUser!.uid)
                .set({
              "uid": firebaseUser!.uid,
              "email": firebaseUser!.email,
              "name": name.toString().trim(),
              "phone": phoneNumber.trim(),
              "password": password.trim(),
              "photoUrl": defaultPhotoUrl,
              "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
              "state": 1,
              "role": selectedUserRole,
              "fcmToken": fcmToken,
              "deviceId": deviceId,
              "referralCode": referralCode
            });
          } else {
            //get user detail for current user
            setState(() {
              isloading = false;
            });
            Fluttertoast.showToast(
                msg: "Account with this credentials is already created");
          }

          setState(() {
            isloading = false;
          });
          Fluttertoast.showToast(msg: "User created successfully");
          Route route =
              MaterialPageRoute(builder: (c) => const AllAmbassadors());
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
                SizedBox(height: size.height * 0.05),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Text(
                    "REGISTER AMBASSADOR OR WORKER",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                SvgPicture.asset(
                  "assets/icons/signup.svg",
                  height: size.height * 0.35,
                ),
                SizedBox(height: size.height * 0.03),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Ambassador',
                            groupValue: selectedUserRole,
                            onChanged: (value) {
                              setState(() {
                                selectedUserRole = value;
                              });
                            },
                          ),
                          const Text('Ambassador'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Caller',
                            groupValue: selectedUserRole,
                            onChanged: (value) {
                              setState(() {
                                selectedUserRole = value;
                              });
                            },
                          ),
                          const Text('Caller'),
                        ],
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
                      print(name);
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
                      hintText: "Andika amazina ye",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: phoneNumberEditingController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      phoneNumber = val;
                      print(phoneNumber);
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
                      hintText: "Andika Telefoni ye",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: passwordEditingController,
                    obscureText: !_passwordVisible,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      password = val;
                    },
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
                    decoration: InputDecoration(
                      hintText: "Andika telephone nanone",
                      icon: const Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: size.width * 0.4,
                  height: size.height * 0.07,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
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
                        "Register",
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
                SizedBox(height: size.height * 0.05),
              ]),
        ),
      ),
    );
  }
}
