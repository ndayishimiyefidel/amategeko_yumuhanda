import 'dart:convert';

import 'package:amategeko/screens/amasomo/create_question.dart';
import 'package:amategeko/screens/amasomo/open_modified_quiz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';
import '../../utils/constants.dart';
import '../irembo/courses_widget .dart';

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
  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  late String photo;
  String? userRole;
  String? adminPhone;
  late String phone;
  String userToken = "";
  late int totalQuestion = 0;
  int itemsPerPage = 10;
  int currentPage = 0;
  List<Map<String, dynamic>> allCoursesList = [];

  int from = 0;
  int totalRows = 0;
  int to = 10; // Initial range, fetch the first 10 records

  Future<void> fetchAllCourseContent() async {
    final apiUrl = API.openCourseContent +
        "?courseId=${widget.courseId}&from=$from&to=$to";
    isLoading = true;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Response data:$data");

        if (data['success'] == true) {
          if (!mounted) return;
          setState(() {
            if (from == 0) {
              // If it's the first load, clear the list
              allCoursesList.clear();
            }
            // Append the new data to the existing list
            allCoursesList
                .addAll(List<Map<String, dynamic>>.from(data['data']));
            if (!mounted) return;
            setState(() {
              isLoading = false;
              totalRows = int.tryParse(data['total'])!.toInt();
            });

            // Update 'from' and 'to' for the next load
            from = to;
            to += 10; // Fetch the next 10 records
          });
        } else {
          print("Failed to execute query");
        }
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print("Error occurs: $e");
    }
  }

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
    getCurrUserData(); //get login data
    fetchAllCourseContent();
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
              !isLoading
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (allCoursesList.isEmpty)
                            const Center(
                              child: Text("no courses available right now!"),
                            )
                          else
                            Column(
                              children: [
                                ListView.builder(
                                  padding: const EdgeInsets.only(top: 16),
                                  itemCount: allCoursesList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final data = allCoursesList[index];

                                    final audio = data['audios'];
                                    final img = data['images'];
                                    var d, imge;
                                    if (audio != "") {
                                      d = (data["audios"] ?? '').split(',');
                                    } else {
                                      d = <String>[];
                                      ;
                                    }
                                    if (img != "") {
                                      imge = (data["images"] ?? '').split(',');
                                    } else {
                                      imge = <String>[];
                                    }

                                    return CourseContentList(
                                      id: data["id"] ?? '',
                                      audios: d,
                                      images: imge,
                                      description: data["description"] ?? '',
                                    );
                                  },
                                ),
                              ],
                            ),
                          if (to <=
                              totalRows) // Show "Load More" button if there are more records
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  isLoading = true;
                                  fetchAllCourseContent(); // Load more records
                                },
                                child: const Text("Load More"),
                              ),
                            ),
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
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
                                builder: (BuildContext context) =>
                                    CreateQuestion(
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
                                builder: (BuildContext context) =>
                                    OpenModifiedQuiz(
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
        ));
  }
}
