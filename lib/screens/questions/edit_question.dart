import 'dart:io';

import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/quizzes/open_quiz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import '../../services/database_service.dart';
import '../../utils/constants.dart';

class EditQuestion extends StatefulWidget {
  final String quizId,
      question,
      questionUrl,
      option1,
      option2,
      option3,
      option4,
      quizTitle;

  const EditQuestion({
    required this.quizId,
    required this.question,
    required this.questionUrl,
    required this.option1,
    required this.option2,
    required this.option3,
    required this.option4,
    required this.quizTitle,
  });

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  final _formkey = GlobalKey<FormState>();
  String question = "", option1 = "", option2 = "";
  String option3 = "", option4 = "";
  String questionUrl = "";

  //adding controller
  final TextEditingController questionController = TextEditingController();
  final TextEditingController option1Controller = TextEditingController();
  final TextEditingController option2Controller = TextEditingController();
  final TextEditingController option3Controller = TextEditingController();
  final TextEditingController option4Controller = TextEditingController();
  bool _isLoading = false;

  final picker = ImagePicker();
  UploadTask? uploadTask;
  File? pickedFile;

  Future selectsFile() async {
    final pickedFiles = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFiles != null) {
        pickedFile = File(pickedFiles.path);
        _isLoading = false;
      }
    });
  }

  //database service
  DatabaseService databaseService = DatabaseService();

  ///saving quiz data inside quiz
  ///creating map data

  @override
  void initState() {
    super.initState();
  }

  uploadQuizData() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      int totQuestion = 0;
      String refId = randomAlphaNumeric(16);
      String filepath = 'images/$refId';

      if (pickedFile == null) {
        questionUrl = "";
      } else {
        final refs = FirebaseStorage.instance.ref().child(filepath);
        uploadTask = refs.putFile(pickedFile!);
        final snapshot = await uploadTask!.whenComplete(() {});
        final downloadlink = await snapshot.ref.getDownloadURL();
        print("download link $downloadlink");
        questionUrl = downloadlink.toString();
      }
      Map<String, String> questionMap = {
        "question": question.isEmpty ? widget.question : question,
        "option1": option1.isEmpty ? widget.option1 : option1,
        "option2": option2.isEmpty ? widget.option2 : option2,
        "option3": option3.isEmpty ? widget.option3 : option3,
        "option4": option4.isEmpty ? widget.option4 : option4,
        "quizPhotoUrl": questionUrl.isEmpty ? widget.questionUrl : questionUrl,
      };

      ///check whether if the quiz is not filled
      ///using collection group
      await databaseService
          .updateQuestionData(questionMap, widget.quizId, widget.question)
          .then((value) {
        setState(() {
          _isLoading = false;
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text("Question changed successfully"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          _formkey.currentState!.reset();
                          questionController.clear();
                          option1Controller.clear();
                          option2Controller.clear();
                          option3Controller.clear();
                          option4Controller.clear();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return OpenQuiz(
                              quizId: widget.quizId,
                              title: widget.quizTitle,
                            );
                          }));
                        },
                        child: const Text("ok"))
                  ],
                );
              });
        });
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
        decoration: InputDecoration(
          icon: const Icon(
            Icons.question_answer_outlined,
            color: kPrimaryColor,
          ),
          hintText:
              widget.question.isEmpty ? "Type Question.. " : widget.question,
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
          hintText:
              widget.option1.isEmpty ? "correct option.. " : widget.option1,
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
          hintText: widget.option2.isEmpty ? "option 2.. " : widget.option2,
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
          hintText: widget.option3.isEmpty ? "option 3.. " : widget.option3,
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
          hintText: widget.option4.isEmpty ? "option 4.. " : widget.option4,
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option4 = val;
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
                              ? (pickedFile == null)
                                  ? Container()
                                  : Container(
                                      child: Row(
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
                                                pickedFile!,
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              )),
                                        ],
                                      ),
                                    )
                              : Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Material(
                                          // display new updated image
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(125.0)),
                                          clipBehavior: Clip.hardEdge,
                                          // display new updated image
                                          child: Image.network(
                                            widget.questionUrl.toString(),
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          )),
                                    ],
                                  ),
                                ),
                          GestureDetector(
                            onTap: selectsFile,
                            child: Padding(
                                padding: (pickedFile == null)
                                    ? const EdgeInsets.only(
                                        top: 0.0, right: 170.0)
                                    : const EdgeInsets.only(
                                        top: 150.0, right: 120.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
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
