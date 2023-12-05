import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../backend/apis/db_connection.dart';
import '../../components/text_field_container.dart';
import '../../utils/constants.dart';
import '../homepages/notificationtab.dart';
import 'package:http/http.dart' as http;

import 'course_content.dart';

class IsomoPage extends StatefulWidget {
  const IsomoPage({Key? key}) : super(key: key);

  @override
  State<IsomoPage> createState() => _IsomoPageState();
}

class _IsomoPageState extends State<IsomoPage> {
  final _formkey = GlobalKey<FormState>();
  String courseTitle = "", quizDesc = "";
  String courseId = "";
  String selectedCourseType = "Free";

  //adding controller
  final TextEditingController courseTitleController = TextEditingController();
  final TextEditingController coursePriceController = TextEditingController();
  final TextEditingController courseDescController = TextEditingController();

  String coursePrice = "";
  String courseDesc = "";

  //database service
  bool _isLoading = false;
  final bool isNew = true;

  Future createCourse() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      int dateFormat = DateTime.now().millisecondsSinceEpoch;
      Map<String, String> courseMap = {
        "courseTitle": courseTitle.trim().toString(),
        "coursePrice": coursePrice.trim().toString(),
        "courseType": selectedCourseType.toString(),
        "courseDesc": courseDesc.trim().toString(),
        "createdAt": dateFormat.toString()
      };
      final createCourseUrl = API.createCourse;
      try {
        final Response = await http.post(
          Uri.parse(createCourseUrl),
          body: courseMap,
        );

        if (Response.statusCode == 200) {
          final Result = jsonDecode(Response.body);

          if (Result['created'] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return CourseContent(
                    courseId: courseId,
                  );
                },
              ),
            );
          } else {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
            Fluttertoast.showToast(
                textColor: Colors.red,
                fontSize: 18,
                msg: Result['message'] ?? " Failed");
          }
        } else {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(
              textColor: Colors.red,
              fontSize: 18,
              msg: "Failed to connect to  api");
        }
      } catch (Error) {
        print(" Error: $Error");
        // Handle  API call error
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //quiz url image
    Size size = MediaQuery.of(context).size;
    final quizPriceField = TextFieldContainer(
      child: TextFormField(
        autofocus: true,
        controller: coursePriceController,
        onSaved: (value) {
          coursePriceController.text = value!;
        },
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        enabled: true,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.price_change_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Course Price",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          coursePrice = val;
          if (kDebugMode) {
            print(coursePrice);
          }
        },
      ),
    );
    //quiz title field
    final quizTitleField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: courseTitleController,
        onSaved: (value) {
          courseTitleController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.title_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Course Title",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          courseTitle = val;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (input) =>
            input != null && input.length < 5 ? 'Enter course title' : null,
      ),
    );
    //quiz desc
    //quiz title field
    final quizDescField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        maxLines: 5,
        controller: courseDescController,
        onSaved: (value) {
          courseDescController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: "Enter Course Descrition...",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          courseDesc = val;
        },
      ),
    );

    //quiz type
    final quizTypeField = TextFieldContainer(
      child: DropdownButtonFormField(
        value: selectedCourseType,
        items: [
          DropdownMenuItem(
            value: "Free",
            child: Text("Free"),
          ),
          DropdownMenuItem(
            value: "Paid",
            child: Text("Paid"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            selectedCourseType = value.toString();
          });
        },
        decoration: InputDecoration(
          labelText: "Course Type",
          icon: Icon(
            Icons.select_all_outlined,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );

    final createQuizBtn = Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      width: size.width * 0.7,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
            createCourse();
          },
          child: const Text(
            "Create Course",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Ishuri Online Course",
          style:
              TextStyle(letterSpacing: 1.25, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Notifications(),
                ),
              );
            },
          )
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  const Text(
                    "Create course.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 2),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  quizTypeField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  quizTitleField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  quizDescField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  selectedCourseType == "Paid" ? quizPriceField : SizedBox(),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  createQuizBtn,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  _isLoading
                      ? const LinearProgressIndicator()
                      : Container(
                          child: null,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
