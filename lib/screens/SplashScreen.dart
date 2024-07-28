import 'dart:convert';
import 'HomeScreen.dart';
import '../utils/constants.dart';
import 'Welcome/welcome_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../backend/apis/db_connection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart'; // Add this import

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
          }
        } else {
          print("Error: Failed to connect to API");
        }
      } catch (e) {
        print("Error: $e");
      }
      if (!mounted) return;
      setState(() {
        isAlreadyLoggedIn = true;
        preferences.setString("fcmToken", fcmToken!);
      });
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
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: AlertDialog(
            title: Text("Kuvugurura birakenewe"),
            content: Text(
              "Verisiyo nshya ya porogaramu irahari. Nyamuneka vugurura kugirango ukomeze gukoresha porogaramu.Nta muntu wemere gukoresha iyi verisiyo kanda kuri update  ",
              style: const TextStyle(
                  fontSize: 18.0, fontFamily: 'Courgette', color: Colors.red),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Update"),
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
          : WelcomeScreen(
              min_version: minVersion.toString(),
            ),
      duration: 11000,
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


















// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:splash_screen_view/SplashScreenView.dart';
// import 'dart:convert';
// import '../backend/apis/db_connection.dart';
// import '../utils/constants.dart';
// import 'HomeScreen.dart';
// import 'Welcome/welcome_screen.dart';
// import 'package:http/http.dart' as http;

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   late SharedPreferences preferences;
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   String? fcmToken;
//   bool isAlreadyLoggedIn = false;
//   String? currentuserid;
//   String? userRole;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     navigateUser();
//   }

//   void navigateUser() async {
//     preferences = await SharedPreferences.getInstance();
//     currentuserid = preferences.getString("uid");
//     userRole = preferences.getString("role");

//     fcmToken = await _messaging.getToken();

//     if (currentuserid != null) {
//       try {
//         final fcmTokenUrl = API.updateFcmToken;
//         final response = await http.post(
//           Uri.parse(fcmTokenUrl),
//           body: {'docId': currentuserid, 'fcmToken': fcmToken},
//         );

//         if (response.statusCode == 200) {
//           // Your logic for a successful response
//           final fcmResult = json.decode(response.body);
//           if (fcmResult['success'] == true) {
//           } else {}
//         } else {
//           print("Error: Failed to connect to api");
//         }
//       } catch (e) {
//         print("Error: $e");
//       }
//       if (!mounted) return;
//       setState(() {
//         isAlreadyLoggedIn = true;
//         preferences.setString("fcmToken", fcmToken!);
//       });
//     } else {
//       if (!mounted) return;
//       setState(() {
//         isAlreadyLoggedIn = false;
//       });
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       // When the app is minimized or closed, navigate to the HomeScreen
//       if (isAlreadyLoggedIn) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => HomeScreen(
//               currentuserid: preferences.getString("uid").toString(),
//               userRole: userRole.toString(),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SplashScreenView(
//       navigateRoute: isAlreadyLoggedIn
//           ? HomeScreen(
//               currentuserid: preferences.getString("uid").toString(),
//               userRole: userRole.toString(),
//             )
//           : const WelcomeScreen(),
//       duration: 5500,
//       imageSrc: "assets/images/icon_new.png",
//       text: "Amategeko y'Umuhanda",
//       textType: TextType.ColorizeAnimationText,
//       textStyle: const TextStyle(fontSize: 40.0, fontFamily: 'Courgette'),
//       colors: const [
//         kPrimaryColor,
//         kPrimaryLightColor,
//         kPrimaryColor,
//       ],
//       backgroundColor: Colors.white,
//     );
//   }
// }
