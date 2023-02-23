import 'package:amategeko/resources/user_state_methods.dart';
import 'package:amategeko/screens/accounts/AccountSettingsPage.dart';
import 'package:amategeko/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../screens/homepages/dashboard.dart';
import '../screens/quizzes/old_quiz.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
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
            onTap: () => UserStateMethods().logoutuser(context),
            leading: Image.asset(
              "assets/exit.png",
              height: 30,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Log out",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
