import 'package:flutter/foundation.dart';
import 'package:rwanda_traffic_rules/ads/ad_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import '../../widgets/MainDrawer.dart';
import '../../widgets/ModernAppBar.dart';
import 'package:rwanda_traffic_rules/components/amabwiriza.dart';
import 'package:rwanda_traffic_rules/screens/rules/readDocument.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AmategekoYose extends StatefulWidget {
  const AmategekoYose({Key? key}) : super(key: key);

  @override
  State<AmategekoYose> createState() => _AmategekoYoseState();
}

class _AmategekoYoseState extends State<AmategekoYose> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late SharedPreferences preferences;
  String? currentuserid;
  String? currentusername;
  String? phone;
  String? userRole;

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      phone = preferences.getString("phone")!;
      userRole = preferences.getString("role")!;
    });
  }

  List<Map<String, String>> documents = [
    {
      'assetPath': 'assets/files/IGAZETI_YA_LETA.pdf',
      'fileName': 'Official Gazette',
      'fileSize': '502 KB',
      'description': 'Official government traffic regulations',
    },
    {
      'assetPath': 'assets/files/alexisibyapa.pdf',
      'fileName': 'Traffic Signs',
      'fileSize': '753 KB',
      'description': 'Complete guide to traffic signs and signals',
    },
  ];

  @override
  void initState() {
    _messaging.getToken().then((value) {
      if (kDebugMode) {
        print(value);
      }
    });
    getCurrUserData();
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
      appBar: ModernAppBar(
        title: 'Traffic Rules',
        subtitle: 'Documents',
        onMenuPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AmabwirizaList(),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.rule_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Rules',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withValues(alpha: 0.1),
                  kPrimaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: kPrimaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Traffic Documents",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Official traffic rules and regulations",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${documents.length} documents available",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Documents List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length + 1, // +1 for bottom padding
              itemBuilder: (context, index) {
                if (index == documents.length) {
                  // Bottom padding item
                  return const SizedBox(height: 100);
                }
                final doc = documents[index];
                return ModernDocumentCard(
                  assetPath: doc['assetPath']!,
                  fileName: doc['fileName']!,
                  fileSize: doc['fileSize']!,
                  description: doc['description']!,
                );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: userRole == "Admin"
      //     ? Container(
      //         margin: const EdgeInsets.only(bottom: 20),
      //         child: FloatingActionButton.extended(
      //           onPressed: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (BuildContext context) => UploadDocuments(
      //                         isNew: true,
      //                         documentId: '',
      //                         filename: '',
      //                       )),
      //             );
      //           },
      //           label: const Text(
      //             'Upload document',
      //             style: TextStyle(
      //               fontSize: 12,
      //               fontWeight: FontWeight.w600,
      //               fontFamily: 'Poppins',
      //             ),
      //           ),
      //           icon: const Icon(
      //             Icons.add,
      //             size: 16,
      //           ),
      //           backgroundColor: kPrimaryColor,
      //           foregroundColor: Colors.white,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(12),
      //           ),
      //           elevation: 4,
      //           isExtended: true,
      //         ),
      //       )
      //     : null,
    );
  }
}

class ModernDocumentCard extends StatelessWidget {
  final String assetPath;
  final String fileName;
  final String fileSize;
  final String description;

  const ModernDocumentCard({
    Key? key,
    required this.assetPath,
    required this.fileName,
    required this.fileSize,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AdManager.onDocumentDownload();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadFile(
                  assetPath: assetPath,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Document Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: kPrimaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Document Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.file_present_rounded,
                            color: kPrimaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            fileSize,
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.open_in_new_rounded,
                    color: kPrimaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
