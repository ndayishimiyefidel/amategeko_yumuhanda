import 'dart:async';

import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/HomeScreen.dart';
import 'package:amategeko/screens/Login/components/background.dart';
import 'package:amategeko/screens/Signup/signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool _passwordVisible;
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
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      //_interstitialAd = null;
    } else {
      print('InterstitialAd is not loaded yet.');
    }
  }

  @override
  void initState() {
    super.initState();
    loadInterstitialAd();

    // Start the timer to show the interstitial ad every 4 minutes
    interstitialTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      showInterstitialAd();
    });

    _passwordVisible = false;
    _messaging.getToken().then((value) {
      fcmToken = value;
      print("My fcm token is: $fcmToken");
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
      print(currentuserid);
    });
  }

  Future<void> retrieveDeviceId() async {
    deviceId = await DeviceIdManager.getDeviceId();
    print("Device ID: $deviceId");
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
              // Padding(
              //   padding: const EdgeInsets.only(left: 20),
              //   child: CheckboxListTile(
              //     title: Text("Remember Me"),
              //     value: checkedValue,
              //     onChanged: (newValue) {
              //       setState(() {
              //         checkedValue = newValue!;
              //       });
              //     },
              //     controlAffinity:
              //         ListTileControlAffinity.leading, //  <-- leading Checkbox
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(right: 45, bottom: 20),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: <Widget>[
              //       const Text(
              //         "Wibagiwe numero ya terefone? ",
              //         style: TextStyle(color: kPrimaryColor),
              //       ),
              //       GestureDetector(
              //         onTap: () {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) {
              //                 return const ForgotScreen();
              //               },
              //             ),
              //           );
              //         },
              //         child: const Text(
              //           "Gusubiramo",
              //           style: TextStyle(
              //             color: Colors.red,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //       )
              //     ],
              //   ),
              // ),
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
                    )
                  : const SizedBox(),
              AdBannerWidget(),
              SizedBox(
                height: size.height * 0.06,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      preferences = await SharedPreferences.getInstance();
      var user = FirebaseAuth.instance.currentUser;

      showInterstitialAd();

      // await _auth
      //     .signInWithEmailAndPassword(
      //         email: emailAddress.toString().trim(), password: password.trim())
      //     .then((auth) {
      //   user = auth.user;
      // }).catchError((err) {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text(err.message)));
      // });

      // if (user != null) {
      //   FirebaseFirestore.instance
      //       .collection("Users")
      //       .doc(user!.uid)
      //       .update({"state": 1});

      FirebaseFirestore.instance
          .collection("Users")
          .where("password", isEqualTo: password)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.size > 0) {
          var firstDoc = querySnapshot.docs.first;
          if (firstDoc != null && firstDoc.data() != null) {
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
              Navigator.push(context, route);
            } else {
              if (data.containsKey("deviceId") &&
                  data["deviceId"] == deviceId) {
                await preferences.setString("uid", data["uid"]);
                await preferences.setString("name", data["name"]);
                await preferences.setString("photo", data["photoUrl"]);
                await preferences.setString("email", data["email"]);
                await preferences.setString("role", data["role"]);
                await preferences.setString("phone", data["phone"]);
                print("db device id");
                print(data["deviceId"]);

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
                Navigator.push(context, route);
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
