import 'dart:io';

import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/HomeScreen.dart';
import 'package:amategeko/screens/Login/components/background.dart';
import 'package:amategeko/screens/Signup/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import '../../forgotpassword/forgot_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late SharedPreferences preferences;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  String emailAddress = "", password = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool _passwordVisible;
  bool isloading = false;

  String? deviceId;

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  retieveDeviceId() async {
    //get device id
    deviceId = await _getId();
    // print("deveice id is:$deviceId");
  }

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _messaging.getToken().then((value) {
      fcmToken = value;
      print("My fcm token is: $fcmToken");
    });
  }

  Future<void> signupNavigator() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SignUpScreen();
        },
      ),
    );
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
              SizedBox(height: size.height * 0.03),
              const Text(
                "KWINJIRA MURI APULIKASIYO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
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
                      "Niba ufite ikibazo mugukoesha iyi apulikasiyo kandi ukaba ukeneye ubufasha wabariza kuri izi inforumasiyo zikurikira:",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    const Text(
                      "Telephone:0788659575/0728877442",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    const Text(
                      "Imeri:maitrealexis001@gmail.com",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.03),
              TextFieldContainer(
                child: TextFormField(
                  controller: emailEditingController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (val) {
                    emailAddress = val;
                  },
                  validator: (emailValue) {
                    if (emailValue!.isEmpty) {
                      return 'This field is mandatory';
                    }
                    String p =
                        "[a-zA-Z0-9+._%-+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
                    RegExp regExp = RegExp(p);

                    if (regExp.hasMatch(emailValue)) {
                      // So, the email is valid
                      return null;
                    }

                    return 'This is not a valid email';
                  },
                  cursorColor: kPrimaryColor,
                  decoration: const InputDecoration(
                    icon: Icon(
                      Icons.email,
                      color: kPrimaryColor,
                    ),
                    hintText: "imeri yawe",
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextFieldContainer(
                child: TextFormField(
                  controller: passwordEditingController,
                  obscureText: !_passwordVisible,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: (val) {
                    password = val;
                  },
                  validator: (pwValue) {
                    if (pwValue!.isEmpty) {
                      return 'This field is mandatory';
                    }
                    if (pwValue.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                  cursorColor: kPrimaryColor,
                  decoration: InputDecoration(
                    hintText: "Andika telefoni yawe...",
                    icon: const Icon(
                      Icons.lock_outlined,
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
              SizedBox(
                height: size.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      "Wibagiwe numero ya terefone? ",
                      style: TextStyle(color: kPrimaryColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const ForgotScreen();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Gusubiramo",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: size.width * 0.7,
                height: size.height * 0.07,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor),
                    onPressed: () {
                      loginUser();
                    },
                    child: const Text(
                      "Injira",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              isloading
                  ? oldcircularprogress()
                  : Container(
                      child: null,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Ntugira Konti ?   ",
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
                            return SignUpScreen();
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
              ),
              SizedBox(
                height: size.height * 0.04,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      preferences = await SharedPreferences.getInstance();

      var user = FirebaseAuth.instance.currentUser;

      await _auth
          .signInWithEmailAndPassword(
              email: emailAddress.toString().trim(), password: password.trim())
          .then((auth) {
        user = auth.user;
      }).catchError((err) {
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err.message)));
      });

      if (user != null) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(user!.uid)
            .update({"state": 1});

        FirebaseFirestore.instance
            .collection("Users")
            .doc(user!.uid)
            .get()
            .then((datasnapshot) async {
          String userRole = datasnapshot.data()!["role"];

          ///make sure the user role is not admininstrator
          /// no way to check which device is using
          if (datasnapshot.data()!['role'] == "Admin") {
            await preferences.setString("uid", datasnapshot.data()!["uid"]);
            await preferences.setString("name", datasnapshot.data()!["name"]);
            await preferences.setString(
                "photo", datasnapshot.data()!["photoUrl"]);
            await preferences.setString("email", datasnapshot.data()!["email"]);
            await preferences.setString("role", datasnapshot.data()!["role"]);
            await preferences.setString("phone", datasnapshot.data()!["phone"]);

            setState(() {
              isloading = false;
            });
            Route route = MaterialPageRoute(
                builder: (c) => HomeScreen(
                      currentuserid: user!.uid,
                      userRole: userRole,
                    ));
            Navigator.push(context, route);
          } else {
            ///tracking user role
            if (datasnapshot.data()!["deviceId"] == deviceId) {
              await preferences.setString("uid", datasnapshot.data()!["uid"]);
              await preferences.setString("name", datasnapshot.data()!["name"]);
              await preferences.setString(
                  "photo", datasnapshot.data()!["photoUrl"]);
              await preferences.setString(
                  "email", datasnapshot.data()!["email"]);
              await preferences.setString("role", datasnapshot.data()!["role"]);
              await preferences.setString(
                  "phone", datasnapshot.data()!["phone"]);

              setState(() {
                isloading = false;
              });
              // Navigator.of(context).pop(context);
              Route route = MaterialPageRoute(
                  builder: (c) => HomeScreen(
                        currentuserid: user!.uid,
                        userRole: userRole,
                      ));
              Navigator.push(context, route);
            } else {
              setState(() {
                isloading = false;
              });
              Fluttertoast.showToast(
                  msg:
                      "Not registered on this device, please use device you have registered in before.",
                  textColor: Colors.red,
                  fontSize: 18);
            }
          }
        });
      } else {
        setState(() {
          isloading = false;
        });
        Fluttertoast.showToast(
            msg: "Login Failed,No such user matching with your credentials",
            textColor: Colors.red,
            fontSize: 18);
      }
    }
  }
}
