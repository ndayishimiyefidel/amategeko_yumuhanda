import 'package:amategeko/screens/amasomo/course_content.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

import '../../components/text_field_container.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../homepages/notificationtab.dart';

class IsomoPage extends StatefulWidget {
  const IsomoPage({Key? key}) : super(key: key);

  @override
  State<IsomoPage> createState() => _IsomoPageState();
}

class _IsomoPageState extends State<IsomoPage> {
  final _formkey = GlobalKey<FormState>();
  String courseTitle = "", quizDesc = "";
  String courseId = "";

  //adding controller
  final TextEditingController courseTitleController = TextEditingController();
  final TextEditingController coursePriceController = TextEditingController();
  String coursePrice = "";

  //database service
  bool _isLoading = false;
  final bool isNew = true;
  DatabaseService databaseService = DatabaseService();

  Future createCourse() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      courseId = randomAlphaNumeric(16);
      Map<String, String> courseMap = {
        "courseId": courseId,
        "courseTitle": courseTitle,
        "quizPrice": coursePrice
      };
      await databaseService.createCourseData(courseMap, courseId).then((value) {
        setState(() {
          _isLoading = false;
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
        });
      });
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
          print(coursePrice);
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
                  builder: (BuildContext context) => Notifications(),
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
                  quizTitleField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  quizPriceField,
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
