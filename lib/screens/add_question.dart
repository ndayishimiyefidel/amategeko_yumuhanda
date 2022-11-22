import 'package:amategeko/screens/create_quiz.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../widgets/appbar.dart';

class AddQuestion extends StatefulWidget {
  final String quizId;
  const AddQuestion(this.quizId);

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  final _formkey = GlobalKey<FormState>();
  String question = "", option1 = "", option2 = "";
  String option3 = "", option4 = "";

  //adding controller
  final TextEditingController questionController = new TextEditingController();
  final TextEditingController option1Controller = new TextEditingController();
  final TextEditingController option2Controller = new TextEditingController();
  final TextEditingController option3Controller = new TextEditingController();
  final TextEditingController option4Controller = new TextEditingController();
  //database service
  bool _isLoading = false;
  DatabaseService databaseService = new DatabaseService();
  uploadQuizData() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Map<String, String> questionMap = {
        "question": question,
        "option1": option1,
        "option2": option2,
        "option3": option3,
        "option4": option4
      };
      await databaseService
          .addQuestionData(questionMap, widget.quizId)
          .then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionField = TextFormField(
      autofocus: false,
      controller: questionController,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        questionController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.question_answer_outlined),
        contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        hintText: "Question...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (val) {
        question = val;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (input) =>
          input != null && input.length < 1 ? 'Enter question' : null,
    );
    //quiz title field
    final option1Field = TextFormField(
      autofocus: false,
      controller: option1Controller,
      onSaved: (value) {
        option1Controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        hintText: "option 1",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (val) {
        option1 = val;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (input) =>
          input != null && input.length < 1 ? 'Enter option 1' : null,
    );
    //quiz desc
    final option2Field = TextFormField(
      autofocus: false,
      controller: option2Controller,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        option2Controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        hintText: "option 2",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (val) {
        option2 = val;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (input) =>
          input != null && input.length < 1 ? 'Enter option 2' : null,
    );
    final option3Field = TextFormField(
      autofocus: false,
      controller: option3Controller,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        option3Controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        hintText: "option 3",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (val) {
        option3 = val;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (input) =>
          input != null && input.length < 1 ? 'Enter option 3' : null,
    );
    final option4Field = TextFormField(
      autofocus: false,
      controller: option4Controller,
      keyboardType: TextInputType.multiline,
      onSaved: (value) {
        option4Controller.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        hintText: "option 4",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (val) {
        option4 = val;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (input) =>
          input != null && input.length < 1 ? 'Enter option 4' : null,
    );
    final addquestionBtn = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.blue[300],
      child: MaterialButton(
        padding: const EdgeInsets.all(15),
        minWidth: MediaQuery.of(context).size.width * 0.3,
        onPressed: () {
          uploadQuizData();
        },
        child: const Text(
          'Add question',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    final addsubmitBtn = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.blue[300],
      child: MaterialButton(
        padding: const EdgeInsets.all(15),
        minWidth: MediaQuery.of(context).size.width * 0.3,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'Submit question',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
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
                  return const CreateQuiz();
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
                  child: _isLoading
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Form(
                          key: _formkey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "Add Questions",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: "Loto",
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "Feel free to add question,it's simple and easy!",
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
                              questionField,
                              const SizedBox(
                                height: 25,
                              ),
                              option1Field,
                              const SizedBox(
                                height: 25,
                              ),
                              option2Field,
                              const SizedBox(
                                height: 25,
                              ),
                              option3Field,
                              const SizedBox(
                                height: 25,
                              ),
                              option4Field,
                              const SizedBox(
                                height: 45,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [addquestionBtn, addsubmitBtn],
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
