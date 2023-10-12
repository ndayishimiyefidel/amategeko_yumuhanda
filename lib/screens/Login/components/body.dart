import 'dart:async';

import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/HomeScreen.dart';
import 'package:amategeko/screens/Login/components/background.dart';
import 'package:amategeko/screens/Signup/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import '../../../widgets/banner_widget.dart';
import 'check_deviceid.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late SharedPreferences preferences;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  String emailAddress = "";
  String password = "";

  bool isLoading = false;
  String? deviceId;
  bool checkedValue = false;
  bool isLoggedIn = false; // Track login state
  InterstitialAd? _interstitialAd;
  Timer? interstitialTimer;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2864387622629553/2309153588',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      if (kDebugMode) {
        print('InterstitialAd is not loaded yet.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadInterstitialAd();

    // Start the timer to show the interstitial ad every 4 minutes
    interstitialTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      showInterstitialAd();
    });
    _messaging.getToken().then((value) {
      fcmToken = value;
      if (kDebugMode) {
        print("My fcm token is: $fcmToken");
      }
    });

    // Await the retrieveDeviceId() function here
    retrieveDeviceId().then((_) {
      // The device ID retrieval is completed, so now call checkLoginState()
      checkLoginState();
    });
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
          return SignUpScreen();
        },
      ),
    );
  }

  void checkLoginState() async {
    preferences = await SharedPreferences.getInstance();
    isLoggedIn = preferences.getBool('isLoggedIn') ?? false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd!.dispose();
    interstitialTimer?.cancel();
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
                    hintText: "Andika telefoni yawe",
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
                height: size.height * 0.01,
              ),
              const AdBannerWidget(),
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      preferences = await SharedPreferences.getInstance();
      showInterstitialAd();
      FirebaseFirestore.instance
          .collection("Users")
          .where("password", isEqualTo: password)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.size > 0) {
          var firstDoc = querySnapshot.docs.first;
          if (firstDoc.data() != null) {
            Map<String, dynamic> data = firstDoc.data() as Map<String, dynamic>;

            String userRole = data['role'];

            if (data.containsKey('role') &&
                (data['role'] == "Admin" ||
                    data['role'] == "Ambassador" ||
                    data['role'] == "Caller")) {
              await preferences.setString("uid", data["uid"]);
              await preferences.setString("name", data["name"]);
              await preferences.setString("photo", data["photoUrl"]);
              await preferences.setString("email", data["email"]);
              await preferences.setString("role", data["role"]);
              await preferences.setString("phone", data["phone"]);

              setState(() {
                isLoading = false;
                isLoggedIn = true; // Update login state
              });
              preferences.setBool('isLoggedIn', isLoggedIn);
              Route route = MaterialPageRoute(
                builder: (c) => HomeScreen(
                  currentuserid: data["uid"],
                  userRole: userRole,
                ),
              );
              setState(() {
                Navigator.push(context, route);
              });
            } else {
              if (data.containsKey("deviceId") &&
                  data["deviceId"] == deviceId) {
                await preferences.setString("uid", data["uid"]);
                await preferences.setString("name", data["name"]);
                await preferences.setString("photo", data["photoUrl"]);
                await preferences.setString("email", data["email"]);
                await preferences.setString("role", data["role"]);
                await preferences.setString("phone", data["phone"]);
                if (kDebugMode) {
                  print("db device id");
                                  print(data["deviceId"]);

                }

                setState(() {
                  isLoading = false;
                  isLoggedIn = true; // Update login state
                });
                preferences.setBool('isLoggedIn', isLoggedIn);
                Route route = MaterialPageRoute(
                  builder: (c) => HomeScreen(
                    currentuserid: data["uid"],
                    userRole: userRole,
                  ),
                );
                setState(() {
                  Navigator.push(context, route);
                });
              } else {
                setState(() {
                  isLoading = false;
                });
                Fluttertoast.showToast(
                  msg:
                      "Not registered on this device, please use the device you have registered before.",
                  textColor: Colors.red,
                  fontSize: 18,
                );
              }
            }
          }
        } else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: "Login Failed, No such user matching with your credentials",
            textColor: Colors.red,
            fontSize: 18,
          );
        }
      });
    }
  }
}
