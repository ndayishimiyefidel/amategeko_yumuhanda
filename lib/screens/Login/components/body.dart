import 'dart:async';
import 'dart:convert';
import 'check_deviceid.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../ads/ad_manager.dart'; // Import ad manager
import '../../../backend/apis/db_connection.dart';
import 'package:rwanda_traffic_rules/screens/HomeScreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwanda_traffic_rules/screens/Signup/signup_screen.dart';
import 'package:rwanda_traffic_rules/screens/Login/components/background.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);
  @override
  State createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  late SharedPreferences preferences;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  TextEditingController passwordEditingController = TextEditingController();
  String password = "";

  bool isLoading = false;
  String? deviceId;
  bool checkedValue = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });

    _messaging.getToken().then((value) {
      fcmToken = value;
      if (kDebugMode) {
        print("My fcm token is: $fcmToken");
      }
    });
    // Ads are initialized in main.dart

    getCurrUserId();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
    AdManager.dispose();
  }

  void showRewardedAd() {
    bool adShown = AdManager.showRewardedAd(context: 'user_login');

    if (!adShown) {
      //print('Rewarded Ad is not loaded yet.');
    }
  }

  String? currentuserid;

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      currentuserid = preferences.getString("uid");
      if (kDebugMode) {
        print(currentuserid);
      }
      retrieveDeviceId();
    });
  }

  Future<void> retrieveDeviceId() async {
    if (kIsWeb) {
      // Collect browser information for fingerprint
      // final userAgent = html.window.navigator.userAgent;
      // final screenResolution =
      //     '${html.window.screen?.width}x${html.window.screen?.height}';
      // final platform = html.window.navigator.platform;

      // // Combine the info to create a unique fingerprint
      // deviceId = _generateFingerprint(userAgent, screenResolution, platform!);

      // if (kDebugMode) {
      //   print("Browser Fingerprint: $deviceId");
      // }
    } else {
      // Use device ID for mobile platforms
      deviceId = await DeviceIdManager.getDeviceId();
      if (kDebugMode) {
        print("Device ID: $deviceId");
      }
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: size.height * 0.08),

                  // Header Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.all(20),
                        //   decoration: BoxDecoration(
                        //     color: kPrimaryColor.withValues(alpha: 0.1),
                        //     shape: BoxShape.circle,
                        //   ),
                        //   child: SvgPicture.asset(
                        //     "assets/icons/login.svg",
                        //     height: 80,
                        //     colorFilter: ColorFilter.mode(
                        //       kPrimaryColor,
                        //       BlendMode.srcIn,
                        //     ),
                        //   ),
                        // ),

                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "assets/icons/login.svg",
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.2,
                            fit: BoxFit.contain,
                            // colorFilter: ColorFilter.mode(
                            //   kPrimaryColor,
                            //   BlendMode.srcIn,
                            // ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.005),
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          "Sign in to continue learning",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Support Information Card
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.support_agent,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Need Help?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "If you're having trouble using this app and need assistance, please call one of our support numbers:",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    color: kPrimaryColor, size: 16),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    await FlutterPhoneDirectCaller.callNumber(
                                        "0788659575");
                                  },
                                  child: Text(
                                    "0788659575",
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    color: kPrimaryColor, size: 16),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    await FlutterPhoneDirectCaller.callNumber(
                                        "0728877442");
                                  },
                                  child: Text(
                                    "0728877442",
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  // Login Form
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Phone Number Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
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
                                  return 'Phone number is required';
                                }
                                if (pwValue.length < 6) {
                                  return 'Phone number must be at least 6 digits';
                                }
                                return null;
                              },
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                hintText: "Enter your phone number",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: kPrimaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 0.03),

                          // Login Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor:
                                    kPrimaryColor.withValues(alpha: 0.3),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      loginUser();
                                    },
                              child: isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Sign In",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Sign Up Link
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "New to the app? ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
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
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Legal Links
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _launchURL(
                                "https://www.rwandatraffic.rw/privacy-policy.html");
                          },
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.underline,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            _launchURL(
                                "https://www.rwandatraffic.rw/terms-and-conditions.html");
                          },
                          child: Text(
                            "Terms of Service",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.underline,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
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

  Future<void> loginUser() async {
    showRewardedAd();
    // Check for network connectivity
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      _showToast(
          "No internet connection. Please try again when you have a stable connection.");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    preferences = await SharedPreferences.getInstance();
    const loginUrl = API.login;

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: {
          'password': password.trim(),
        },
      );

      if (response.statusCode == 200) {
        final loginResult = json.decode(response.body);

        if (loginResult['success'] == true) {
          await _updateFcmToken(loginResult['uid']);
          await _saveUserPreferences(loginResult);
          if (loginResult['role'] == 'Admin') {
            _navigateToHome(loginResult['uid'], loginResult['role']);
          } else {
            // _navigateToHome(loginResult['uid'], loginResult['role']);
            if (deviceId != null) {
              if (loginResult['role'] == 'User' &&
                  loginResult['deviceId'] == deviceId) {
                _navigateToHome(loginResult['uid'], loginResult['role']);
              } else {
                _showToast(
                    "This device is not registered with your account. Please use the phone you registered with.");
              }
            } else {
              _showToast("Device not captured!");
            }
          }
        } else {
          _showToast(loginResult['message'] ?? "Login failed");
        }
      } else {
        _showToast("Failed to connect to login API");
      }
    } catch (e) {
      print("Login Error: $e");
      _showToast("An error occurred. Please try again.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateFcmToken(String uid) async {
    if (fcmToken == null) return;

    try {
      const fcmTokenUrl = API.updateFcmToken;
      final response = await http.post(
        Uri.parse(fcmTokenUrl),
        body: {'docId': uid, 'fcmToken': fcmToken},
      );

      if (response.statusCode != 200) {
        print("Error: Failed to update FCM token");
      }
    } catch (e) {
      print("FCM Token Update Error due to : $e");
    }
  }

  Future<void> _saveUserPreferences(Map<String, dynamic> userData) async {
    await preferences.setString("uid", userData["uid"]);
    await preferences.setString("name", userData["name"]);
    await preferences.setString("role", userData["role"]);
    await preferences.setString("phone", userData["phone"]);
    await preferences.setBool("isLoggedIn", true);

    if (userData["can_access_online_school"].toString() == "1") {
      await preferences.setBool("canAccessOnlineSchool", true);
    }

    if (fcmToken != null) {
      await preferences.setString("fcmToken", fcmToken!);
    }
  }

  void _navigateToHome(String uid, String userRole) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          currentuserid: uid,
          userRole: userRole,
        ),
      ),
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: Colors.red,
      fontSize: 16,
      msg: message,
    );
  }
}
