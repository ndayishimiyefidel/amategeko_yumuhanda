import 'package:amategeko/resources/user_state_methods.dart';
import 'package:amategeko/screens/accounts/AccountSettingsPage.dart';
import 'package:amategeko/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/homepages/dashboard.dart';
import '../screens/quizzes/old_quiz.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  FirebaseAuth auth = FirebaseAuth.instance;

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
            onTap: () =>
            {
              Share.share(
                  'Iyi application igizwe nibibazo nibisubizo babaza muri examin ya provisoire iga examin zose zirimo kuko bazakubaza imwe muri zo https://play.google.com/store/apps/details?id=com.amategeko.amategeko',
                  subject: 'Share App!')
            },
            leading: IconButton(
              onPressed: () =>
              {
                Share.share(
                    'Iyi application igizwe nibibazo nibisubizo babaza muri examin ya provisoire iga examin zose zirimo kuko bazakubaza imwe muri zo https://play.google.com/store/apps/details?id=com.amategeko.amategeko',
                    subject: 'Share App!')
              },
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
            title: const Text(
              "Share App",
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
    await auth.currentUser!.delete().then((value) =>
    {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(docId)
          .delete()
          .then((value) =>
      {
        UserStateMethods().logoutuser(context),
        print("User deleted"),
      })
    });
  }
}
