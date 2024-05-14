import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import '../../widgets/MainDrawer.dart';
import 'package:amategeko/components/amabwiriza.dart';
import 'package:amategeko/widgets/custom_widget.dart';
import 'package:amategeko/screens/quizzes/new_quiz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Exams extends StatefulWidget {
  const Exams({super.key});

  @override
  State createState() => _ExamsState();
}

class _ExamsState extends State<Exams> with SingleTickerProviderStateMixin {
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
          "Exams",
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
      body: const NewQuiz(),
      //floating button

      // floatingActionButton: userRole == "Admin"
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) {
      //                 return const CreateQuiz();
      //               },
      //             ),
      //           );
      //         },
      //         child: const Icon(Icons.add),
      //       )
      //     : null,
    );
  }

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  String? userRole;
  late String phone;

  getCurrUserData() async {
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
  }
}
