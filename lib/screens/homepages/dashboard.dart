import 'dart:async';

import 'package:amategeko/screens/ambassador/view_referrals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/BouncingButton.dart';
import '../../widgets/DashboardCards.dart';
import '../../widgets/MainDrawer.dart';
import '../../widgets/banner_widget.dart';
import '../accounts/users.dart';
import '../amasomo/all_courses.dart';
import '../ambassador/ambassador.dart';
import '../groups/group_list.dart';
import '../irembo/abiyandishije.dart';
import '../irembo/irembo_iyandikishe.dart';
import '../quizzes/exams.dart';
import '../quizzes/quiz.dart';
import '../rules/amategeko_yose.dart';
import 'noficationtab1.dart';
import 'notificationtab.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late Animation animation, delayedAnimation, muchDelayedAnimation, leftCurve;
  late AnimationController animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  InterstitialAd? _interstitialAd;
  Timer? interstitialTimer;
  bool _isConnected = true;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2864387622629553/2309153588',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  String userRole = "";
  late String photo;
  late String phone;
  String? referralCode;

  Future<String?> _getReferralCode() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where("role", isEqualTo: "Ambassador")
          .where("uid", isEqualTo: currentuserid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs[0];
        return userDoc["referralCode"];
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting referral code: $e");
      return null;
    }
  }

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      photo = preferences.getString("photo")!;
      phone = preferences.getString("phone")!;
      _getReferralCode().then((code) {
        setState(() {
          referralCode = code;
          print(referralCode);
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
    checkInternetConnection();

    // Start the timer to show the interstitial ad every 4 minutes
    // interstitialTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
    //   showInterstitialAd();
    // });

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

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
    if (_isConnected) {
      loadInterstitialAd();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    _interstitialAd!.dispose();
    interstitialTimer?.cancel();
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
            child: MainDrawer(
              userRole: userRole,
              referralCode: referralCode,
            ),
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
                      builder: (BuildContext context) =>
                          const NotificationTab1(),
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
                              if (_isConnected) {
                                showInterstitialAd();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => Exams(),
                                  ),
                                );
                              } else if (_interstitialAd == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => Exams(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => Exams(),
                                  ),
                                );
                              }
                            },
                            child: const DashboardCard(
                              name: "New Exam",
                              imgpath: "exam.png",
                            ),
                          ),
                        ),
                        Transform(
                          transform: Matrix4.translationValues(
                              delayedAnimation.value * width, 0, 0),
                          child: Bouncing(
                            onPress: () {
                              if (_isConnected) {
                                showInterstitialAd();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        OnlyQuiz(),
                                  ),
                                );
                              } else if (_interstitialAd == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        OnlyQuiz(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        OnlyQuiz(),
                                  ),
                                );
                              }
                            },
                            child: const DashboardCard(
                              name: "Quiz",
                              imgpath: "quizzez.png",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AdBannerWidget(),
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
                              name: "IGAZETTE",
                              imgpath: "traffic.png",
                            ),
                          ),
                        ),
                        Transform(
                          transform: Matrix4.translationValues(
                              delayedAnimation.value * width, 0, 0),
                          child: Bouncing(
                            onPress: () {
                              if (_isConnected) {
                                showInterstitialAd();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const GroupList(),
                                  ),
                                );
                              } else if (_interstitialAd == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const GroupList(),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const GroupList(),
                                  ),
                                );
                              }
                            },
                            child: const DashboardCard(
                              name: "Group Whatsapp",
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
                        userRole != "Caller"
                            ? Transform(
                                transform: Matrix4.translationValues(
                                    muchDelayedAnimation.value * width, 0, 0),
                                child: Bouncing(
                                  onPress: () {
                                    if (_isConnected) {
                                      showInterstitialAd();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              Notifications(),
                                        ),
                                      );
                                    } else if (_interstitialAd == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              Notifications(),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              Notifications(),
                                        ),
                                      );
                                    }
                                  },
                                  child: const DashboardCard(
                                    name: "Notifications",
                                    imgpath: "notification.png",
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
                                              const AllUsers(),
                                        ));
                                  },
                                  child: const DashboardCard(
                                    name: "All User",
                                    imgpath: "images/icon1.jpg",
                                  ),
                                ),
                              ),
                        userRole != "Admin"
                            ? Transform(
                                transform: Matrix4.translationValues(
                                    delayedAnimation.value * width, 0, 0),
                                child: Bouncing(
                                  onPress: () {
                                    if (_isConnected) {
                                      showInterstitialAd();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const IremboSignUpScreen(),
                                        ),
                                      );
                                    } else if (_interstitialAd == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const IremboSignUpScreen(),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const IremboSignUpScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  child: const DashboardCard(
                                    name: "Iyandikishe",
                                    imgpath: 'irembo.jpg',
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
                                              const AllUsers(),
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
              userRole == "Admin"
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                      child: Container(
                        alignment: const Alignment(1.0, 0),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, right: 20.0),
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
                                            const AllCourse(),
                                      ),
                                    );
                                  },
                                  child: const DashboardCard(
                                    name: "Ishuri online",
                                    imgpath: "mwarimu.jpg",
                                  ),
                                ),
                              ),
                              Transform(
                                transform: Matrix4.translationValues(
                                    muchDelayedAnimation.value * width, 0, 0),
                                child: Bouncing(
                                  onPress: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const AllAmbassadors(),
                                      ),
                                    );
                                  },
                                  child: const DashboardCard(
                                    name: "Register Ambassador",
                                    imgpath: "profile.png",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              userRole == "Ambassador"
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                      child: Container(
                        alignment: const Alignment(1.0, 0),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, right: 20.0),
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
                                            ViewReferrals(
                                                referralCode:
                                                    referralCode.toString(),
                                                refUid: currentuserid),
                                      ),
                                    );
                                  },
                                  child: const DashboardCard(
                                    name: "My Referrals",
                                    imgpath: "wgroup.jpg",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                child: Container(
                  alignment: const Alignment(1.0, 0),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        userRole == "Admin"
                            ? Transform(
                                transform: Matrix4.translationValues(
                                    muchDelayedAnimation.value * width, 0, 0),
                                child: Bouncing(
                                  onPress: () {
                                    if (_isConnected) {
                                      showInterstitialAd();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const Abiyandikishe(),
                                        ),
                                      );
                                    } else if (_interstitialAd == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const Abiyandikishe(),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const Abiyandikishe(),
                                        ),
                                      );
                                    }
                                  },
                                  child: const DashboardCard(
                                    name: "Abiyandikishe",
                                    imgpath: "irembo.jpg",
                                  ),
                                ),
                              )
                            : Container(),
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
