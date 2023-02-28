import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../forgotpassword/forgot_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amategeko/screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amategeko/screens/Signup/signup_screen.dart';
import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/Login/components/background.dart';

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
                "LOGIN PAGE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.35,
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
                    hintText: "Your Email",
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
                    hintText: "Your Phone...",
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
                      "Forgot Password ?  ",
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
                        "Reset",
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
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
                    "Don’t have an Account ? ",
                    style: TextStyle(color: kPrimaryColor),
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
                      "Sign Up",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
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
            if (datasnapshot.data()!["fcmToken"] == fcmToken) {
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