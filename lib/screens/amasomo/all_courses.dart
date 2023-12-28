import 'package:amategeko/components/amabwiriza.dart';
import 'package:amategeko/screens/amasomo/course_contents.dart';
import 'package:amategeko/utils/generate_code.dart';
import 'package:amategeko/widgets/custom_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../backend/apis/db_connection.dart';
import '../../utils/constants.dart';
import '../../widgets/ProgressWidget.dart';
import '../../widgets/fcmWidget.dart';
import 'course_content.dart';
import 'isomo_page.dart';

class AllCourse extends StatefulWidget {
  const AllCourse({Key? key}) : super(key: key);

  @override
  State<AllCourse> createState() => _AllCourseState();
}

class _AllCourseState extends State<AllCourse> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<dynamic>? courseStream;
  bool isLoading = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  late String email;
  late String photo;
  String? userRole;
  String? adminPhone;
  int examno = 0;
  late String phone;
  String userToken = "";
  late int totalQuestion = 0;
  int itemsPerPage = 10;
  int currentPage = 0;
  List<Map<String, dynamic>> allCoursesList = [];

  int from = 0;
  int totalRows = 0;
  int to = 10; // Initial range, fetch the first 10 records

  Future<void> fetchAllCourses() async {
    final apiUrl = API.courseList + "?from=$from&to=$to";
    isLoading = true;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);

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

  Future<void> getToken() async {
    final url = API.getToken; // Replace with your PHP script URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final adminData = data['data'];
          userToken = adminData['fcmToken'];
          adminPhone = adminData['phone'];
          print(adminPhone);
        } else {
          // Handle the case when there is no admin or other errors
        }
      } else {
        // Handle HTTP request errors
        print("failed to connect to server");
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
    }
  }

  @override
  void initState() {
    ////
    ///update
    _messaging.getToken().then((value) {
      if (kDebugMode) {
        print("My token is $value");
      }
    });

    //check code
    getCurrUserData(); //get login data
    fetchAllCourses();
    requestPermission(); //request permission
    loadFCM(); //load fcm
    listenFCM(); //list fcm
    getToken(); //get admin token
    FirebaseMessaging.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Ishuri Online",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
        //appbar
        key: _scaffoldKey,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: !isLoading
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
                                return CourseTile(
                                  index: index,
                                  courseId: data['courseId'] ?? '',
                                  title: data["courseTitle"] ?? '',
                                  totalCourses: totalQuestion,
                                  userRole: userRole.toString(),
                                  userToken: userToken,
                                  senderName: currentusername,
                                  currentUserId: currentuserid,
                                  phone: phone,
                                  coursePrice: data["coursePrice"] ?? '',
                                  adminPhone: adminPhone.toString(),
                                  courseDesc: data['courseDesc'] ?? '',
                                  courseType: data['courseType'] ?? '',
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
                              fetchAllCourses(); // Load more records
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
        ),
        floatingActionButton: (userRole == "Admin")
            ? FloatingActionButton.extended(
                label: const Row(
                  children: [
                    Text(
                      "Create Course",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const IsomoPage(),
                    ),
                  );
                },
              )
            : null);
  }

  Future<void> requestCode(
      String userId, String quizId, String senderName, String title) async {
    final url = API.requestCode;
    final sabaCodeUrl = API.sabaCode;
    final int exam = 0;
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName naho nimero ya telefoni ni  Namaze kwishyura amafaranga 1500 kuri 0788659575 yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': currentuserid, 'ex_type': exam.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print('Response Body: $data');
        if (data['success'] == true) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text(
                      "Your request have been already sent,Please wait the team is processing it."),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"))
                  ],
                );
              });
        } else {
          try {
            final res = await http.post(
              Uri.parse(sabaCodeUrl),
              body: {
                'userId': currentuserid.toString(),
                'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
                "phone": phone.toString(),
                "name": currentusername,
                "ex_type": exam.toString()
              },
            );
            print(res.body);

            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              print('Response Body: $data');
              if (data['requestSent'] == true) {
                //handle if not sent
                sendPushMessage(userToken, body, notificationTitle);
                isLoading = false;

                Size size = MediaQuery.of(context).size;
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text(
                            "Ubusabe bwawe bwakiriwe neza, Kugirango ubone kode ikwinjiza muri exam banza wishyure."),
                        actions: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            width: size.width * 0.7,
                            height: size.height * 0.07,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor),
                                onPressed: () async {
                                  //direct phone call
                                  await FlutterPhoneDirectCaller.callNumber(
                                      "*182*8*1*329494*1500#");
                                },
                                child: const Text(
                                  "Ishyura 1500 Rwf.",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Okay"))
                        ],
                      );
                    });
              } else {
                Fluttertoast.showToast(
                  msg: "Faild to request code",
                  textColor: Colors.red,
                  fontSize: 10,
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: "Faild to connect to api",
                textColor: Colors.red,
                fontSize: 10,
              );
            }
          } catch (e) {
            // Handle exceptions
            print("Error: $e");
            // You can show an error message or perform other error handling as needed
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Faild to connect to api",
          textColor: Colors.red,
          fontSize: 10,
        );
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      // You can show an error message or perform other error handling as needed
    }
  }
}

