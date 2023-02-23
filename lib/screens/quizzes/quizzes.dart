import 'package:amategeko/screens/quizzes/new_quiz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/MainDrawer.dart';
import '../homepages/nofications.dart';
import 'create_quiz.dart';
import 'old_quiz.dart';

class Quizzes extends StatefulWidget {
  @override
  _QuizzesState createState() => _QuizzesState();
}

class _QuizzesState extends State<Quizzes> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        elevation: 0,
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: const Text(
          "Quizzes",
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
            scaffoldKey.currentState!.openDrawer();
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
      body: SingleChildScrollView(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DefaultTabController(
              length: 2, // length of tabs
              initialIndex: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Container(
                      child: const TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black26,
                        indicatorColor: Colors.black,
                        tabs: [
                          Tab(text: 'Quiz'),
                          Tab(text: 'Exam'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height *
                        0.68, //height of TabBarView
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: const TabBarView(
                      children: <Widget>[
                        // TodayAttendance(),
                        // OverallAttendance(),
                        OldQuiz(),
                        NewQuiz(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      //floating button

      floatingActionButton: userRole == "Admin"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CreateQuiz();
                    },
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  late String email;
  late String photo;
  String? userRole;
  late String phone;
  String userToken = "";

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      photo = preferences.getString("photo")!;
      phone = preferences.getString("phone")!;
      email = preferences.getString("email")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
  }
}
