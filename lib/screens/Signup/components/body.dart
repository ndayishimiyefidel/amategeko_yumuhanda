import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/text_field_container.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import '../../HomeScreen.dart';
import '../../Login/login_screen.dart';
import '../../Signup/components/background.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
  final userRole = "User";

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;

    _messaging.getToken().then((value) {
      fcmToken = value;
    });
  }

  void _registerUser() async {
    print("your fcm token is $fcmToken");
    if (_formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      preferences = await SharedPreferences.getInstance();
      var firebaseUser = FirebaseAuth.instance.currentUser;

      //BEFORE CREATING A NEW ACCOUNT MAKE SURE THE DEVICE IS ALREADY REGISTERED YET.

      final QuerySnapshot checkToken = await FirebaseFirestore.instance
          .collection("Users")
          .where("fcmToken", isEqualTo: fcmToken)
          .get();
      final List<DocumentSnapshot> document = checkToken.docs;
      if (document.isEmpty) {
        await _auth
            .createUserWithEmailAndPassword(
                email: emailAddress.toString().trim(),
                password: password.toString().trim())
            .then((auth) {
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
              "role": userRole,
              "fcmToken": fcmToken
            });
            final currentuser = firebaseUser;
            await preferences.setString("uid", currentuser!.uid);
            await preferences.setString("name", name.toString().trim());
            await preferences.setString("photo", defaultPhotoUrl);
            await preferences.setString("phone", phoneNumber.trim());
            await preferences.setString("role", userRole.toString().trim());
            await preferences.setString("email", currentuser.email.toString());
          } else {
            //get user detail for current user
            await preferences.setString("uid", documents[0]["uid"]);
            await preferences.setString("name", documents[0]["name"]);
            await preferences.setString("photo", documents[0]["photoUrl"]);
            await preferences.setString("phone", documents[0]["phone"]);
            await preferences.setString("role", documents[0]["role"]);
            await preferences.setString("email", documents[0]["email"]);
            setState(() {
              isloading = false;
            });
            Fluttertoast.showToast(
                msg:
                    "Account with this credentials is already created or this device is already in use");
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
                "Your device is already registered,Contact administraor for help");
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
                      hintText: "Andika amazina yawe..",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: emailEditingController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      emailAddress = val;
                      print(emailAddress);
                    },
                    validator: (emailValue) {
                      if (emailValue!.isEmpty) {
                        return 'This field is mandatory';
                      }
                      String p =
                          "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
                      RegExp regExp = new RegExp(p);

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
                      hintText: "Andika imeli yawe...",
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
                      hintText: "Andika Telefoni yawe...",
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
                    decoration: InputDecoration(
                      hintText: "Ongera wandike telefoni..",
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
                  width: size.width * 0.7,
                  height: size.height * 0.07,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor),
                      onPressed: () {
                        _registerUser();
                      },
                      child: const Text(
                        "Iyandikishe",
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
                Row(
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
                              return LoginScreen();
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
                ),
              ]),
        ),
      ),
    );
  }
}
