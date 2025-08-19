import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../widgets/DashboardCards.dart';
import '../../widgets/BouncingButton.dart';
import '../../ads/ad_manager.dart'; // Import ad manager
import '../../ads/banner_widget.dart';
import '../rules/amategeko_yose.dart';
import '../user_progress/user_progress_screen.dart';
import '../../widgets/MainDrawer.dart';
import '../../components/amabwiriza.dart';
import '../homepages/open_exam.dart';
import '../amasomo/course_management.dart';
import '../groups/group_list.dart';
import '../homepages/notificationtab.dart';
import '../accounts/users.dart';
import '../irembo/irembo_iyandikishe.dart';
import '../irembo/abiyandishije.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late Animation animation, delayedAnimation, muchDelayedAnimation, leftCurve;
  late AnimationController animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //shared preferences
  late SharedPreferences preferences;
  String currentuserid = "";
  String currentusername = "User";
  String userRole = "";

  String phone = "";
  String? referralCode;

  // Ad manager is now handled globally
  bool isLoading = true;

  void getCurrUserData() async {
    try {
      preferences = await SharedPreferences.getInstance();

      if (mounted) {
        setState(() {
          currentuserid = preferences.getString("uid") ?? "";
          currentusername = preferences.getString("name") ?? "User";
          userRole = preferences.getString("role") ?? "";
          phone = preferences.getString("phone") ?? "";

          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
    // Ads are initialized in main.dart
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

  // void _showLogoutDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Logout'),
  //         content: const Text('Are you sure you want to logout?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               UserStateMethods().logoutuser(context);
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text('Logout'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void showRewardedAd() {
    try {
      // Check if ad manager is still valid before showing ad
      if (!mounted) return;

      bool adShown = AdManager.showRewardedAd(context: 'bonus_feature');

      if (!adShown) {
        print('Rewarded Ad is not loaded yet. Loading...');
        // The ad manager will automatically try to load a new ad
      }
    } catch (e) {
      print('Error showing rewarded ad: $e');
    }
  }

  void _showInterstitialAd() {
    try {
      // Check if ad manager is still valid before showing ad
      if (!mounted) return;

      // Show the interstitial ad when needed
      AdManager.showInterstitialAd(context: 'dashboard_action');
    } catch (e) {
      print('Error showing interstitial ad: $e');
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    // Ads are disposed globally
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kPrimaryColor.withValues(alpha: 0.05),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  "Loading dashboard...",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     _showLogoutDialog();
          //   },
          //   backgroundColor: Colors.red,
          //   child: const Icon(Icons.logout, color: Colors.white),
          //   tooltip: 'Logout',
          // ),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _scaffoldKey.currentState!.openDrawer(),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.menu,
                                  color: kPrimaryColor, size: 28),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rwanda Traffic",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                "Dashboard",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AmabwirizaList(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.rule_rounded,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Rules",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withValues(alpha: 0.05),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Modern Header
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 24, vertical: 28),
                  //   decoration: BoxDecoration(
                  //     color: kPrimaryColor.withValues(alpha: 0.08),
                  //     borderRadius: const BorderRadius.only(
                  //       bottomLeft: Radius.circular(32),
                  //       bottomRight: Radius.circular(32),
                  //     ),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           CircleAvatar(
                  //             radius: 28,
                  //             backgroundColor:
                  //                 kPrimaryColor.withValues(alpha: 0.15),
                  //             child: Icon(Icons.person,
                  //                 color: kPrimaryColor, size: 32),
                  //           ),
                  //           const SizedBox(width: 16),
                  //           Expanded(
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text(
                  //                   "Welcome,",
                  //                   style: TextStyle(
                  //                     color: Colors.grey[700],
                  //                     fontSize: 16,
                  //                   ),
                  //                 ),
                  //                 Text(
                  //                   currentusername,
                  //                   style: TextStyle(
                  //                     color: kPrimaryColor,
                  //                     fontWeight: FontWeight.bold,
                  //                     fontSize: 22,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //           Container(
                  //             padding: const EdgeInsets.symmetric(
                  //                 horizontal: 12, vertical: 6),
                  //             decoration: BoxDecoration(
                  //               color: kPrimaryColor.withValues(alpha: 0.12),
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //             child: Row(
                  //               children: [
                  //                 Icon(Icons.verified_user,
                  //                     color: kPrimaryColor, size: 18),
                  //                 const SizedBox(width: 4),
                  //                 Text(
                  //                   userRole,
                  //                   style: TextStyle(
                  //                     color: kPrimaryColor,
                  //                     fontWeight: FontWeight.w600,
                  //                     fontSize: 14,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 18),
                  //       Text(
                  //         "What would you like to do today?",
                  //         style: TextStyle(
                  //           color: Colors.grey[700],
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 18),
                  // Small Welcome Card with Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        showRewardedAd();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const UserProgressScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kPrimaryColor.withValues(alpha: 0.08),
                              kPrimaryColor.withValues(alpha: 0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: kPrimaryColor.withValues(alpha: 0.12),
                            width: 0.7,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.emoji_events_rounded,
                                color: kPrimaryColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Your Progress",
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Keep practicing!",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 9,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.trending_up,
                                      color: Colors.white, size: 11),
                                  const SizedBox(width: 2),
                                  Text(
                                    "Stats",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Dashboard Grid - Row 1
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedBuilder(
                          animation: muchDelayedAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset:
                                  Offset(muchDelayedAnimation.value * width, 0),
                              child: Bouncing(
                                onPress: () {
                                  showRewardedAd();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const OpenExamPage(),
                                    ),
                                  );
                                },
                                child: const DashboardCard(
                                  name: "Exams",
                                  imgpath: "rnp.jpg",
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: muchDelayedAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset:
                                  Offset(muchDelayedAnimation.value * width, 0),
                              child: Bouncing(
                                onPress: () {
                                  showRewardedAd();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const CourseManagement(),
                                    ),
                                  );
                                },
                                child: DashboardCard(
                                  name: "Online School",
                                  imgpath: "mwarimu.jpg",
                                  // isDisabled: userRole != 'Admin' &&
                                  //     !canAccessOnlineSchool,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Dashboard Grid - Row 2
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedBuilder(
                          animation: muchDelayedAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset:
                                  Offset(muchDelayedAnimation.value * width, 0),
                              child: Bouncing(
                                onPress: () {
                                  showRewardedAd();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const AmategekoYose()),
                                  );
                                },
                                child: const DashboardCard(
                                  name: "Traffic Rules",
                                  imgpath: "traffic.png",
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: delayedAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(delayedAnimation.value * width, 0),
                              child: Bouncing(
                                onPress: () {
                                  _showInterstitialAd();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const GroupList(),
                                    ),
                                  );
                                },
                                child: const DashboardCard(
                                  name: "WhatsApp Group",
                                  imgpath: "wgroup.jpg",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Dashboard Grid - Row 3 (Conditional based on user role)
                  if (userRole != "Caller")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedBuilder(
                            animation: muchDelayedAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    muchDelayedAnimation.value * width, 0),
                                child: Bouncing(
                                  onPress: () {
                                    _showInterstitialAd();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const Notifications(),
                                      ),
                                    );
                                  },
                                  child: DashboardCard(
                                    name: userRole == "Admin" ||
                                            userRole == "Caller"
                                        ? "Notifications"
                                        : 'Share',
                                    imgpath: userRole == "Admin" ||
                                            userRole == "Caller"
                                        ? "notification.png"
                                        : "share1.png",
                                  ),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: delayedAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset:
                                    Offset(delayedAnimation.value * width, 0),
                                child: Bouncing(
                                  onPress: () {
                                    showRewardedAd();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const AllUsers(),
                                      ),
                                    );
                                  },
                                  child: DashboardCard(
                                    name: userRole == "User"
                                        ? "My code"
                                        : "All Users",
                                    imgpath: "images/icon1.jpg",
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  // Dashboard Grid - Row 4 (Conditional based on user role)
                  if (userRole != "Admin")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedBuilder(
                            animation: delayedAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset:
                                    Offset(delayedAnimation.value * width, 0),
                                child: Bouncing(
                                  onPress: () {
                                    showRewardedAd();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const IremboSignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const DashboardCard(
                                    name: "Register",
                                    imgpath: 'irembo.jpg',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                              width: 18), // Empty space for single card
                        ],
                      ),
                    ),
                  // Admin specific cards
                  if (userRole == "Admin")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedBuilder(
                            animation: muchDelayedAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    muchDelayedAnimation.value * width, 0),
                                child: Bouncing(
                                  onPress: () {
                                    _showInterstitialAd();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const Abiyandikishe(),
                                      ),
                                    );
                                  },
                                  child: const DashboardCard(
                                    name: "Registered Users",
                                    imgpath: "irembo.jpg",
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                              width: 18), // Empty space for single card
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  const AdBannerWidget(),
                  const SizedBox(
                      height: 100), // Increased padding for bottom navigation
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
