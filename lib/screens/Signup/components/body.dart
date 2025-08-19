import 'dart:math';
import 'dart:async';
import 'dart:convert';
import '../../HomeScreen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../Login/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../ads/ad_manager.dart'; // Import ad manager
import 'package:fluttertoast/fluttertoast.dart';
import '../../Signup/components/background.dart';
import '../../Login/components/check_deviceid.dart';
import 'package:rwanda_traffic_rules/enume/models/user_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rwanda_traffic_rules/backend/apis/db_connection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

// ignore_for_file: use_build_context_synchronously

class SignUp extends StatefulWidget {
  final String? referralCode;

  const SignUp({Key? key, this.referralCode}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  bool isRegistered = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  String name = "", phoneNumber = "";

  late SharedPreferences preferences;
  bool isloading = false;
  final userRole = "User";
  String? deviceId;
  // Ad manager is now handled globally

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
    });
    //loads ads
    // Ads are initialized in main.dart

    getCurrUserId();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void showRewardedAd() {
    bool adShown = AdManager.showRewardedAd(context: 'user_signup');

    if (!adShown) {
      //print('Rewarded Ad is not loaded yet.');
    }
  }

  String? currentuserid;

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid") ?? '';

      if (kDebugMode) {
        print(currentuserid);
      }

      retrieveDeviceId();
    });
  }

  /// Updated retrieveDeviceId function for web-based platforms
  Future<void> retrieveDeviceId() async {
    if (kIsWeb) {
      //  Collect browser information for fingerprint
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

  String generateUniqueUid() {
    // Create a unique user ID using a timestamp and a random number
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final int randomNum = (timestamp ~/ 1000) + Random().nextInt(9999);
    return '$timestamp$randomNum';
  }

  Future<void> _registerUser() async {
    showRewardedAd();
    // Check for network connectivity
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      Fluttertoast.showToast(
        textColor: Colors.white,
        backgroundColor: Colors.red,
        fontSize: 16,
        msg:
            "No internet connection. Please try again when you have a stable connection.",
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isloading = true;
    });

    final String uid = generateUniqueUid();
    final int dateF = DateTime.now().millisecondsSinceEpoch;
    final User userModel = User(
      uid: uid,
      createdAt: dateF.toString(),
      password: phoneNumber.trim(),
      role: userRole,
      phone: phoneNumber.trim(),
      name: name.trim(),
      referralCode: "",
      state: 1,
      deviceId: deviceId?.toString() ?? "",
      fcmToken: fcmToken?.toString() ?? "",
      canAccessOnlineSchool: false,
    );

    try {
      if (deviceId == null || deviceId.toString() == '') {
        _showErrorToast("Unable to find device identifier of this device");
      } else {
        await _validateDeviceAndRegister(userModel, uid);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      _showErrorToast("An error occurred. Please try again. ${e.toString()}");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> _registerUserWeb(User userModel, String uid) async {
    try {
      print("🔍 DEBUG: Starting registration for user: $uid");
      print("🔍 DEBUG: User model data: ${userModel.toJson()}");

      final response = await http.post(
        Uri.parse(API.signUp),
        body: userModel.toJson(),
      );

      print("🔍 DEBUG: Registration response status: ${response.statusCode}");
      print("🔍 DEBUG: Registration response body: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("🔍 DEBUG: Parsed result: $result");

        // Check if the response contains user data that might need parsing
        if (result['user'] != null) {
          print("🔍 DEBUG: Response contains user data: ${result['user']}");
          try {
            // If there's user data, try to parse it safely
            if (result['user'] is Map<String, dynamic>) {
              print("🔍 DEBUG: User data is a Map, attempting to parse...");
              // Don't actually parse it here, just log it
            }
          } catch (e) {
            print("🔍 DEBUG: Error parsing user data from response: $e");
          }
        }

        if (result['registered'] == true) {
          await _saveUserPreferences(uid);
          _navigateToHome(uid);
        } else {
          _showErrorToast(result['message'] ?? "Registration Failed");
        }
      } else {
        _showErrorToast("Failed to connect to registration API");
      }
    } catch (e, stackTrace) {
      print("🔍 DEBUG: Registration error: $e");
      print("🔍 DEBUG: Stack trace: $stackTrace");
      _showErrorToast("Registration failed. Please try again.");
    }
  }

  Future<void> _validateDeviceAndRegister(User userModel, String uid) async {
    try {
      print("🔍 DEBUG: Starting device validation for user: $uid");
      print("🔍 DEBUG: Device ID: $deviceId, Phone: $phoneNumber");

      final validationResponse = await http.post(
        Uri.parse(API.validate),
        body: {"deviceId": deviceId, "phone": phoneNumber},
      );

      print(
          "🔍 DEBUG: Validation response status: ${validationResponse.statusCode}");
      print("🔍 DEBUG: Validation response body: ${validationResponse.body}");

      if (validationResponse.statusCode == 200) {
        final validationResult = jsonDecode(validationResponse.body);
        print("🔍 DEBUG: Parsed validation result: $validationResult");

        if (validationResult['success'] == false) {
          await _registerUserWeb(userModel, uid);
        } else {
          _showErrorToast(validationResult['message'] ??
              "Device already registered in the app, please contact the administrator");
        }
      } else {
        _showErrorToast("Failed to connect to API");
      }
    } catch (e, stackTrace) {
      print("🔍 DEBUG: Device validation error: $e");
      print("🔍 DEBUG: Stack trace: $stackTrace");
      _showErrorToast("Device validation failed. Please try again.");
    }
  }

  Future<void> _saveUserPreferences(String uid) async {
    preferences = await SharedPreferences.getInstance();
    await preferences.setString("uid", uid);
    await preferences.setString("name", name);
    await preferences.setString("phone", phoneNumber.trim());
    await preferences.setString("role", userRole);
    await preferences.setBool(
        "canAccessOnlineSchool", false); // New users start with no access
    if (fcmToken != null) {
      await preferences.setString("fcmToken", fcmToken!);
    }
  }

  void _navigateToHome(String uid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(currentuserid: uid, userRole: userRole),
      ),
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
        textColor: Colors.white,
        backgroundColor: Colors.red,
        fontSize: 16,
        msg: message,
        toastLength: Toast.LENGTH_LONG);
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
                  SizedBox(height: size.height * 0.06),

                  // Header Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            "assets/icons/signup.svg",
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
                          "Create Account",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          "Join us to start learning traffic rules and get your license",
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
                                      fontSize: 18,
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
                            const SizedBox(height: 12),
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

                  SizedBox(height: size.height * 0.04),

                  // Registration Form
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Name Input
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
                                  return 'Full name is required';
                                }
                                if (nameValue.length < 3) {
                                  return 'Name must be at least 3 characters';
                                }
                                const String p = "^[a-zA-Z\\s]+";
                                RegExp regExp = RegExp(p);

                                if (regExp.hasMatch(nameValue)) {
                                  return null;
                                }

                                return 'Please enter a valid name';
                              },
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                hintText: "Enter your full name",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(
                                  Icons.person,
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

                          SizedBox(height: size.height * 0.02),

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
                              controller: phoneNumberEditingController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              onChanged: (val) {
                                phoneNumber = val;
                                if (kDebugMode) {
                                  print(phoneNumber);
                                }
                              },
                              validator: (phoneValue) {
                                if (phoneValue!.isEmpty) {
                                  return 'Phone number is required';
                                }

                                const String p = "^07[2,389]\\d{7}";
                                RegExp regExp = RegExp(p);

                                if (regExp.hasMatch(phoneValue)) {
                                  return null;
                                }

                                return 'Please enter a valid Rwandan phone number';
                              },
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                hintText: "Enter your phone number",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
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

                          SizedBox(height: size.height * 0.04),

                          // Register Button
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
                              onPressed: isloading
                                  ? null
                                  : () {
                                      _registerUser();
                                    },
                              child: isloading
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
                                        Icon(Icons.person_add, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Create Account",
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

                  // Sign In Link
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Already have an account? ",
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
                                  return const LoginScreen();
                                },
                              ),
                            );
                          },
                          child: Text(
                            "Sign In",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
