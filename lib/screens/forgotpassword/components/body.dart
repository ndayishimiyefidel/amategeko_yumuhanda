import '../../../services/auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../Login/login_screen.dart';
import '../../../widgets/ProgressWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amategeko/screens/Signup/signup_screen.dart';
import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/Login/components/background.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  late SharedPreferences preferences;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  TextEditingController emailEditingController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;
  String emailAddress = "";

  @override
  void initState() {
    super.initState();
    _messaging.getToken().then((value) {
      fcmToken = value;
    });
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
                "REQUEST PASSWORD RESET LINK",
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
                  textInputAction: TextInputAction.done,
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
                      requestResetLink();
                    },
                    child: const Text(
                      "REQUEST RESET",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Already have an Account ? ",
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
                      "Sign In",
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

  void requestResetLink() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      preferences = await SharedPreferences.getInstance();


      await _firestore
          .collection('Users')
          .where('email', isEqualTo: emailAddress)
          .get()
          .then((value) async {
        if (value.size == 1) {
          _authService.forgotPassword(emailAddress).then((value) {
            setState(() {
              isLoading = false;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text(
                        "Reset Password Link sent successfully to your email,please check it",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.of(context).pop();
                              _formkey.currentState!.reset();
                              emailEditingController.clear();
                            },
                            child: const Text("Ok"))
                      ],
                    );
                  });
            });
          });
        } else {
          setState(() {
            isLoading = false;

            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                      "Email does not exist, please double check your email and try again",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.of(context).pop();
                            _formkey.currentState!.reset();
                            emailEditingController.clear();
                          },
                          child: const Text("Close"))
                    ],
                  );
                });
          });
        }
      });
    }
  }
}
