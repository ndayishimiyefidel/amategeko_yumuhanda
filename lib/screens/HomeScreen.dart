import 'package:rwanda_traffic_rules/screens/rules/amategeko_yose.dart';

import '../utils/constants.dart';
import '../enume/user_state.dart';
import 'homepages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'accounts/AccountSettingsPage.dart';
import '../resources/user_state_methods.dart';
import 'package:rwanda_traffic_rules/screens/quizzes/exams.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rwanda_traffic_rules/ads/ad_manager.dart'; // Import ad manager
import '../widgets/disclaimer_widget.dart'; // Import disclaimer widget

class HomeScreen extends StatefulWidget {
  final String currentuserid;
  final String userRole;

  const HomeScreen(
      {Key? key, required this.currentuserid, required this.userRole})
      : super(key: key);

  @override
  State createState() =>
      _HomeScreenState(currentuserid: currentuserid, userRole: userRole);
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  _HomeScreenState({required this.currentuserid, required String userRole});

  late SharedPreferences preferences;
  late String userRole = widget.userRole;
  late String currentusername = "";
  late String currentuserid;
  String userEmail = "user@email.com";

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    const Exams(),
    const AmategekoYose(),
    UserSettings(),
  ];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      UserStateMethods().setUserState(
          userId: currentuserid,
          userState: UserState.onLine,
          userRole: widget.userRole);
    });
    WidgetsBinding.instance.addObserver(this);
    getCurrUserData();
  }

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      userRole = preferences.getString("role") ?? "User";
      currentusername = preferences.getString("name") ?? "User";
      userEmail = preferences.getString("email") ?? "user@email.com";
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        UserStateMethods().setUserState(
            userId: currentuserid,
            userState: UserState.onLine,
            userRole: widget.userRole);
        break;
      case AppLifecycleState.inactive:
        UserStateMethods().setUserState(
            userId: currentuserid,
            userState: UserState.offLine,
            userRole: widget.userRole);
        break;
      case AppLifecycleState.paused:
        UserStateMethods().setUserState(
            userId: currentuserid,
            userState: UserState.waiting,
            userRole: widget.userRole);
        break;
      case AppLifecycleState.detached:
        UserStateMethods().setUserState(
            userId: currentuserid,
            userState: UserState.offLine,
            userRole: widget.userRole);
        break;
      case AppLifecycleState.hidden:
        UserStateMethods().setUserState(
            userId: currentuserid,
            userState: UserState.offLine,
            userRole: widget.userRole);
        break;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Show interstitial ad when navigating between major sections
    if (index != _selectedIndex) {
      AdPlacement.onSectionNavigation();
    }
  }

  DateTime? _lastBackPress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_lastBackPress == null ||
            DateTime.now().difference(_lastBackPress!) >
                const Duration(seconds: 2)) {
          print('Back press detected');
          _lastBackPress = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.red.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                side: BorderSide(color: Colors.white, width: 1),
              ),
              content: Text('Press back disabled because you are home screen',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  )),
              duration: Duration(seconds: 3),
            ),
          );
        }
        if (didPop) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                  )),
              content: const Text('Are you sure you want to exit the app?',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ))),
                TextButton(
                    onPressed: () => UserStateMethods().logoutuser(context),
                    child: const Text('Exit',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ))),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        extendBody: false, // Changed to false to prevent content overlap
        body: SafeArea(
          bottom:
              false, // Don't add safe area at bottom since we have custom nav
          child: Column(
            children: [
              // Disclaimer banner at top
              DisclaimerWidget.buildSmallDisclaimer(),
              // Main content
              Expanded(
                child: _widgetOptions[_selectedIndex],
              ),
              // Banner ad at bottom
              AdManager.getBannerAd(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: 80, // Increased height for better touch targets
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CurvedNavigationBar(
                height: 64.0, // Slightly reduced to fit in container
                backgroundColor: Colors.transparent,
                color: kPrimaryLightColor,
                buttonBackgroundColor: kPrimaryColor,
                animationDuration: const Duration(milliseconds: 400),
                index: _selectedIndex,
                items: [
                  _buildNavItem(Icons.dashboard_rounded, "Home", 0),
                  _buildNavItem(Icons.quiz_rounded, "Exams", 1),
                  _buildNavItem(Icons.traffic_rounded, "Rules", 2),
                  _buildNavItem(Icons.person_rounded, "Profile", 3),
                ],
                onTap: _onItemTapped,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 26, // Slightly larger icons
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontSize: 11, // Slightly smaller text
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
