import 'dart:convert';
import 'HomeScreen.dart';
import '../utils/constants.dart';
import 'Welcome/welcome_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../backend/apis/db_connection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late SharedPreferences preferences;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  bool isAlreadyLoggedIn = false;
  String? currentuserid;
  String? userRole;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });

    navigateUser();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _isUserLoggedIn() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      isAlreadyLoggedIn = preferences.getBool("isLoggedIn") ?? false;
    });
  }

  Future<void> navigateUser() async {
    preferences = await SharedPreferences.getInstance();
    currentuserid = preferences.getString("uid");
    userRole = preferences.getString("role");

    fcmToken = await _messaging.getToken();

    await checkVersion(); // Call version check before proceeding

    if (currentuserid != null) {
      try {
        final fcmTokenUrl = API.updateFcmToken;
        final response = await http.post(
          Uri.parse(fcmTokenUrl),
          body: {'docId': currentuserid, 'fcmToken': fcmToken},
        );

        if (response.statusCode == 200) {
          // Your logic for a successful response
          final fcmResult = json.decode(response.body);
          if (fcmResult['success'] == true) {
            // Handle success

            if (!mounted) return;
            setState(() {
              isAlreadyLoggedIn = true;
              _isUserLoggedIn();
              preferences.setString("fcmToken", fcmToken!);
            });
          }
        } else {
          print("Error: Failed to connect to API");
        }
      } catch (e) {
        print("Error: $e");
      }
    } else {
      if (!mounted) return;
      setState(() {
        isAlreadyLoggedIn = false;
      });
    }
  }

  String? minVersion;

  Future<void> checkVersion() async {
    try {
      final response = await http.get(Uri.parse(API.app_version_url));
      if (response.statusCode == 200) {
        final versionInfo = jsonDecode(response.body);
        minVersion = versionInfo['min_version'];

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        print("min version: " + minVersion!);
        print("current version: " + currentVersion);

        if (_isVersionLower(currentVersion, minVersion!)) {
          _showUpdateDialog(versionInfo['update_url']);
        }
      } else {
        throw Exception('Failed to fetch version info');
      }
    } catch (e) {
      print("Error checking app version: $e");
    }
  }

  bool _isVersionLower(String currentVersion, String minVersion) {
    return currentVersion.compareTo(minVersion) < 0;
  }

  void _showUpdateDialog(String updateUrl) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog dismissal
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Prevent back button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.system_update, color: kPrimaryColor),
                const SizedBox(width: 8),
                Text(
                  "Update Required",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            content: Text(
              "A new version of the app is available. Please update to continue using the app. You cannot use this version anymore. Thank you for your understanding.",
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Update Now"),
                onPressed: () {
                  _launchURL(updateUrl); // Launch update URL
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (isAlreadyLoggedIn && currentuserid != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              currentuserid: preferences.getString("uid").toString(),
              userRole: userRole.toString(),
            ),
          ),
        );
      }
    }
  }

  void _navigateToNextScreen() {
    if (isAlreadyLoggedIn && currentuserid != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            currentuserid: preferences.getString("uid").toString(),
            userRole: userRole.toString(),
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(
            min_version: minVersion ?? "1.0.0",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-navigate after animations complete
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              kPrimaryLightColor.withValues(alpha: 0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/icon_new.png",
                      height: 120,
                      width: 120,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // App Title
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        "Rwanda Traffic Rules Pro",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Learn & Master Traffic Regulations",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Version info
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Version ${minVersion ?? "1.0.0"}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
