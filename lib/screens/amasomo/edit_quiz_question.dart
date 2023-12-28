import 'dart:io';
import 'package:amategeko/components/text_field_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../backend/apis/db_connection.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'open_modified_quiz.dart';

class Edit1Question extends StatefulWidget {
  final String id,
      courseId,
      question,
      questionUrl,
      option1,
      option2,
      option3,
      option4,
      correctOption;

  const Edit1Question({
    super.key,
    required this.id,
    required this.question,
    required this.questionUrl,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.correctOption,
    required this.courseId,
  });

  @override
  State<Edit1Question> createState() => _Edit1QuestionState();
}

class _Edit1QuestionState extends State<Edit1Question> {
  final _formkey = GlobalKey<FormState>();
  String question = "", option1 = "", option2 = "";
  String option3 = "", option4 = "";
  String questionUrl = "";
  String correctAnswer = "";

  //adding controller
  late TextEditingController questionController;
  late TextEditingController correctController;
  late TextEditingController option1Controller;
  late TextEditingController option2Controller;
  late TextEditingController option3Controller;
  late TextEditingController option4Controller;
  bool _isLoading = false;
  final apiUrl = API.hostUser;
  List<File> _selectedImageFiles = [];

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
    questionController = TextEditingController(text: widget.question);
    option1Controller = TextEditingController(text: widget.option1);
    option2Controller = TextEditingController(text: widget.option2);
    option3Controller = TextEditingController(text: widget.option4);
    option4Controller = TextEditingController(text: widget.option4);
    correctController = TextEditingController(text: widget.correctOption);

    super.initState();
  }

  uploadQuizData() async {
    if (_formkey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final apiUrl = API.updateCourseQuestion;

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

        request.fields['id'] = widget.id;
        request.fields['question'] =
            question.isEmpty ? widget.question : question;
        request.fields['option1'] = option1.isEmpty ? widget.option1 : option1;
        request.fields['option2'] = option2.isEmpty ? widget.option2 : option2;
        request.fields['option3'] = option3.isEmpty ? widget.option3 : option3;
        request.fields['option4'] = option4.isEmpty ? widget.option4 : option4;
        request.fields['correctAnswer'] =
            correctAnswer.isEmpty ? widget.correctOption : correctAnswer;
        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var jsonResponse = json.decode(responseData);

          if (jsonResponse['created'] == true) {
            // // Handle successful creation
            // Fluttertoast.showToast(msg: 'Quizcreated successfully');
            // print('Quiz created successfully');
            // setState(() {
            //   _formkey.currentState!.reset();
            //   questionController.clear();
            //   option1Controller.clear();
            //   option2Controller.clear();
            //   option3Controller.clear();
            //   option4Controller.clear();
            //   correctController.clear();
            // });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OpenModifiedQuiz(
                  courseId: widget.courseId,
                ),
              ),
            );
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
        decoration: InputDecoration(
          icon: const Icon(
            Icons.question_answer_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Type Question.. ",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          question = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
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
        decoration: InputDecoration(
          hintText: "correct option.. ",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option1 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
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
        decoration: InputDecoration(
          hintText: "option 2.. ",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option2 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
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
        decoration: InputDecoration(
          hintText: "option 3.. ",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option3 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
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
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "option 4.. ",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option4 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
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
        decoration: InputDecoration(
          hintText: "correct answer.. ",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          correctAnswer = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
      ),
    );
    final addquestionBtn = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.5,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
            uploadQuizData();
          },
          child: const Text(
            "EDIT QUESTION",
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
            Navigator.pop(context);
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
          "Edit Questions",
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
                          (widget.questionUrl.isEmpty)
                              ? (_selectedImageFiles.isEmpty)
                                  ? Container()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Material(
                                            // display new updated image
                                            borderRadius:
                                                const BorderRadius.all(
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
                                    )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Material(
                                        // display new updated image
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(125.0)),
                                        clipBehavior: Clip.hardEdge,
                                        // display new updated image
                                        child: Image.network(
                                          apiUrl +
                                              "/${widget.questionUrl.toString()}",
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
                    height: size.height * 0.05,
                  ),
                  correctField,
                  SizedBox(
                    height: size.height * 0.05,
                  ),
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
