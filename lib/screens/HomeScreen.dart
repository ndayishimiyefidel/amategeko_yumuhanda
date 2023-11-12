// ignore_for_file: unnecessary_null_comparison, avoid_print
import 'package:amategeko/screens/quizzes/quizzes.dart';
import 'package:amategeko/screens/rules/amategeko_yose.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enume/user_state.dart';
import '../resources/user_state_methods.dart';
import '../utils/constants.dart';
import 'accounts/AccountSettingsPage.dart';
import 'homepages/dashboard.dart';
import 'homepages/notificationtab.dart';

class HomeScreen extends StatefulWidget {
  final String currentuserid;
  final String userRole;

  const HomeScreen(
      {Key? key, required this.currentuserid, required this.userRole})
      : super(key: key);

  @override
  State createState() =>
      // ignore: no_logic_in_create_state
      _HomeScreenState(currentuserid: currentuserid, userRole: userRole);
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  _HomeScreenState({required this.currentuserid, required String userRole});

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
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.onLine,
                userRole: widget.userRole)
            : print("Resumed State");
        break;
      case AppLifecycleState.inactive:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.offLine,
                userRole: widget.userRole)
            : print("Inactive State");
        break;
      case AppLifecycleState.paused:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.waiting,
                userRole: widget.userRole)
            : print("Paused State");
        break;
      case AppLifecycleState.detached:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.offLine,
                userRole: widget.userRole)
            : print("Detached State");
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
  }

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;
  final String currentuserid;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Override the back button behavior
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => LoginScreen()),
        //   (route) => false,
        // );
        // SystemNavigator.pop();
        return false; // Return false to prevent default back button behavior
      },
      child: const Scaffold(
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  late SharedPreferences preferences;
  late String userRole = "";
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const Home(), //index 0
    const Quizzes(), //index 1
    const Notifications(), //index 2// index 3
    const AmategekoYose(), //index 4
    UserSettings(), //index 5
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      userRole = preferences.getString("role")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65.0,
        backgroundColor: Colors.white,
        color: kPrimaryLightColor,
        buttonBackgroundColor: kPrimaryLightColor,
        items: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.dashboard_customize,
              color: _selectedIndex == 0 ? kPrimaryColor : Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.quiz_outlined,
              color: _selectedIndex == 1 ? kPrimaryColor : Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.notifications_outlined,
              color: _selectedIndex == 2 ? kPrimaryColor : Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.traffic_outlined,
              color: _selectedIndex == 3 ? kPrimaryColor : Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.person_outline,
              color: _selectedIndex == 4 ? kPrimaryColor : Colors.black,
            ),
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
  }
}
