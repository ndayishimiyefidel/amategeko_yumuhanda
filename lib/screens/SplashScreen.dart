import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import '../utils/constants.dart';
import 'HomeScreen.dart';
import 'Welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SharedPreferences preferences;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;
  bool isAlreadyLoggedIn = false;
  String? currentuserid;
  String? userRole;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    precachePicture(
        ExactAssetPicture(
            SvgPicture.svgStringDecoderBuilder, 'assets/icons/signup.svg'),
        null);
    precachePicture(
        ExactAssetPicture(
            SvgPicture.svgStringDecoderBuilder, 'assets/icons/chat.svg'),
        null);
    precachePicture(
        ExactAssetPicture(
            SvgPicture.svgStringDecoderBuilder, 'assets/icons/login.svg'),
        null);
    navigateuser();
  }

  void navigateuser() async {
    preferences = await SharedPreferences.getInstance();
    currentuserid = preferences.getString("uid");
    userRole = preferences.getString("role");

    fcmToken = await _messaging.getToken();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(preferences.getString("uid"))
          .update({"fcmToken": fcmToken});

      setState(() {
        isAlreadyLoggedIn = true;
      });

      Route route = MaterialPageRoute(
          builder: (c) => HomeScreen(
                currentuserid: preferences.getString("uid").toString(),
                userRole: userRole.toString(),
              ));
      Navigator.pushReplacement(context, route);
    } else {
      setState(() {
        isAlreadyLoggedIn = false;
      });
      Route route = MaterialPageRoute(builder: (c) => WelcomeScreen());
      Navigator.pushReplacement(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: isAlreadyLoggedIn
          ? HomeScreen(
              currentuserid: currentuserid!,
              userRole: userRole.toString(),
            )
          : WelcomeScreen(),
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
