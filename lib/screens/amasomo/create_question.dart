import 'dart:convert';
import 'dart:io';
import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/amasomo/all_courses.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';
import '../../utils/constants.dart';
import '../../widgets/apptext.dart';

class CreateQuestion extends StatefulWidget {
  final String courseId;
  final String? courseTitle;

  const CreateQuestion({
    super.key,
    required this.courseId,
    this.courseTitle,
  });

  @override
  State<CreateQuestion> createState() => _CreateQuestionState();
}

class _CreateQuestionState extends State<CreateQuestion> {
  final _formkey = GlobalKey<FormState>();
  String question = "", option1 = "", option2 = "";
  String option3 = "", option4 = "";
  String questionUrl = "";
  String correctAnswer = "";
  List<File> _selectedImageFiles = [];

  final TextEditingController questionController = TextEditingController();
  final TextEditingController correctController = TextEditingController();
  final TextEditingController questionExplainedController =
      TextEditingController();
  final TextEditingController option1Controller = TextEditingController();
  final TextEditingController option2Controller = TextEditingController();
  final TextEditingController option3Controller = TextEditingController();
  final TextEditingController option4Controller = TextEditingController();
  bool _isLoading = false;

  Future<void> pickImageFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _selectedImageFiles =
            result.files.map((file) => File(file.path!)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> uploadCourseQuizData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final apiUrl = API.createCourseQuiz;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      if (_selectedImageFiles.isNotEmpty) {
        for (var imageFile in _selectedImageFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('image[]', imageFile.path),
          );
        }
      }

      request.fields['courseId'] = widget.courseId;
      request.fields['question'] = question;
      request.fields['option1'] = option1;
      request.fields['option2'] = option2;
      request.fields['option3'] = option3;
      request.fields['option4'] = option4;
      request.fields['correctAnswer'] = correctAnswer;
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        if (jsonResponse['created'] == true) {
          Fluttertoast.showToast(msg: AppText.quizCreatedSuccess);
          setState(() {
            _formkey.currentState!.reset();
            questionController.clear();
            option1Controller.clear();
            option2Controller.clear();
            option3Controller.clear();
            option4Controller.clear();
            correctController.clear();
          });
        } else {
          Fluttertoast.showToast(msg: AppText.quizCreationFailed);
        }
        if (!mounted) return;
        setState(() {
          _selectedImageFiles = [];
          _isLoading = false;
        });
      } else {
        print('Failed to upload files. Status code: ${response.statusCode}');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error uploading files: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final questionField = TextFieldContainer(
      child: TextFormField(
        decoration: InputDecoration(
          icon: Icon(
            Icons.question_answer_outlined,
            color: kPrimaryColor,
          ),
          hintText: AppText.typeQuestionHint,
          border: InputBorder.none,
        ),
        onChanged: (val) {
          question = val;
        },
        validator: (input) => input!.isEmpty ? AppText.questionError : null,
      ),
    );

    final option1Field = TextFieldContainer(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "${AppText.optionHint} 1",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option1 = val;
        },
        validator: (input) => input!.isEmpty ? AppText.optionError : null,
      ),
    );

    final option2Field = TextFieldContainer(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "${AppText.optionHint} 2",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option2 = val;
        },
        validator: (input) => input!.isEmpty ? AppText.optionError : null,
      ),
    );

    final option3Field = TextFieldContainer(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "${AppText.optionHint} 3",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option3 = val;
        },
        validator: (input) => input!.isEmpty ? AppText.optionError : null,
      ),
    );

    final option4Field = TextFieldContainer(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "${AppText.optionHint} 4",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option4 = val;
        },
        validator: (input) => input!.isEmpty ? AppText.optionError : null,
      ),
    );

    final correctField = TextFieldContainer(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: AppText.correctAnswerHint,
          border: InputBorder.none,
        ),
        onChanged: (val) {
          correctAnswer = val;
        },
        validator: (input) => input!.isEmpty ? AppText.correctAns : null,
      ),
    );

    final addquestionBtn = SizedBox(
      width: size.width * 0.4,
      height: size.height * 0.05,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
            uploadCourseQuizData();
          },
          child: Text(
            AppText.saveQuestionButton,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    final addsubmitBtn = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.5,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryLightColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const AllCourse(),
              ),
            );
          },
          child: Text(
            AppText.submitButton,
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppText.addQuestionsTitle,
          style: TextStyle(
            letterSpacing: 1.25,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
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
                  Text(
                    "${AppText.courseTitleLabel} : ${widget.courseTitle}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  questionField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  option1Field,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  option2Field,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  option3Field,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  option4Field,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  correctField,
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : Container(
                          child: null,
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            addquestionBtn,
                            const SizedBox(
                              height: 20,
                            ),
                            addsubmitBtn,
                          ],
                        ),
                      ),
                    ],
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
