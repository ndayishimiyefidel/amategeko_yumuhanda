import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:amategeko/backend/apis/db_connection.dart';
import 'package:amategeko/enume/models/user_model.dart';
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
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  final String? referralCode;

  const SignUp({Key? key, this.referralCode}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  bool isRegistered = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  String name = "", phoneNumber = "", password = "";

  late SharedPreferences preferences;
  bool isloading = false;
  final userRole = "User";
  String? deviceId;

  @override
  void initState() {
    super.initState();
    _messaging.getToken().then((value) {
      fcmToken = value;
    });

    retrieveDeviceId();
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
    if (kIsWeb) {}
    deviceId = await DeviceIdManager.getDeviceId();
    if (kDebugMode) {
      print("Device ID: $deviceId");
    }
  }

  String generateUniqueUid() {
    // Create a unique user ID using a timestamp and a random number
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final int randomNum = (timestamp ~/ 1000) + Random().nextInt(9999);
    return '$timestamp$randomNum';
  }

  Future<void> _registerUser() async {
    print("device Ids:$deviceId");
    // if (deviceId!.isNotEmpty || deviceId != "") {
    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isloading = true;
        });

        final deviceValidationUrl = API.validate;
        final registrationUrl = API.signUp;
        final String uid = generateUniqueUid();

        // Device validation
        if (kIsWeb) {
          int dateF = DateTime.now().millisecondsSinceEpoch;

          User userModel = User(
              uid: uid,
              createdAt: dateF.toString(),
              password: password.toString().trim(),
              role: userRole,
              phone: phoneNumber.toString().trim(),
              name: name.trim(),
              referralCode: "",
              state: 1,
              deviceId: deviceId != null ? deviceId.toString() : "",
              fcmToken: fcmToken != null ? fcmToken.toString() : "");

          try {
            final registrationResponse = await http.post(
              Uri.parse(registrationUrl),
              body: userModel.toJson(),
            );

            if (registrationResponse.statusCode == 200) {
              final registrationResult = jsonDecode(registrationResponse.body);
              print("REg Error: $registrationResult ");

              if (registrationResult['registered'] == true) {
                // Registration successful
                preferences = await SharedPreferences.getInstance();
                await preferences.setString("uid", uid);
                await preferences.setString("name", name);
                await preferences.setString(
                    "phone", phoneNumber.toString().trim());
                await preferences.setString("role", userRole);

                if (fcmToken != null) {
                  await preferences.setString("fcmToken", fcmToken!);
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      currentuserid: uid,
                      userRole: userRole,
                    ),
                  ),
                );
              } else {
                Fluttertoast.showToast(
                    textColor: Colors.red,
                    fontSize: 18,
                    msg:
                        registrationResult['message'] ?? "Registration Failed");
              }
            } else {
              Fluttertoast.showToast(
                  textColor: Colors.red,
                  fontSize: 18,
                  msg: "Failed to connect to registration api");
            }
          } catch (registrationError) {
            print("Registration Error: $registrationError");
            // Handle registration API call error
          }
        } else {
          try {
            final deviceValidationResponse = await http.post(
              Uri.parse(deviceValidationUrl),
              body: {"deviceId": deviceId, "phone": phoneNumber},
            );

            if (deviceValidationResponse.statusCode == 200) {
              final deviceValidationResult =
                  json.decode(deviceValidationResponse.body);
              print("REg w:$deviceValidationResult ");

              if (deviceValidationResult['success'] == false) {
                // Continue with user registration
                int dateF = DateTime.now().millisecondsSinceEpoch;

                User userModel = User(
                    uid: uid,
                    createdAt: dateF.toString(),
                    password: password.toString().trim(),
                    role: userRole,
                    phone: phoneNumber.toString().trim(),
                    name: name.trim(),
                    referralCode: "",
                    state: 1,
                    deviceId: deviceId.toString(),
                    fcmToken: fcmToken != null ? fcmToken.toString() : "");

                try {
                  final registrationResponse = await http.post(
                    Uri.parse(registrationUrl),
                    body: userModel.toJson(),
                  );

                  if (registrationResponse.statusCode == 200) {
                    final registrationResult =
                        jsonDecode(registrationResponse.body);
                    print("REg Error: $registrationResult ");

                    if (registrationResult['registered'] == true) {
                      // Registration successful
                      preferences = await SharedPreferences.getInstance();
                      await preferences.setString("uid", uid);
                      await preferences.setString("name", name);
                      await preferences.setString(
                          "phone", phoneNumber.toString().trim());
                      await preferences.setString("role", userRole);

                      if (fcmToken != null) {
                        await preferences.setString("fcmToken", fcmToken!);
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            currentuserid: uid,
                            userRole: userRole,
                          ),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(
                          textColor: Colors.red,
                          fontSize: 18,
                          msg: registrationResult['message'] ??
                              "Registration Failed");
                    }
                  } else {
                    Fluttertoast.showToast(
                        textColor: Colors.red,
                        fontSize: 18,
                        msg: "Failed to connect to registration api");
                  }
                } catch (registrationError) {
                  print("Registration Error: $registrationError");
                  // Handle registration API call error
                }
              } else {
                Fluttertoast.showToast(
                    textColor: Colors.red,
                    fontSize: 18,
                    msg: deviceValidationResult['message'] ??
                        "Device Already registered in the app, please contact the administrator");
              }
            } else {
              Fluttertoast.showToast(
                  textColor: Colors.red,
                  fontSize: 18,
                  msg: "Failed to connect to API");
            }
          } catch (deviceValidationError) {
            print("Device Validation Error: $deviceValidationError");
            // Handle device validation API call error
          }
        }

        setState(() {
          isloading = false;
        });
      }
    } catch (e) {
      // Handle exceptions here
      print("Error: $e");
      // You can show an error message or perform other error handling as needed
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
          key: _formKey,
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
                      hintText: "Andika Nimero ya Telefoni yawe",
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
                      hintText: "Andika Nimero ya Telephone Yawe",
                      icon: Icon(
                        Icons.phone,
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
