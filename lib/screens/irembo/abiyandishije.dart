import 'dart:convert';
import 'package:rwanda_traffic_rules/screens/homepages/notificationtab.dart';
import 'package:rwanda_traffic_rules/utils/constants.dart';
import 'package:rwanda_traffic_rules/widgets/MainDrawer.dart';
import 'package:rwanda_traffic_rules/widgets/ModernAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';

class Abiyandikishe extends StatefulWidget {
  const Abiyandikishe({super.key});

  @override
  State createState() => _AbiyandikisheState();
}

class _AbiyandikisheState extends State<Abiyandikishe> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> allUsersList = [];
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  late String quizTitle;
  late SharedPreferences preferences;
  int itemsPerPage = 10;
  int currentPage = 0;
  bool isLoading = false;
  bool isSelectionMode = false;
  Set<String> selectedUsers = <String>{};

  int from = 0;
  int totalRows = 0;
  int to = 10; // Initial range, fetch the first 10 records

  Future<void> fetchAllUsers() async {
    final apiUrl = API.abiyandikishije + "?from=$from&to=$to";
    isLoading = true;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          if (!mounted) return;
          setState(() {
            if (from == 0) {
              // If it's the first load, clear the list
              allUsersList.clear();
            }
            // Append the new data to the existing list
            allUsersList.addAll(List<Map<String, dynamic>>.from(data['data']));
            isLoading = false;
            totalRows = int.tryParse(data['total'])!.toInt();
          });

          // Update 'from' and 'to' for the next load
          from = to;
          to += 10; // Fetch the next 10 records
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
      setState(() {
        isLoading = false;
      });
      print("Error occurs: $e");
    }
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      phoneNumber = preferences.getString("phone")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserId();
    fetchAllUsers(); // Load the initial 10 records
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Delete single user
  Future<void> deleteUser(String userId, String userName) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteIremboUser),
        body: {'uid': userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            allUsersList.removeWhere((user) => user['uid'] == userId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userName deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to delete user'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Bulk delete users
  Future<void> bulkDeleteUsers() async {
    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select users to delete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(API.deleteIremboUser),
        body: {
          'uids': selectedUsers.join(','),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            allUsersList
                .removeWhere((user) => selectedUsers.contains(user['uid']));
            selectedUsers.clear();
            isSelectionMode = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${selectedUsers.length} users deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to delete users'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Failed to delete users');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Toggle selection mode
  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedUsers.clear();
      }
    });
  }

  // Toggle user selection
  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUsers.contains(userId)) {
        selectedUsers.remove(userId);
      } else {
        selectedUsers.add(userId);
      }
    });
  }

  // Select all users
  void selectAllUsers() {
    setState(() {
      if (selectedUsers.length == allUsersList.length) {
        selectedUsers.clear();
      } else {
        selectedUsers =
            allUsersList.map((user) => user['uid'] as String).toSet();
      }
    });
  }

  // Show bulk delete confirmation dialog
  void _showBulkDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Bulk Delete'),
          content: Text(
            'Are you sure you want to delete ${selectedUsers.length} selected user(s)? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                bulkDeleteUsers();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Show single delete confirmation dialog
  void _showDeleteConfirmation(String userId, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
              'Are you sure you want to delete $userName? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteUser(userId, userName);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
        title: 'Registered',
        subtitle: 'Users',
        onMenuPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: Icon(
                selectedUsers.length == allUsersList.length
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: Colors.white,
                size: 24,
              ),
              onPressed: selectAllUsers,
              tooltip: 'Select All',
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_sweep,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => _showBulkDeleteConfirmation(),
              tooltip: 'Bulk Delete',
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
              onPressed: toggleSelectionMode,
              tooltip: 'Cancel Selection',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(
                Icons.select_all,
                color: Colors.white,
                size: 24,
              ),
              onPressed: toggleSelectionMode,
              tooltip: 'Select Users',
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Notifications(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: isLoading && allUsersList.isEmpty
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
                    "Loading users...",
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
                              Icons.people_rounded,
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
                                  "Registered Users",
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "View all registered users in the system",
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
                            "${allUsersList.length} users loaded",
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

                // Users List
                Expanded(
                  child: allUsersList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No users available",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No registered users found",
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
                          itemCount: allUsersList.length,
                          itemBuilder: (context, index) {
                            final data = allUsersList[index];
                            return ModernUserCard(
                              name: data["name"] ?? '',
                              time: data["createdAt"],
                              userId: data["uid"] ?? '',
                              myPhone: data["phone"] ?? '',
                              identity: data['identity'] ?? '',
                              myAddress: data["address"] ?? '',
                              code: data["code"] ?? 'nocode',
                              type: data['type'] ?? 'notype',
                              category: data['category'] ?? 'nocategory',
                              isSelectionMode: isSelectionMode,
                              isSelected: selectedUsers.contains(data["uid"]),
                              onSelectionChanged: () =>
                                  toggleUserSelection(data["uid"]),
                              onDelete: () => _showDeleteConfirmation(
                                  data["uid"], data["name"]),
                            );
                          },
                        ),
                ),

                // Load More Button
                if (to <= totalRows)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                fetchAllUsers(); // Load more records
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Load More Users",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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

class ModernUserCard extends StatelessWidget {
  final String name,
      time,
      userId,
      myPhone,
      identity,
      myAddress,
      code,
      type,
      category;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onSelectionChanged;
  final VoidCallback onDelete;

  const ModernUserCard({
    Key? key,
    required this.name,
    required this.time,
    required this.userId,
    required this.myPhone,
    required this.identity,
    required this.myAddress,
    required this.code,
    required this.type,
    required this.category,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onSelectionChanged,
    required this.onDelete,
  }) : super(key: key);

  // Function to copy user details to clipboard
  void _copyUserDetails(BuildContext context) {
    final details =
        'Identity: $identity | Phone: $myPhone | Code: ${code != 'nocode' ? code : 'No Code'} | Category: $category';

    Clipboard.setData(ClipboardData(text: details)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User details copied to clipboard!'),
          backgroundColor: kPrimaryColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }

  // Function to copy individual field to clipboard
  void _copyIndividualField(
      BuildContext context, String fieldName, String value) {
    Clipboard.setData(ClipboardData(text: value)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName copied to clipboard!'),
          backgroundColor: kPrimaryColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }

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
          onTap: isSelectionMode ? onSelectionChanged : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Header
                Row(
                  children: [
                    if (isSelectionMode)
                      GestureDetector(
                        onTap: onSelectionChanged,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected ? kPrimaryColor : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: kPrimaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "User ID: $userId",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type != 'notype' ? type : 'User',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (!isSelectionMode) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyUserDetails(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.copy_rounded,
                                color: kPrimaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // User Details
                _buildDetailRow(context, Icons.phone_rounded, "Phone", myPhone,
                    showCopyButton: true),
                const SizedBox(height: 8),
                _buildDetailRow(
                    context, Icons.badge_rounded, "Identity", identity,
                    showCopyButton: true),
                const SizedBox(height: 8),
                _buildDetailRow(
                    context, Icons.location_on_rounded, "Address", myAddress),
                const SizedBox(height: 8),
                _buildDetailRow(
                    context, Icons.category_rounded, "Category", category,
                    showCopyButton: true),
                const SizedBox(height: 8),
                _buildDetailRow(context, Icons.code_rounded, "Code",
                    code != 'nocode' ? code : 'No Code',
                    showCopyButton: true),
                const SizedBox(height: 16),

                // Copy Details Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _copyUserDetails(context),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text(
                      'Copy Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                      foregroundColor: kPrimaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: kPrimaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Registration Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Registered: ${_formatTime(time)}",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value,
      {bool showCopyButton = false}) {
    return Row(
      children: [
        Icon(
          icon,
          color: kPrimaryColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showCopyButton &&
            value.isNotEmpty &&
            value != 'No Code' &&
            value != 'nocode' &&
            value != 'nocategory' &&
            value != 'notype')
          GestureDetector(
            onTap: () => _copyIndividualField(context, label, value),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.copy_rounded,
                color: kPrimaryColor,
                size: 14,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(String? time) {
    if (time == null) return 'Unknown';
    try {
      // Add your time formatting logic here
      return time;
    } catch (e) {
      return 'Unknown';
    }
  }
}
