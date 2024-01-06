import 'package:amategeko/components/amabwiriza.dart';
import 'package:amategeko/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ads/interestial_ad.dart';
import '../../ads/reward_video_manager.dart';
import '../../utils/constants.dart';
import '../../widgets/BouncingButton.dart';
import '../../widgets/DashboardCards.dart';
import '../../widgets/MainDrawer.dart';
import '../quizzes/exam_english.dart';
import '../quizzes/examen_fr.dart';
import '../quizzes/exams.dart';

class OpenExamPage extends StatefulWidget {
  const OpenExamPage({super.key});

  @override
  State createState() => _OpenExamPageState();
}

class _OpenExamPageState extends State<OpenExamPage>
    with SingleTickerProviderStateMixin {
  late Animation animation, delayedAnimation, muchDelayedAnimation, leftCurve;
  late AnimationController animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  String userRole = "";

  late String phone;
  String? referralCode;
  final InterestialAds adManager = InterestialAds();

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      phone = preferences.getString("phone")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
    RewardedVideoAdManager.loadRewardAd();
    adManager.loadInterstitialAd();

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

  void showRewardedAd() {
    bool adShown = RewardedVideoAdManager.showRewardAd();

    if (!adShown) {
      print('Rewarded Ad is not loaded yet.');
    }
  }

  void _showInterstitialAd() {
    // Show the interstitial ad when needed
    adManager.showInterstitialAd();
  }

  @override
  void dispose() {
    animationController.dispose();
    RewardedVideoAdManager.dispose();
    adManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    animationController.forward();
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            elevation: 0,
            child: MainDrawer(
              userRole: userRole,
              referralCode: referralCode,
            ),
          ),
          appBar: AppBar(
            title: const Text(
              "Exam Page",
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
              CustomButton(
                text: "Amabwiriza",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => AmabwirizaList(),
                    ),
                  );
                },
              )
            ],
            centerTitle: true,
            backgroundColor: kPrimaryColor,
            elevation: 0.0,
          ),
          body: ListView(
            children: [
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
                              //_showInterstitialAd();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Exams(),
                                ),
                              );
                            },
                            child: const DashboardCard(
                              name: "Kinyarwanda",
                              imgpath: "kinexam.jpg",
                            ),
                          ),
                        ),
                        Transform(
                          transform: Matrix4.translationValues(
                              muchDelayedAnimation.value * width, 0, 0),
                          child: Bouncing(
                            onPress: () {
                              //showRewardedAd();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const ExamEnglish(),
                                ),
                              );
                            },
                            child: const DashboardCard(
                              name: "English",
                              imgpath: "enexam.jpg",
                            ),
                          ),
                        )
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
                                      ExamFrench(),
                                ),
                              );
                            },
                            child: const DashboardCard(
                              name: "Francais",
                              imgpath: "frexam.jpg",
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
