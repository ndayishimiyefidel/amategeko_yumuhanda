import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../backend/apis/db_connection.dart';
import '../../components/text_field_container.dart';
import '../../utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

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
  final TextEditingController _descriptionController = TextEditingController();
  String _courseDescription = '';
  List<File> _selectedAudioFiles = [];
  List<File> _selectedImageFiles = [];
  bool _isLoading = false;

  Future<void> pickAudioFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _selectedAudioFiles =
            result.files.map((file) => File(file.path!)).toList();
      });
    }
  }

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

  Future<void> uploadFiles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final apiUrl = API.uploadContent; // Replace with your server URL

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Check if there are selected audio files
      if (_selectedAudioFiles.isNotEmpty) {
        for (var audioFile in _selectedAudioFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('audio[]', audioFile.path),
          );
        }
      }

      // Check if there are selected image files
      if (_selectedImageFiles.isNotEmpty) {
        for (var imageFile in _selectedImageFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('image[]', imageFile.path),
          );
        }
      }

      request.fields['description'] = _courseDescription;
      request.fields['courseId'] = widget.courseId;

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        if (jsonResponse['created'] == true) {
          // Handle successful creation
          Fluttertoast.showToast(msg: 'Course content created successfully');
          print('Course content created successfully');
          setState(() {
            _courseDescription = '';
          });
        } else {
          // Handle failure to create course content
          print('Failed to create course content');
          Fluttertoast.showToast(msg: 'Failed to create course content');
        }
        if (!mounted) return;
        setState(() {
          _selectedAudioFiles = [];
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
    final courseDescriptionField = TextFieldContainer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          autofocus: true,
          maxLines: 5,
          controller: _descriptionController,
          keyboardType: TextInputType.text,
          onSaved: (value) {
            _descriptionController.text = value!;
          },
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: "Enter content",
            border: InputBorder.none,
          ),
          onChanged: (val) {
            _courseDescription = val;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
            uploadFiles();
          },
          child: const Text(
            "Add Content",
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
          "Course Content",
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
                  Text(
                    "Create Course Content",
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  courseDescriptionField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  ElevatedButton(
                    onPressed: pickAudioFiles,
                    child: Text('Pick Audio Files'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: pickImageFiles,
                    child: Text('Pick Image Files'),
                  ),
                  SizedBox(height: 16),
                  if (_selectedAudioFiles.isNotEmpty ||
                      _selectedImageFiles.isNotEmpty)
                    Text(
                        'Selected Files: ${_selectedAudioFiles.length + _selectedImageFiles.length}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          createCourse,
                          _isLoading == true
                              ? CircularProgressIndicator()
                              : SizedBox(),
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
