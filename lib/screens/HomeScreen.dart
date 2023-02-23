import 'package:amategeko/screens/homepages/nofications.dart';
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

class HomeScreen extends StatefulWidget {
  final String currentuserid;
  final String userRole;

  HomeScreen({Key? key, required this.currentuserid, required this.userRole})
      : super(key: key);

  @override
  _HomeScreenState createState() =>
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
          userState: UserState.Online,
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
                userState: UserState.Online,
                userRole: widget.userRole)
            : print("Resumed State");
        break;
      case AppLifecycleState.inactive:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.Offline,
                userRole: widget.userRole)
            : print("Inactive State");
        break;
      case AppLifecycleState.paused:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.Waiting,
                userRole: widget.userRole)
            : print("Paused State");
        break;
      case AppLifecycleState.detached:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.Offline,
                userRole: widget.userRole)
            : print("Detached State");
        break;
    }
  }

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;
  final String currentuserid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({
    Key? key,
  }) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  late SharedPreferences preferences;
  late String userRole = "";
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    const Home(), //index 0
    Quizzes(), //index 1
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
        // currentIndex: _selectedIndex,
        // selectedItemColor: kPrimaryColor,
        // selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        // unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
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
