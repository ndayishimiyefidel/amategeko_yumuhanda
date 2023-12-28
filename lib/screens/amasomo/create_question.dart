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
  String explainedText = "";
  List<File> _selectedImageFiles = [];

  //adding controller
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
      // Check if there are selected image files
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
          // Handle successful creation
          Fluttertoast.showToast(msg: 'Quizcreated successfully');
          print('Quiz created successfully');
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
          // Handle failure to create course content
          print('Failed to create course content');
          Fluttertoast.showToast(msg: 'Failed to create course content');
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
        autofocus: false,
        controller: questionController,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          questionController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.question_answer_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Type Question...",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          question = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter question' : null,
      ),
    );
    //quiz title field
    final option1Field = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: option1Controller,
        onSaved: (value) {
          option1Controller.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: "Option",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option1 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter option 1' : null,
      ),
    );
    //quiz desc
    final option2Field = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: option2Controller,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          option2Controller.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: "Option 2",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option2 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter option 2' : null,
      ),
    );
    final option3Field = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: option3Controller,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          option3Controller.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: "Option 3",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option3 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter option 3' : null,
      ),
    );
    final option4Field = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: option4Controller,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          option4Controller.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: "Option 4",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option4 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter option 4' : null,
      ),
    );
    final correctField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: correctController,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          correctController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          hintText: "Andika igisubizo cyukuri",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          correctAnswer = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) =>
            input!.isEmpty ? 'Andika igisubizo cyukuri' : null,
      ),
    );

    // final explaineField = TextFieldContainer(
    //   child: TextFormField(
    //     autofocus: false,
    //     controller: questionExplainedController,
    //     keyboardType: TextInputType.text,
    //     onSaved: (value) {
    //       correctController.text = value!;
    //     },
    //     textInputAction: TextInputAction.done,
    //     decoration: const InputDecoration(
    //       hintText: "Andika icyo igazeti ivuaga",
    //       border: InputBorder.none,
    //     ),
    //     onChanged: (val) {
    //       explainedText = val;
    //     },
    //     autovalidateMode: AutovalidateMode.disabled,
    //     // validator: (input) =>
    //     //     input!.isEmpty ? 'Andika igisubizo cyukuri' : null,
    //   ),
    // );
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
          child: const Text(
            "Save Question",
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
          child: const Text(
            "SUBMIT",
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
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add Questions",
          style: TextStyle(
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
                    "Course Title : ${widget.courseTitle}",
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
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(0.0),
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          (_selectedImageFiles.isEmpty)
                              ? Container()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Material(
                                        // display new updated image
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(125.0)),
                                        clipBehavior: Clip.hardEdge,
                                        // display new updated image
                                        child: Image.file(
                                          _selectedImageFiles.first,
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        )),
                                  ],
                                ),
                          GestureDetector(
                            onTap: pickImageFiles,
                            child: Padding(
                                padding: (_selectedImageFiles.isEmpty)
                                    ? const EdgeInsets.only(
                                        top: 0.0, right: 170.0)
                                    : const EdgeInsets.only(
                                        top: 150.0, right: 120.0),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 25.0,
                                      child: Icon(
                                        Icons.photo,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
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
                  // explaineField,
                  // SizedBox(
                  //   height: size.height * 0.05,
                  // ),
                  _isLoading
                      ? const CircularProgressIndicator()
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
                      ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