class CourseTile extends StatefulWidget {
  final String title;
  final String courseId;
  final int totalCourses;
  final String userRole;
  final String userToken;
  final String adminPhone;
  final String senderName;
  final String phone;
  final String currentUserId;
  final String coursePrice, courseType, courseDesc;

  final int index;

  const CourseTile({
    Key? key,
    required this.title,
    required this.courseId,
    required this.totalCourses,
    required this.userToken,
    required this.senderName,
    required this.phone,
    required this.currentUserId,
    required this.userRole,
    required this.coursePrice,
    required this.adminPhone,
    required this.index,
    required this.courseType,
    required this.courseDesc,
  }) : super(key: key);

  @override
  State<CourseTile> createState() => _CourseTileState();
}

class _CourseTileState extends State<CourseTile> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: kPrimaryColor,
                width: size.width * 0.001,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: InkWell(
              splashColor: kPrimaryColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child:
                                  Text("${widget.index + 1}. ${widget.title}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.start),
                            ),
                            GestureDetector(
                              onTap: () {
                                //all
                                if (widget.userRole == "Admin" ||
                                    widget.courseType == "Free") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CourseContents(
                                            courseId: widget.courseId,
                                            courseTitle: widget.title);
                                      },
                                    ),
                                  );
                                } else {
                                  navigateToIshuli(widget.currentUserId);
                                }
                              },
                              child: const Icon(
                                Icons.next_plan_outlined,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      _isLoading
                          ? circularprogress()
                          : Container(
                              child: null,
                            ),
                      (widget.userRole == "Admin")
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.height * 0.03,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return CourseContent(
                                                  isNew: false,
                                                  courseId: widget.courseId,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Add Content",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 0.03,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                kPrimaryLightColor),
                                        onPressed: () {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          final deleteApiUrl = API.deleteCourse;
                                          GenerateUser.deleteUserCode(
                                              context,
                                              widget.courseId,
                                              deleteApiUrl,
                                              widget.title,
                                              "course deleted successfully!");
                                        },
                                        child: const Text(
                                          "Delete course",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          : Container(
                              child: null,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToIshuli(String currentUserId) async {
    final url = API.navigateToIshuri; // Replace with your PHP script URL

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': widget.currentUserId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        if (data['success'] == true) {
          if (data['hasCode'] == true) {
            if (!mounted) return;
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CourseContents(
                        courseId: widget.courseId, courseTitle: widget.title);
                  },
                ),
              );
            });
          } else {
            if (!mounted) return;
            setState(() {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text(
                          "Ntabwo wemerewe gufungura isomo, Hamagara iyi nimero 0788659575 bagufashe.Murakoze "),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Close"))
                      ],
                    );
                  });
            });
          }
        } else {
          // Handle other error cases
        }
      } else {
        // Handle HTTP request errors
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      // You can show an error message or perform other error handling as needed
    }
  }
}
