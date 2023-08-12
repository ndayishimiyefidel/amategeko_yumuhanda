import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:random_string/random_string.dart';

import '../../components/text_field_container.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class CourseContent extends StatefulWidget {
  final String courseId;
  final isNew;

  const CourseContent({Key? key, required this.courseId, this.isNew})
      : super(key: key);

  @override
  State<CourseContent> createState() => _CourseContentState();
}

class _CourseContentState extends State<CourseContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController courseController = TextEditingController();
  String courseDesc = "";
  DatabaseService databaseService = DatabaseService();
  bool _isLoading = false;
  final picker = ImagePicker();
  UploadTask? uploadTask;
  File? pickedFile;
  String downloadImgUrl = "";
  String refId = randomAlphaNumeric(16);

  Future selectsFile() async {
    setState(() {
      _isLoading = true;
    });
    String filepath = 'courseImages/$refId';
    final pickedFiles = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFiles != null) {
        pickedFile = File(pickedFiles.path);
        _isLoading = false;
        print(pickedFile);
      }
    });
    if (pickedFile != null) {
      final refs = FirebaseStorage.instance.ref().child(filepath);
      uploadTask = refs.putFile(pickedFile!);
      final snapshot = await uploadTask!.whenComplete(() {});
      final downloadlink = await snapshot.ref.getDownloadURL();
      print("download link $downloadlink");
      downloadImgUrl = downloadlink.toString();
      Map<String, String> courseMap = {
        "courseId": widget.courseId,
        "courseImgUrl": downloadImgUrl,
      };
      databaseService.addCourseImages(courseMap, widget.courseId).then((value) {
        setState(() {
          _isLoading = false;
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text("image uploaded"),
                );
              });
        });
      });
    }
  }

  List<String> uploadedUrls = [];
  String downloadUrl = "";
  late String fileName;

  Future<void> uploadFilesToFirebaseStorage() async {
    List<File> files = [];
    // Allow the user to select multiple audio files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      files = result.paths.map((path) => File(path!)).toList();

      // Upload each file to Firebase Storage
      for (File file in files) {
        // String fileName = path.basename(file.path);
        fileName = 'audio/${path.basename(file.path)}';
        final refs = FirebaseStorage.instance.ref().child(fileName);
        UploadTask task = refs.putFile(file);
        final snapshot = await task.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          uploadedUrls.add(downloadUrl);
          print(downloadUrl);

          ///save to firestore
          saveAudioFiles();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final courseDescriptionField = TextFieldContainer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          autofocus: true,
          maxLines: 10,
          controller: courseController,
          keyboardType: TextInputType.text,
          onSaved: (value) {
            courseController.text = value!;
          },
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: "---------Course Content------",
            border: InputBorder.none,
          ),
          onChanged: (val) {
            courseDesc = val;
            print(courseDesc);
          },
          autovalidateMode: AutovalidateMode.disabled,
          validator: (input) => input!.isEmpty ? 'Enter course content' : null,
        ),
      ),
    );
    //quiz title field
    final createCourse = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.5,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
            uploadCourseData();
          },
          child: const Text(
            "Submit Data",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
          "Add course content",
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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  courseDescriptionField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Text(widget.courseId),
                  const Text(
                    "Please choose audio and image",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              uploadFilesToFirebaseStorage();
                            },
                            child: const Icon(Icons.keyboard_voice_outlined)),
                        ElevatedButton(
                            onPressed: () {
                              selectsFile();
                            },
                            child: const Icon(
                                Icons.photo_size_select_actual_outlined)),
                      ],
                    ),
                  ),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Container(
                          child: null,
                        ),
                  const SizedBox(height: 20),
                  // Text('Uploaded URLs:$uploadedUrls'),
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
                        children: [createCourse],
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

  Future<void> uploadCourseData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Map<String, String> courseMap = {
        "courseId": widget.courseId,
        'courseDesc': courseDesc,
      };
      await databaseService
          .addCourseData(courseMap, widget.courseId)
          .then((value) {
        setState(() {
          _isLoading = false;
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text("Course successfully"),
                );
              });
        });
      });
    }
  }

  Future<void> saveAudioFiles() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> courseMap = {
      "courseId": widget.courseId,
      "fileName": fileName,
      'downloadUrl': '$uploadedUrls',
    };
    await databaseService
        .addCourseAudio(courseMap, widget.courseId)
        .then((value) {
      setState(() {
        _isLoading = false;
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text("audio uploaded"),
              );
            });
      });
    });
  }
}
