import 'package:amategeko/screens/accounts/AccountSettingsPage.dart';
import 'package:amategeko/screens/accounts/UserList.dart';
import 'package:amategeko/screens/groups/group_list.dart';
import 'package:amategeko/screens/quizzes/old_quiz.dart';
import 'package:amategeko/screens/quizzes/quizzes.dart';
import 'package:amategeko/screens/rules/amategeko_yose.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../resources/user_state_methods.dart';
import '../../utils/constants.dart';
import '../../widgets/BouncingButton.dart';
import '../../widgets/DashboardCards.dart';
import '../../widgets/MainDrawer.dart';
import 'nofications.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late Animation animation, delayedAnimation, muchDelayedAnimation, leftCurve;
  late AnimationController animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  String userRole = "";
  late String photo;
  late String phone;

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      photo = preferences.getString("photo")!;
      phone = preferences.getString("phone")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();

    animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));

    delayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));

    muchDelayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.fastOutSlowIn)));

    leftCurve = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    animationController.forward();
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            elevation: 0,
            child: MainDrawer(),
          ),
          appBar: AppBar(
            title: const Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                letterSpacing: 1.25,
                fontSize: 24,
              ),
            ),
            leading: IconButton(
              color: Colors.white,
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const Notifications(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 25,
                  ),
                ),
              ),
            ],
            centerTitle: true,
            backgroundColor: kPrimaryColor,
            elevation: 0.0,
          ),
          body: ListView(
            children: [
              // UserDetailCard(),
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                child: Container(
                  alignment: const Alignment(1.0, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform(
                          transform: Matrix4.translationValues(
                              muchDelayedAnimation.value * width, 0, 0),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => Quizzes(),
                                ),
                              );
                            },
                            child: const DashboardCard(
                              name: "Quizzes",
                              imgpath: "quizzez.png",
                            ),
                          ),
                        ),
                        Transform(
                          transform: Matrix4.translationValues(
                              delayedAnimation.value * width, 0, 0),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      UserSettings(),
                                ),
                              );
                            },
                            child: const DashboardCard(
                              name: "Profile",
                              imgpath: "profile.png",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                child: Container(
                  alignment: const Alignment(1.0, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform(
                          transform: Matrix4.translationValues(
                              muchDelayedAnimation.value * width, 0, 0),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const AmategekoYose(),
                                ),
                              );
                            },
                            child: const DashboardCard(
                              name: "Gazette",
                              imgpath: "traffic.png",
                            ),
                          ),
                        ),
                        Transform(
                          transform: Matrix4.translationValues(
                              delayedAnimation.value * width, 0, 0),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const GroupList(),
                                ),
                              );
                            },
                            child: const DashboardCard(
                              name: "Whatsapp Group",
                              imgpath: "wgroup.jpg",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                child: Container(
                  alignment: const Alignment(1.0, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform(
                          transform: Matrix4.translationValues(
                              muchDelayedAnimation.value * width, 0, 0),
                          child: Bouncing(
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Notifications(),
                                ),
                              );
                            },
                            child: const DashboardCard(
                              name: "Notifications",
                              imgpath: "notification.png",
                            ),
                          ),
                        ),
                        userRole != "Admin"
                            ? Transform(
                                transform: Matrix4.translationValues(
                                    delayedAnimation.value * width, 0, 0),
                                child: Bouncing(
                                  onPress: () =>
                                      UserStateMethods().logoutuser(context),
                                  child: const DashboardCard(
                                    name: "Exit",
                                    imgpath: "exit.png",
                                  ),
                                ),
                              )
                            : Transform(
                                transform: Matrix4.translationValues(
                                    delayedAnimation.value * width, 0, 0),
                                child: Bouncing(
                                  onPress: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              UserList(),
                                        ));
                                  },
                                  child: const DashboardCard(
                                    name: "All User",
                                    imgpath: "images/icon1.jpg",
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
