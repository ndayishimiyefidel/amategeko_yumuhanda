import 'package:amategeko/resources/user_state_methods.dart';
import 'package:amategeko/screens/accounts/AccountSettingsPage.dart';
import 'package:amategeko/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/Signup/signup_screen.dart';
import '../screens/amasomo/prayer.dart';
import '../screens/homepages/dashboard.dart';
import '../screens/quizzes/old_quiz.dart';

class MainDrawer extends StatefulWidget {
  final String? userRole;
  final String? referralCode;

  MainDrawer({
    this.userRole,
    this.referralCode,
  });

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    initUniLinks();
  }

  Future<void> initUniLinks() async {
    try {
      Uri? initialLink = Uri.parse(await getInitialLink().toString());
      if (initialLink != null) {
        handleDeepLink(initialLink);
      }

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
    // Replace "com.amategeko.amategeko" with your app package name on the Play Store
    String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.amategeko.amategeko";
    // Redirect to the Play Store
    launch(playStoreLink);
  }

  Future<bool> checkAppInstalled() async {
    // Replace "com.amategeko.amategeko" with your app package name
    const String appPackage = "com.amategeko.amategeko";
    // Check if the app is installed by attempting to launch it
    bool isInstalled = await canLaunch(appPackage);
    return isInstalled;
  }

  void shareApp() {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.amategeko.amategeko";
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
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const OldQuiz(),
                  ),
                );
              });
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
            onTap: () => deleteUser(auth.currentUser!.uid),
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
            onTap: () => deleteUser(auth.currentUser!.uid),
            leading: IconButton(
              onPressed: () => deleteUser(auth.currentUser!.uid),
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

  Future<void> deleteUser(String docId) async {
    await auth.currentUser!.delete().then((value) => {
          FirebaseFirestore.instance
              .collection("Users")
              .doc(docId)
              .delete()
              .then((value) => {
                    UserStateMethods().logoutuser(context),
                    print("User deleted"),
                  })
        });
  }
}
