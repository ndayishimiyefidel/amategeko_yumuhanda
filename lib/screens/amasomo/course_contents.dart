import 'package:amategeko/screens/amasomo/course_audio.dart';
import 'package:amategeko/screens/amasomo/course_description.dart';
import 'package:amategeko/screens/amasomo/create_question.dart';
import 'package:amategeko/screens/amasomo/open_modified_quiz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class CourseContents extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseContents(
      {Key? key, required this.courseId, required this.courseTitle})
      : super(key: key);

  @override
  State<CourseContents> createState() => _CourseContentsState();
}

class _CourseContentsState extends State<CourseContents> {
  bool isLoading = false;
  DatabaseService databaseService = DatabaseService();
  AuthService authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  late String email;
  late String photo;
  String? userRole;
  String? adminPhone;
  late String phone;
  String userToken = "";
  late int totalQuestion = 0;

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
    getCurrUserData(); //get login data
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            letterSpacing: 1.25,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {},
          )
        ],
        centerTitle: true,
      ),
     body: SingleChildScrollView(
  child: Column(
    children: [
      ReadText(quizId: widget.courseId, title: widget.courseTitle),
      const SizedBox(
        height: 10,
      ),
      ReadAudio(courseId: widget.courseId,userRole:userRole.toString(),),
      const SizedBox(
        height: 20,
      ),
      userRole == "Admin"
          ? Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => CreateQuestion(
                          courseId: widget.courseId,
                          courseTitle: widget.courseTitle,
                        ),
                      ),
                    );
                  },
                  child: const Text("Create Quiz"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => OpenModifiedQuiz(
                          courseId: widget.courseId,
                        ),
                      ),
                    );
                  },
                  child: const Text("Fungura Imyitozo"),
                ),
              ],
            )
          : ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => OpenModifiedQuiz(
                      courseId: widget.courseId,
                    ),
                  ),
                );
              },
              child: const Text("Kora Imyitozo"),
            ),
    ],
  ),
)

    );
  }
}
