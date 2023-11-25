import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'dart:convert';
import '../backend/apis/db_connection.dart';
import '../utils/constants.dart';
import 'HomeScreen.dart';
import 'Welcome/welcome_screen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late SharedPreferences preferences;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  bool isAlreadyLoggedIn = false;
  String? currentuserid;
  String? userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    navigateUser();
  }

  void navigateUser() async {
    preferences = await SharedPreferences.getInstance();
    currentuserid = preferences.getString("uid");
    userRole = preferences.getString("role");

    fcmToken = await _messaging.getToken();

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
          } else {}
        } else {
          print("Error: Failed to connect to api");
        }
      } catch (e) {
        print("Error: $e");
      }

      setState(() {
        isAlreadyLoggedIn = true;
        preferences.setString("fcmToken", fcmToken!);
      });
    } else {
      setState(() {
        isAlreadyLoggedIn = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // When the app is minimized or closed, navigate to the HomeScreen
      if (isAlreadyLoggedIn) {
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: isAlreadyLoggedIn
          ? HomeScreen(
              currentuserid: preferences.getString("uid").toString(),
              userRole: userRole.toString(),
            )
          : const WelcomeScreen(),
      duration: 5500,
      imageSrc: "assets/images/icon_new.png",
      text: "Amategeko y'Umuhanda",
      textType: TextType.ColorizeAnimationText,
      textStyle: const TextStyle(fontSize: 40.0, fontFamily: 'Courgette'),
      colors: const [
        kPrimaryColor,
        kPrimaryLightColor,
        kPrimaryColor,
      ],
      backgroundColor: Colors.white,
    );
  }
}
