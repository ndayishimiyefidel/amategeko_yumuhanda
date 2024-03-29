import 'dart:io';

import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/quizzes/quizzes.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import '../../utils/constants.dart';
import '../homepages/notificationtab.dart';
import '../questions/add_question.dart';

class CreateQuiz extends StatefulWidget {
  const CreateQuiz({Key? key}) : super(key: key);

  @override
  State<CreateQuiz> createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {
  //from

  _CreateQuizState() {
    _selectedType = _quizType[0];
  }

  final _formkey = GlobalKey<FormState>();
  String quizUrl = "", quizTitle = "", quizDesc = "";
  String quizId = "";
  String _selectedType = "";

  //select file
  // PlatformFile? pickedFile;
  final picker = ImagePicker();
  UploadTask? uploadTask;
  File? pickedFile;

  Future selectsFile() async {
    final pickedFiles = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFiles != null) {
        pickedFile = File(pickedFiles.path);
        _isLoading = true;
      }
    });
  }

  final _quizType = ["Free", "Paid"];

  //adding controller
  final TextEditingController quizUrlController = TextEditingController();
  final TextEditingController quizTitleController = TextEditingController();
  final TextEditingController quizDescController = TextEditingController();
  final TextEditingController quizPriceController = TextEditingController();
  String quizPrice = "";

  //database service
  bool _isLoading = false;
  final bool isNew = true;
  DatabaseService databaseService = DatabaseService();

  Future createquizOnline() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      quizId = randomAlphaNumeric(16);
      String filepath = 'images/$quizId';
      // final file = File(pickedFile!.path!);

      if (pickedFile == null) {
        quizUrl =
            "https://media.gettyimages.com/id/1311206139/vector/stop-sign.jpg?s=612x612&w=gi&k=20&c=LLieTSmvLgus4NJFlsiGoL3P7qTYO3WNMql0SF7uOZA=";
      } else {
        final refs = FirebaseStorage.instance.ref().child(filepath);
        uploadTask = refs.putFile(pickedFile!);

        final snapshot = await uploadTask!.whenComplete(() {});
        final downloadlink = await snapshot.ref.getDownloadURL();
        print("download link $downloadlink");
        quizUrl = downloadlink.toString();
      }

      print("download link $quizUrl");

      Map<String, String> quizMap = {
        "quizId": quizId,
        "quizTitle": quizTitle,
        "quizImgUrl": quizUrl,
        "quizType": _selectedType,
        "quizDesc": quizDesc,
        "quizPrice": quizPrice
      };
      await databaseService.addQuizData(quizMap, quizId).then((value) {
        setState(() {
          _isLoading = false;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddQuestion(
                  quizId: quizId,
                  quizTitle: quizTitle,
                  isNew: isNew,
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
        autofocus: false,
        controller: quizPriceController,
        onSaved: (value) {
          quizPriceController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        enabled: _selectedType == "Paid",
        decoration: const InputDecoration(
          icon: Icon(
            Icons.price_change_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Quiz Price",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          quizPrice = val;
          print(quizPrice);
        },
      ),
    );
    //quiz title field
    final quizTitleField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: quizTitleController,
        onSaved: (value) {
          quizTitleController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.title_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Quiz Title",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          quizTitle = val;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (input) =>
            input != null && input.length < 5 ? 'Enter quiz title' : null,
      ),
    );
    //quiz desc
    final quizDescField = TextFormField(
      autofocus: false,
      controller: quizDescController,
      keyboardType: TextInputType.multiline,
      onSaved: (value) {
        quizDescController.text = value!;
      },
      textInputAction: TextInputAction.done,
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: "Quiz description",
        border: OutlineInputBorder(),
      ),
      onChanged: (val) {
        quizDesc = val;
      },
      autovalidateMode: AutovalidateMode.disabled,
    );
    final quizTypeField = TextFieldContainer(
      child: DropdownButtonFormField(
        value: _selectedType,
        items: _quizType
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (val) {
          setState(() {
            _selectedType = val as String;
            print(_selectedType);
            if (_selectedType == "Free") {}
          });
        },
        icon: const Icon(
          Icons.arrow_drop_down_circle,
          // color: kPrimaryColor,
        ),
        dropdownColor: Colors.white,
        decoration: const InputDecoration(
          hintText: "Quiz Type",
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.quiz_outlined,
            color: kPrimaryColor,
          ),
        ),
      ),
    );
    final createQuizBtn = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.7,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
            createquizOnline();
          },
          child: const Text(
            "CREATE QUIZ",
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
          "Create Quizzes",
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
                    "QUIZ  MAKER",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 2),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  const Text(
                    "Create quiz,it's simple and easy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black26,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          (pickedFile == null)
                              ? Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Material(
                                          // display already existing image
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(125.0)),
                                          clipBehavior: Clip.hardEdge,
                                          // display already existing image
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                              width: 200.0,
                                              height: 200.0,
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.lightBlueAccent),
                                              ),
                                            ),
                                            imageUrl:
                                                "https://media.gettyimages.com/id/1311206139/vector/stop-sign.jpg?s=612x612&w=gi&k=20&c=LLieTSmvLgus4NJFlsiGoL3P7qTYO3WNMql0SF7uOZA=",
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
                                          child: Image.file(
                                            pickedFile!,
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
                                padding: const EdgeInsets.only(
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
                  quizTitleField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  quizTypeField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  quizPriceField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  quizDescField,
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
                  SizedBox(height: size.height * 0.03),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      const Text(
                        "Add question to existing quiz? ",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return Quizzes();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      )
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
