import 'dart:io';

import 'package:amategeko/screens/add_question.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:random_string/random_string.dart';

import '../widgets/appbar.dart';
import 'old_quiz.dart';

class CreateQuiz extends StatefulWidget {
  const CreateQuiz({Key? key}) : super(key: key);

  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  //from
  final _formkey = GlobalKey<FormState>();
  String quizUrl = "", quizTitle = "", quizDesc = "";
  String quizId = "";
  //select file
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  Future selectsFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  //adding controller
  final TextEditingController quizurlController = new TextEditingController();
  final TextEditingController quiztitleController = new TextEditingController();
  final TextEditingController quizdescController = new TextEditingController();
  //database service
  bool _isLoading = false;
  DatabaseService databaseService = new DatabaseService();

  Future createquizOnline() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final filepath = 'images/${pickedFile!.name}';
      final file = File(pickedFile!.path!);

      final refs = FirebaseStorage.instance.ref().child(filepath);
      uploadTask = refs.putFile(file);

      final snapshot = await uploadTask!.whenComplete(() {});
      final downloadlink = await snapshot.ref.getDownloadURL();
      print("download link " + downloadlink);

      if (quizUrl == null) {
        quizUrl =
            "https://static.vecteezy.com/system/resources/thumbnails/005/862/378/small/traffic-light-sugnals-rules-blue-sky-background-free-vector.jpg";
      } else {
        quizUrl = downloadlink.toString();
      }

      print("download link " + quizUrl);
      quizId = randomAlphaNumeric(16);
      Map<String, String> quizMap = {
        "quizId": quizId,
        "quizTitle": quizTitle,
        "quizImgUrl": quizUrl,
        "quizDesc": quizDesc
      };
      await databaseService.addQuizData(quizMap, quizId).then((value) {
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddQuestion(quizId);
              },
            ),
          );
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //quiz url image
    final quizurlField = ElevatedButton(
      onPressed: selectsFile,
      child: Text("Select quiz image"),
    );
    //quiz title field
    final quiztitleField = TextFormField(
      autofocus: false,
      controller: quiztitleController,
      onSaved: (value) {
        quiztitleController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.title_outlined),
        contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        hintText: "Quiz title",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (val) {
        quizTitle = val;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (input) =>
          input != null && input.length < 5 ? 'Enter quiz title' : null,
    );
    //quiz desc
    final quizdescField = TextFormField(
      autofocus: false,
      controller: quizdescController,
      keyboardType: TextInputType.multiline,
      onSaved: (value) {
        quizdescController.text = value!;
      },
      textInputAction: TextInputAction.done,
      maxLines: 5,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        hintText: "Quiz description",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (val) {
        quizDesc = val;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (input) =>
          input != null && input.length < 5 ? 'Enter description' : null,
    );
    final createQuizBtn = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.blue[300],
      child: MaterialButton(
        padding: const EdgeInsets.all(15),
        minWidth: MediaQuery.of(context).size.width * 0.5,
        onPressed: () {
          createquizOnline();
        },
        child: const Text(
          'Create Quiz',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: appBar(context),
        leading: IconButton(
          color: Colors.black54,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const OldQuiz();
                },
              ),
            );
          },
        ),
      ),
      body: _isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(20),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "Create Quiz Maker",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: "Loto",
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Feel free to create quiz,it's simple and easy!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "Fasthand",
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(
                          height: 45,
                        ),
                        if (pickedFile != null)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(120),
                            ),
                            child: Center(
                              // child: Text(pickedFile!.name),
                              child: Image.file(
                                File(pickedFile!.path!),
                                width: double.infinity,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 25,
                        ),
                        quizurlField,
                        const SizedBox(
                          height: 25,
                        ),
                        quiztitleField,
                        const SizedBox(
                          height: 25,
                        ),
                        quizdescField,
                        const SizedBox(
                          height: 45,
                        ),
                        createQuizBtn,
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
