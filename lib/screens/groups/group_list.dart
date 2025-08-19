import 'dart:io';
import 'dart:convert';
import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import '../../widgets/MainDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rwanda_traffic_rules/components/amabwiriza.dart';
import 'package:rwanda_traffic_rules/backend/apis/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/ModernAppBar.dart';

class GroupList extends StatefulWidget {
  const GroupList({Key? key}) : super(key: key);
  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late SharedPreferences preferences;
  late String? currentuserid;
  late String currentusername;
  late String photo;
  late String phone;
  String? adminPhone;
  String? userRole;
  List<Map<String, dynamic>> groupList = [];
  TextEditingController nameEditingController = TextEditingController();
  String name = "";
  TextEditingController linkEditingController = TextEditingController();
  String link = "";
  // final _formKey = GlobalKey<FormState>();
  bool isDisposed = false;

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      phone = preferences.getString("phone")!;
      userRole = preferences.getString("role")!;
    });
  }

  Future<void> fetchGroups() async {
    final apiUrl = "${API.fetchGroups}";
    isLoading = true;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            List<Map<String, dynamic>> newData =
                List<Map<String, dynamic>>.from(data['data']);

            newData.removeWhere((newItem) => groupList
                .any((existingItem) => newItem['id'] == existingItem['id']));

            groupList.addAll(newData);
            if (kDebugMode) {
              print("new data $groupList");
            }
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print("Failed to execute query");
        }
      } else {
        throw Exception('Failed to load data from the API');
      }
    } catch (e) {
      print("Error occurs: $e");
    }
  }

  @override
  void initState() {
    getCurrUserData();
    fetchGroups();
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
        title: 'Groups',
        subtitle: 'WhatsApp',
        onMenuPressed: () {
          Navigator.of(context).pop();
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
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: kPrimaryColor,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading groups...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
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
                              Icons.group_rounded,
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
                                  "WhatsApp Groups",
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Join our community groups for traffic rules discussions",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${groupList.length} groups available",
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

                // Groups List
                Expanded(
                  child: groupList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No groups available",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Check back later for new groups",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: groupList.length,
                          itemBuilder: (context, index) {
                            final data = groupList[index];
                            return ModernGroupCard(
                              linkUrl: data["linkUrl"] ?? '',
                              groupName: data["groupName"] ?? '',
                              userRole: userRole.toString(),
                              id: data["id"] ?? '',
                            );
                          },
                        ),
                ),
              ],
            ),
      // floatingActionButton: (userRole != "User")
      //     ? Container(
      //         margin: const EdgeInsets.only(bottom: 16),
      //         child: FloatingActionButton.extended(
      //           onPressed: () => _showCreateGroupDialog(),
      //           backgroundColor: kPrimaryColor,
      //           foregroundColor: Colors.white,
      //           elevation: 4,
      //           icon: const Icon(Icons.add),
      //           label: const Text(
      //             "Create Group",
      //             style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //               fontSize: 16,
      //             ),
      //           ),
      //         ),
      //       )
      //     : null,
    );
  }

  // void _showCreateGroupDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       title: Column(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: kPrimaryColor.withValues(alpha: 0.1),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Icon(
  //               Icons.group_add_rounded,
  //               color: kPrimaryColor,
  //               size: 32,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             "Create New Group",
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //               color: kPrimaryColor,
  //             ),
  //           ),
  //         ],
  //       ),
  //       content: Form(
  //         key: _formKey,
  //         child: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               _buildModernTextField(
  //                 controller: nameEditingController,
  //                 label: "Group Name",
  //                 icon: Icons.group_outlined,
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Group name is required';
  //                   }
  //                   if (value.length < 3) {
  //                     return 'Group name must be at least 3 characters';
  //                   }
  //                   return null;
  //                 },
  //                 onChanged: (val) => name = val,
  //               ),
  //               const SizedBox(height: 16),
  //               _buildModernTextField(
  //                 controller: linkEditingController,
  //                 label: "Group URL",
  //                 icon: Icons.link_outlined,
  //                 validator: (value) {
  //                   if (value == null || value.isEmpty) {
  //                     return 'Group URL is required';
  //                   }
  //                   if (!Uri.tryParse(value)!.hasAbsolutePath) {
  //                     return 'Please enter a valid URL';
  //                   }
  //                   return null;
  //                 },
  //                 onChanged: (val) => link = val,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: Text(
  //             "Cancel",
  //             style: TextStyle(
  //               color: Colors.grey[600],
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             if (_formKey.currentState!.validate()) {
  //               Navigator.of(context).pop();
  //               await _createWhatsAppGroup(name, link);
  //             }
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: kPrimaryColor,
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //           ),
  //           child: const Text(
  //             "Create",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildModernTextField({
  //   required TextEditingController controller,
  //   required String label,
  //   required IconData icon,
  //   required String? Function(String?) validator,
  //   required Function(String) onChanged,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.grey[50],
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
  //     ),
  //     child: TextFormField(
  //       controller: controller,
  //       onChanged: onChanged,
  //       validator: validator,
  //       decoration: InputDecoration(
  //         prefixIcon: Icon(icon, color: kPrimaryColor),
  //         labelText: label,
  //         border: InputBorder.none,
  //         contentPadding: const EdgeInsets.symmetric(
  //           horizontal: 16,
  //           vertical: 16,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Future<void> _createWhatsAppGroup(String groupName, String groupUrl) async {
  //   final url = API.createGroup;
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         "Content-Type": "application/x-www-form-urlencoded",
  //       },
  //       body: {
  //         'groupName': groupName,
  //         'linkUrl': groupUrl,
  //       },
  //     );

  //     final responseData = json.decode(response.body);

  //     if (response.statusCode == 200) {
  //       if (responseData['created'] == true) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(responseData['message']),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //         fetchGroups(); // Refresh the list
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(responseData['message']),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: ${response.statusCode}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
}

class ModernGroupCard extends StatefulWidget {
  final String linkUrl, groupName, userRole, id;

  const ModernGroupCard({
    Key? key,
    required this.linkUrl,
    required this.groupName,
    required this.userRole,
    required this.id,
  }) : super(key: key);

  @override
  State<ModernGroupCard> createState() => _ModernGroupCardState();
}

class _ModernGroupCardState extends State<ModernGroupCard> {
  bool _isLoading = false;

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
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Group Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    color: kPrimaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.groupName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "WhatsApp Group",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  children: [
                    // Join Button
                    _buildActionButton(
                      text: "Join",
                      color: Colors.blue,
                      onTap: () => _launchURL(widget.linkUrl),
                      isLoading: _isLoading,
                    ),

                    // Delete Button (Admin only)
                    if (widget.userRole == "Admin") ...[
                      const SizedBox(height: 8),
                      _buildActionButton(
                        text: "Delete",
                        color: Colors.red,
                        onTap: () => _deleteGroup(widget.id),
                        isLoading: false,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  _launchURL(String url) async {
    setState(() => _isLoading = true);

    try {
      if (Platform.isIOS || Platform.isAndroid) {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } else {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw 'Could not launch $url';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGroup(String groupId) async {
    try {
      final response = await http.post(
        Uri.parse('${API.deletegroup}'),
        body: {'groupName': groupId},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the parent widget
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const GroupList(),
          ),
        );
      } else {
        throw Exception('Failed to delete group');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
