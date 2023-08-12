import 'package:amategeko/screens/rules/readDocument.dart';
import 'package:amategeko/screens/rules/uploadDocument.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../widgets/MainDrawer.dart';
import '../../widgets/banner_widget.dart';
import '../homepages/notificationtab.dart';

// class AmategekoYose extends StatefulWidget {
//   const AmategekoYose({Key? key}) : super(key: key);
//
//   @override
//   State<AmategekoYose> createState() => _AmategekoYoseState();
// }
//
// class _AmategekoYoseState extends State<AmategekoYose> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   Stream<dynamic>? fileStream;
//   bool isLoading = false;
//   DatabaseService databaseService = DatabaseService();
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   AuthService authService = AuthService();
//   final user = FirebaseAuth.instance.currentUser;
//
//   //shared preferences
//   late SharedPreferences preferences;
//   late String currentuserid;
//   late String currentusername;
//   String userRole = "";
//   late String photo;
//   late String phone;
//   String userToken = "";
//
//   // _launchURL(String url) async {
//   //   if (await canLaunchUrl(Uri.parse(url))) {
//   //     await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//   //   } else {
//   //     throw 'Could not launch $url';
//   //   }
//
//   void getCurrUserData() async {
//     preferences = await SharedPreferences.getInstance();
//     setState(() {
//       currentuserid = preferences.getString("uid")!;
//       currentusername = preferences.getString("name")!;
//       userRole = preferences.getString("role")!;
//       photo = preferences.getString("photo")!;
//       phone = preferences.getString("phone")!;
//     });
//   }
//
//   @override
//   void initState() {
//     getCurrUserData();
//     _messaging.getToken().then((value) {
//       print(value);
//     });
//     databaseService.getUploadedDocs().then((value) {
//       setState(() {
//         fileStream = value;
//       });
//     });
//     super.initState();
//   }
//
//   Widget documentsList() {
//     return StreamBuilder(
//       stream: fileStream,
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return const CircularProgressIndicator();
//           default:
//             if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             } else {
//               return fileStream == null
//                   ? const Center(
//                       child: Text(
//                         "No Document Available right now ",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           letterSpacing: 2,
//                           color: Colors.red,
//                         ),
//                       ),
//                     )
//                   : ListView.builder(
//                       itemCount: snapshot.data.docs.length,
//                       itemBuilder: (context, index) {
//                         return FileTile(
//                           docId:
//                               snapshot.data.docs[index].reference.id.toString(),
//                           fileUrl: snapshot.data.docs[index]
//                               .data()["fileUrl"]
//                               .toString(),
//                           fileName: snapshot.data.docs[index]
//                               .data()["fileName"]
//                               .toString(),
//                           fileSize: snapshot.data.docs[index]
//                               .data()["fileSize"]
//                               .toString(),
//                           userRole: userRole,
//                           currentUserId: currentuserid,
//                         );
//                       },
//                     );
//             }
//         }
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: Drawer(
//         elevation: 0,
//         child: MainDrawer(),
//       ),
//       appBar: AppBar(
//         title: const Text(
//           "All Gazette",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.normal,
//             letterSpacing: 1.25,
//             fontSize: 24,
//           ),
//         ),
//         leading: IconButton(
//           color: Colors.white,
//           onPressed: () {
//             _scaffoldKey.currentState!.openDrawer();
//           },
//           icon: const Icon(
//             Icons.menu,
//             color: Colors.white,
//           ),
//         ),
//         actions: [
//           InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (BuildContext context) => Notifications(),
//                 ),
//               );
//             },
//             child: const Padding(
//               padding: EdgeInsets.only(
//                 left: 20,
//                 right: 20,
//               ),
//               child: Icon(
//                 Icons.notifications_outlined,
//                 size: 25,
//               ),
//             ),
//           ),
//         ],
//         centerTitle: true,
//         backgroundColor: kPrimaryColor,
//         elevation: 0.0,
//       ),
//       body: documentsList(),
//       floatingActionButton: userRole == "Admin"
//           ? FloatingActionButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const UploadDocuments(
//                         isNew: true,
//                       );
//                     },
//                   ),
//                 );
//               },
//               child: const Icon(Icons.add),
//             )
//           : null,
//     );
//   }
// }
//
// class FileTile extends StatefulWidget {
//   final String docId;
//   final String fileUrl;
//   final String fileName;
//   final String fileSize;
//   final String userRole;
//   final String currentUserId;
//
//   const FileTile({
//     Key? key,
//     required this.docId,
//     required this.fileUrl,
//     required this.fileName,
//     required this.fileSize,
//     required this.userRole,
//     required this.currentUserId,
//   }) : super(key: key);
//
//   @override
//   State<FileTile> createState() => _FileTileState();
// }
//
// class _FileTileState extends State<FileTile> {
//   bool _isLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//
//     return Container(
//       padding: const EdgeInsets.all(15),
//       child: Column(
//         children: [
//           Card(
//             shape: RoundedRectangleBorder(
//               side: BorderSide(
//                 color: kPrimaryColor,
//                 width: size.width * 0.003,
//               ),
//               borderRadius: BorderRadius.circular(5.0),
//             ),
//             child: InkWell(
//               onTap: () {
//                 print("File url is:${widget.fileUrl}");
//                 // _launchURL(widget.fileUrl);
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return ReadFile(
//                         fileUrl: widget.fileUrl,
//                       );
//                     },
//                   ),
//                 );
//               },
//               splashColor: kPrimaryColor,
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       left: 20, right: 20, top: 10, bottom: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       SizedBox(
//                         height: size.height * 0.01,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             //removing overflow on row widget
//                             child: Column(
//                               children: [
//                                 Text(widget.fileName,
//                                     style: const TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black,
//                                     ),
//                                     textAlign: TextAlign.center),
//                                 SizedBox(
//                                   height: size.height * 0.01,
//                                 ),
//                                 Text(
//                                   "File Size: ${(int.parse(widget.fileSize) / (1024 * 1024)).toStringAsFixed(2)} MB",
//                                   textAlign: TextAlign.start,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.normal,
//                                     color: Colors.blueGrey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(
//                             height: size.height * 0.01,
//                           ),
//                           widget.userRole == "Admin"
//                               ? Column(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   mainAxisSize: MainAxisSize.max,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: <Widget>[
//                                     _getEditIcon(),
//                                     SizedBox(
//                                       height: size.height * 0.03,
//                                     ),
//                                     _isLoading
//                                         ? const CircularProgressIndicator()
//                                         : Container(
//                                             child: null,
//                                           ),
//                                     _getDeleteIcon(),
//                                   ],
//                                 )
//                               : Container()
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _getEditIcon() {
//     return GestureDetector(
//       child: const CircleAvatar(
//         backgroundColor: Colors.green,
//         radius: 14.0,
//         child: Icon(
//           Icons.edit,
//           color: Colors.white,
//           size: 20.0,
//         ),
//       ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return UploadDocuments(
//                 isNew: false,
//                 documentId: widget.docId,
//                 filename: widget.fileName,
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _getDeleteIcon() {
//     return GestureDetector(
//       child: const CircleAvatar(
//         backgroundColor: Colors.red,
//         radius: 14.0,
//         child: Icon(
//           Icons.delete_outline,
//           color: Colors.white,
//           size: 20.0,
//         ),
//       ),
//       onTap: () {
//         setState(() {
//           _isLoading = true;
//         });
//         deleteDoc(widget.docId);
//       },
//     );
//   }
//
//   Future<void> deleteDoc(String docId) async {
//     await FirebaseFirestore.instance
//         .collection("Documents")
//         .doc(docId)
//         .delete()
//         .then((value) {
//       setState(() {
//         _isLoading = false;
//         showDialog(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 content: const Text("Document deleted successfully"),
//                 actions: [
//                   TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text("Close"))
//                 ],
//               );
//             });
//       });
//     });
//   }
// }

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
      print(value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
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
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => Notifications(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 25,
              ),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          documentsList(),
          AdBannerWidget(),
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
