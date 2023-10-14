import 'dart:io';

import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/quizzes/quizzes.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/constants.dart';
import '../homepages/notificationtab.dart';
import '../questions/add_question.dart';

class EditQuiz extends StatefulWidget {
  final String quizId, quizTitle, quizType, quizImage, quizDesc, quizPrice;

  const EditQuiz({
    Key? key,
    required this.quizId,
    required this.quizTitle,
    required this.quizType,
    required this.quizImage,
    required this.quizDesc,
    required this.quizPrice,
  }) : super(key: key);

  @override
  State<EditQuiz> createState() => _EditQuizState();
}

class _EditQuizState extends State<EditQuiz> {
  //from

  _EditQuizState() {
    _selectedtype = _quizType[0];
  }

  final _formkey = GlobalKey<FormState>();
  String quizUrl = "",
      quizTitle = "",
      quizDesc = "";
  String quizId = "";
  String _selectedtype = "";

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
  final TextEditingController quizurlController = TextEditingController();
  final TextEditingController quiztitleController = TextEditingController();
  final TextEditingController quizdescController = TextEditingController();
  final TextEditingController quizPriceController = TextEditingController();
  String quizPrice = "";
  final String _selectedType = "";

  @override
  void initState() {
    super.initState();

    ///initialize data
    quizurlController.text = widget.quizImage;
    quiztitleController.text = widget.quizTitle;
    quizdescController.text = widget.quizDesc;
    quizPriceController.text = widget.quizPrice;
  } //database service
  bool _isLoading = false;
  final bool isNew = true;
  DatabaseService databaseService = DatabaseService();
  final _firestore = FirebaseFirestore.instance;

  Future editOnlineQuiz() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      quizId = widget.quizId;
      String filepath = 'images/$quizId';
      // final file = File(pickedFile!.path!);

      if (pickedFile == null) {
        quizUrl = widget.quizImage;
      } else {
        final refs = FirebaseStorage.instance.ref().child(filepath);
        uploadTask = refs.putFile(pickedFile!);

        final snapshot = await uploadTask!.whenComplete(() {});
        final downloadlink = await snapshot.ref.getDownloadURL();
        quizUrl = downloadlink.toString();
      }

      Map<String, String> quizMap = {
        "quizTitle": quiztitleController.text,
        "quizImgUrl": quizUrl.isEmpty ? widget.quizImage : quizUrl,
        "quizType": _selectedtype.isEmpty ? widget.quizType : _selectedtype,
        "quizDesc": quizdescController.text,
        "quizPrice": quizPriceController.text
      };
      await _firestore
          .collection("Quizmaker")
          .doc(widget.quizId)
          .update(quizMap)
          .then((value) {
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
    Size size = MediaQuery
        .of(context)
        .size;
    final quizPriceField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: quizPriceController,
        onSaved: (value) {
          quizPriceController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        // enabled: _selectedType == "Paid",
        decoration: const InputDecoration(
          icon: Icon(
            Icons.price_change_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Quiz Price ",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          quizPrice = val;
        },
      ),
    );
    //quiz title field
    final quiztitleField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: quiztitleController,
        onSaved: (value) {
          quiztitleController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.title_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Quiz Title ",
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
    final quizdescField = TextFormField(
      autofocus: false,
      controller: quizdescController,
      keyboardType: TextInputType.multiline,
      onSaved: (value) {
        quizdescController.text = value!;
      },
      textInputAction: TextInputAction.done,
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: "Description ",
        border: OutlineInputBorder(),
      ),
      onChanged: (val) {
        quizDesc = val;
      },
    );
    final quizTypeField = TextFieldContainer(
      child: DropdownButtonFormField(
        value: widget.quizType.isEmpty ? _selectedtype : widget.quizType,
        items: _quizType
            .map((e) =>
            DropdownMenuItem(
              value: e,
              child: Text(e),
            ))
            .toList(),
        onChanged: (val) {
          setState(() {
            _selectedtype = val as String;
          });
        },
        icon: const Icon(
          Icons.arrow_drop_down_circle,
          // color: kPrimaryColor,
        ),
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          hintText: widget.quizType,
          border: InputBorder.none,
          prefixIcon: const Icon(
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
            editOnlineQuiz();
          },
          child: const Text(
            "EDIT QUIZ",
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
          "Edit Quiz",
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
                    "Edit quiz,it's simple and easy",
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
                                      imageUrl: widget.quizImage,
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    )),
                              ],
                            ),
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
                                      child: Image.file(
                                        pickedFile!,
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      )),
                                ],
                              ),
                          GestureDetector(
                            onTap: selectsFile,
                            child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 150.0, right: 120.0),
                                child: Row(
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
                  quiztitleField,
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
                  quizdescField,
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
                                return const Quizzes();
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
