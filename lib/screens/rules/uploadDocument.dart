import 'package:amategeko/screens/rules/amategeko_yose.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import '../homepages/notificationtab.dart';

class UploadDocuments extends StatefulWidget {
  final bool isNew;
  final String? documentId;

  final String? filename;

  const UploadDocuments(
      {Key? key, required this.isNew, this.documentId, this.filename})
      : super(key: key);

  @override
  State<UploadDocuments> createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {
  //from

  final _formkey = GlobalKey<FormState>();
  String fileUrl = "", fileName = "", fileType = "";
  int fileSize = 0;

  //select file
  PlatformFile? pickedFile;
  final picker = ImagePicker();

  Future selectsFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
      fileSize = result.files.first.size;
      fileName = result.files.first.name;
      fileType = result.files.first.extension!;
    });
  }

  bool _isLoading = false;
  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final createQuizBtn = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.5,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
           
          },
          child: Text(
            widget.isNew == true ? "Upload Doc" : "Update Doc",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
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
        title: Text(
          widget.isNew == true ? "Upload Docs" : "Update Docs",
          style: const TextStyle(letterSpacing: 1.25, fontSize: 24),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
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
                  Text(
                    widget.isNew == true
                        ? "UPLOAD DOCUMENT"
                        : "UPDATE DOCUMENT",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 2),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(
                    widget.isNew == true
                        ? "upload document,it's simple and easy"
                        : "update document,it's simple and easy",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: kPrimaryLightColor,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isNew == true
                                            ? "Pick PDF File"
                                            : widget.filename.toString(),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          letterSpacing: 2,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: kPrimaryLightColor,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Picked File :${fileName.toString()}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          letterSpacing: 2,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ),
                          GestureDetector(
                            onTap: selectsFile,
                            child: const Padding(
                                padding: EdgeInsets.only(
                                    top: 100.0, right: 120.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: kPrimaryColor,
                                      radius: 25.0,
                                      child: Icon(
                                        Icons.picture_as_pdf,
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
                  createQuizBtn,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  _isLoading
                      ? const LinearProgressIndicator()
                      : Container(
                          child: null,
                        ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "See All Documents ",
                        style: TextStyle(color: kPrimaryColor, fontSize: 16),
                      ),
                      SizedBox(
                        width: size.width * 0.04,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const AmategekoYose();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          "View Docs",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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

  @override
  void initState() {
    super.initState();
    print("Status is :${widget.isNew}");
    print("docId id${widget.documentId}");
  }
}
