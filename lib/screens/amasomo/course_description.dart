import 'package:amategeko/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../enume/models/text_model.dart';

class ReadText extends StatefulWidget {
  final String quizId;
  final String title;

 const  ReadText({
    super.key,
    required this.quizId,
    required this.title,
  });

  @override
  State<ReadText> createState() => _ReadTextState();
}

String courseId = "";
String courseTitle = "";

class _ReadTextState extends State<ReadText> with SingleTickerProviderStateMixin {
  DatabaseService databaseService = DatabaseService();
  QuerySnapshot? questionSnapshot;
  late AnimationController _controller;
  final limitTime = 1200;

  TextModel getTextModelFromDatasnapshot(DocumentSnapshot questionSnapshot) {
    TextModel textModel = TextModel(courseTitle, courseId);
    textModel.courseText = questionSnapshot['courseDesc'];
    textModel.courseId = questionSnapshot['courseId'];
    return textModel;
  }


  @override
  void initState() {
    databaseService.getCourseText(widget.quizId).then((value) {
      questionSnapshot = value;
      setState(() {});
    });
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: limitTime));
    _controller.addListener(() {});
    _controller.forward();
    super.initState();
  }

  bool isFABExtended = false;

  
  @override
  void dispose() {
    if (_controller.isAnimating || _controller.isCompleted) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.quizId)
          .collection("course-text")
          .get(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  physics: const PageScrollPhysics(),
                  itemCount: questionSnapshot?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: TextTile(
                        textModel: getTextModelFromDatasnapshot(
                          questionSnapshot!.docs[index],
                        ),
                        index: index,
                        courseId: widget.quizId,
                        courseTitle: widget.title,
                      ),
                    );
                  },
                ),
              );
            }
        }
      },
    );
  }
}

class TextTile extends StatefulWidget {
  final TextModel textModel;
  final int index;
  final String courseId;
  final String courseTitle;

  const TextTile({
    super.key,
    required this.textModel,
    required this.index,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<TextTile> createState() => _TextTileState();
}

class _TextTileState extends State<TextTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: SingleChildScrollView(
        child: Text(
          widget.textModel.courseText,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  String userRole = "";

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
  }
}
