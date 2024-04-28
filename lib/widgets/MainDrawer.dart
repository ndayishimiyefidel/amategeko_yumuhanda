import 'dart:convert';

import 'package:amategeko/screens/accounts/AccountSettingsPage.dart';
import 'package:amategeko/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../backend/apis/db_connection.dart';
import '../screens/Signup/signup_screen.dart';
import '../screens/amasomo/prayer.dart';
import '../screens/homepages/dashboard.dart';

class MainDrawer extends StatefulWidget {
  final String? userRole;
  final String? referralCode;

  const MainDrawer({
    super.key,
    this.userRole,
    this.referralCode,
  });

  @override
  State createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  late SharedPreferences preferences;
  late String currentuserid;
  late String phone;

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      currentuserid = preferences.getString("uid")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    try {
      Uri? initialLink = Uri.parse(getInitialLink().toString());
      handleDeepLink(initialLink);

      uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          handleDeepLink(uri);
        }
      });
    } catch (e) {
      // Handle link parsing error if any
    }
  }

  void handleDeepLink(Uri link) {
    if (link.queryParameters.containsKey("referral")) {
      String referralCode = link.queryParameters["referral"]!;
      // Check if the app is installed
      checkAppInstalled().then((isInstalled) {
        if (isInstalled) {
          // App is installed, navigate to the registration page with the referral code
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => SignUpScreen(
                // Pass the referral code as an argument to the SignUpScreen
                referralCode: referralCode,
              ),
            ),
          );
        } else {
          // App is not installed, redirect to the Play Store
          redirectToPlayStore();
        }
      });
    }
  }

  void redirectToPlayStore() {
    // Replace "com.amategeko.amategeko11" with your app package name on the Play Store
    String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.amategeko.amategeko1";
    // Redirect to the Play Store
    launchUrl(Uri.parse(playStoreLink));
  }

  Future<bool> checkAppInstalled() async {
    // Replace "com.amategeko.amategeko11" with your app package name
    const String appPackage = "com.amategeko.amategeko1";
    // Check if the app is installed by attempting to launch it
    bool isInstalled = await canLaunchUrl(Uri.parse(appPackage));
    return isInstalled;
  }

  void shareApp() {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.amategeko.amategeko1";
    const String appUrl = "https://amategeko-75e59.web.app/";
    String message;

    if (widget.userRole == "Ambassador") {
      // Include the referral code for Ambassadors in the link
      String appLinkWithReferral = "$appUrl?referral=${widget.referralCode}";
      message =
          "Iyi application igizwe n'ibibazo n'ibisubizo babaza muri examin ya provisoire iga examin zose zirimo kuko bazakubaza imwe muri zo $appLinkWithReferral";
    } else {
      // Use the standard link without the referral code
      message =
          "Iyi application igizwe n'ibibazo n'ibisubizo babaza muri examin ya provisoire iga examin zose zirimo kuko bazakubaza imwe muri zo $playStoreLink";
    }

    // Share the message containing the link (with or without referral code)
    Share.share(
      message,
      subject:
          widget.userRole != "Ambassador" ? 'Share App!' : 'Share your Code',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kPrimaryLightColor,
      ),
      child: ListView(
        children: [
          ListTile(
            onTap: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Home(),
                  ),
                );
              });
            },
            leading: Image.asset(
              "assets/home.png",
              height: 30,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Home",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              // SchedulerBinding.instance.addPostFrameCallback((_) {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (BuildContext context) => const OldQuiz(),
              //     ),
              //   );
              // });
            },
            leading: Image.asset(
              "assets/exam.png",
              height: 30,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Quiz",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => UserSettings(),
                  ),
                );
              });
            },
            leading: Image.asset(
              "assets/profile.png",
              height: 30,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: shareApp, // Call the shareApp function
            leading: IconButton(
              onPressed: shareApp, // Call the shareApp function
              icon: const Icon(
                Icons.share,
                size: 30,
                color: Colors.green,
              ),
            ),
            contentPadding: const EdgeInsets.only(
              left: 60,
              top: 5,
              bottom: 5,
            ),
            title: widget.userRole == "Ambassador"
                ? const Text(
                    "Share code",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Text(
                    "Share App",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          ListTile(
            // onTap: () => deleteUser(auth.currentUser!.uid),
            leading: IconButton(
              onPressed: () {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const Prayer(),
                    ),
                  );
                });
              },
              icon: const Icon(
                Icons.book,
                size: 30,
                color: Colors.blue,
              ),
            ),
            contentPadding: const EdgeInsets.only(
              left: 60,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Prayer",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () => {
              //String? currentuserid;
            },
            leading: IconButton(
              onPressed: () => {
                deleteUser(currentuserid),
              },
              icon: const Icon(
                Icons.delete,
                size: 30,
                color: Colors.redAccent,
              ),
            ),
            contentPadding: const EdgeInsets.only(
              left: 60,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Delete Account",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> deleteUser(String uid) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteSingleUser),
        body: {'uid': uid},
      );

      if (response.statusCode == 200) {
        // User deleted successfully
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          // Show a success message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account deleted successfully'),
              duration: Duration(seconds: 3),
            ),
          );
          // Navigate to login or another appropriate screen
          // Example:
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => LoginScreen()),
          // );
        } else {
          // Show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Failed to delete account: ${responseData['message']}'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Show an error message to the user if server responded with an error status
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${response.statusCode}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions that occur during the HTTP request
      print('Error deleting user: $e');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while deleting the account'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
