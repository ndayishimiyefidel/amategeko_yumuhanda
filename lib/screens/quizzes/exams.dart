import 'package:flutter/material.dart';
import '../../widgets/MainDrawer.dart';
import '../../widgets/ModernAppBar.dart';
import 'package:rwanda_traffic_rules/components/amabwiriza.dart';

import 'package:rwanda_traffic_rules/screens/quizzes/new_quiz.dart';
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
      appBar: ModernAppBar(
        title: 'Exams',
        subtitle: 'Practice Tests',
        onMenuPressed: () {
          scaffoldKey.currentState!.openDrawer();
        },
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AmabwirizaList(),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.rule_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Rules',
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
