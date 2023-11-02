import 'package:amategeko/components/amabwiriza.dart';
import 'package:amategeko/screens/rules/readDocument.dart';
import 'package:amategeko/screens/rules/uploadDocument.dart';
import 'package:amategeko/widgets/custom_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../widgets/MainDrawer.dart';
class AmategekoYose extends StatefulWidget {
  const AmategekoYose({Key? key}) : super(key: key);

  @override
  State<AmategekoYose> createState() => _AmategekoYoseState();
}

class _AmategekoYoseState extends State<AmategekoYose> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Widget documentsList() {
    return Expanded(
      child: ListView(
        children: const [
          FileTile(
            assetPath: 'assets/files/IGAZETI_YA_LETA.pdf',
            fileName: 'IGAZETI YA LETA',
            fileSize: '502 KB',
          ),
          FileTile(
            assetPath: 'assets/files/alexisibyapa.pdf',
            fileName: 'IBYAPA BY ALEXIS',
            fileSize: '753 KB',
          ),

          // Add more FileTile widgets for other files
        ],
      ),
    );
  }

  @override
  void initState() {
    _messaging.getToken().then((value) {
      // ignore: avoid_print
      print(value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
        elevation: 0,
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: const Text(
          "Documents",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.25,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        actions: [
      CustomButton(
      text: "Amabwiriza",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AmabwirizaList(),
          ),
        );
      },
    )
        ],
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          documentsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const UploadDocuments(
                  isNew: true,
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FileTile extends StatelessWidget {
  final String assetPath;
  final String fileName;
  final String fileSize;

  const FileTile({
    Key? key,
    required this.assetPath,
    required this.fileName,
    required this.fileSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: kPrimaryColor,
                width: size.width * 0.003,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ReadFile(
                        assetPath: assetPath,
                      );
                    },
                  ),
                );
              },
              splashColor: kPrimaryColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            //removing overflow on row widget
                            child: Column(
                              children: [
                                Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Text(
                                  "File Size: $fileSize",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
