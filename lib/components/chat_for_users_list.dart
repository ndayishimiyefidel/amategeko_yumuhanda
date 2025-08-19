import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:rwanda_traffic_rules/utils/generate_code.dart';
import 'package:rwanda_traffic_rules/backend/apis/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatUsersList extends StatefulWidget {
  final String name, role, time, userId, phone, password;
  final String? referralCode, quizCode, deviceId;
  final bool? canAccessOnlineSchool;

  const ChatUsersList({
    super.key,
    this.referralCode,
    required this.name,
    required this.time,
    required this.userId,
    required this.phone,
    required this.password,
    required this.role,
    this.quizCode,
    this.deviceId,
    this.canAccessOnlineSchool,
  });

  @override
  State<ChatUsersList> createState() => _ChatUsersListState();
}

class _ChatUsersListState extends State<ChatUsersList> {
  late SharedPreferences preferences;
  bool hasBeenCalled = false;
  bool canAccessOnlineSchool = false;
  bool isUpdatingAccess = false;

  @override
  void initState() {
    super.initState();
    canAccessOnlineSchool = widget.canAccessOnlineSchool ?? false;
  }

  Future<bool> _hasUserBeenCalled() async {
    preferences = await SharedPreferences.getInstance();
    return preferences.getBool('called_${widget.userId}') ?? false;
  }

  Future<void> _setUserCalled() async {
    preferences = await SharedPreferences.getInstance();
    preferences.setBool("called_${widget.userId}", true);
  }

  Future<void> _updateOnlineSchoolAccess(bool access) async {
    setState(() {
      isUpdatingAccess = true;
    });

    try {
      final response = await http.post(
        Uri.parse(API.updateOnlineSchoolAccess),
        body: {
          'uid': widget.userId,
          'access': access ? '1' : '0',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          setState(() {
            canAccessOnlineSchool = access;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(access
                    ? 'Online School access granted to ${widget.name}'
                    : 'Online School access revoked from ${widget.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to update access'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update access. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating online school access: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isUpdatingAccess = false;
      });
    }
  }

  Future<bool?> _showCallConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Call Confirmation"),
          content: Text(hasBeenCalled
              ? "Are you sure you want to call this person again?"
              : "Are you sure you want to call this person?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Call"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int timestamp = int.parse(widget.time);
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formattedDate = DateFormat('dd/MM/yyyy, hh:mm a').format(date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar and Name
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: kPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Joined: $formattedDate",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // User Details Grid
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow("Phone:", widget.phone, Icons.phone_rounded),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                      "Password:", widget.password, Icons.lock_rounded,
                      isItalic: true),
                  if (widget.quizCode != "nocode") ...[
                    const SizedBox(height: 6),
                    _buildInfoRow("Quiz Code:", widget.quizCode.toString(),
                        Icons.code_rounded,
                        color: Colors.blue),
                  ],
                  if (widget.deviceId != "nodevice") ...[
                    const SizedBox(height: 6),
                    _buildInfoRow("Device ID:", widget.deviceId.toString(),
                        Icons.devices_rounded,
                        color: Colors.redAccent),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<bool>(
                    future: _hasUserBeenCalled(),
                    builder: (context, snapshot) {
                      final hasBeenCalled = snapshot.data ?? false;
                      return ElevatedButton.icon(
                        onPressed: () async {
                          bool? confirmed =
                              await _showCallConfirmationDialog(context);
                          if (confirmed == true) {
                            await FlutterPhoneDirectCaller.callNumber(
                                widget.phone);
                            if (!hasBeenCalled) {
                              await _setUserCalled();
                            }
                          }
                        },
                        icon: Icon(
                          Icons.call_rounded,
                          color: hasBeenCalled ? Colors.grey : Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          hasBeenCalled ? "Called" : "Call",
                          style: TextStyle(
                            color: hasBeenCalled ? Colors.grey : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasBeenCalled ? Colors.grey[300] : Colors.blue,
                          foregroundColor:
                              hasBeenCalled ? Colors.grey : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Generate Code Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _generateCodeAndSetLimit,
                    icon: const Icon(
                      Icons.generating_tokens_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Online School Access Toggle (Admin Only)
                if (widget.role == 'User') ...[
                  Container(
                    decoration: BoxDecoration(
                      color: canAccessOnlineSchool ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: (canAccessOnlineSchool
                                  ? Colors.blue
                                  : Colors.grey)
                              .withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: isUpdatingAccess
                          ? null
                          : () {
                              _updateOnlineSchoolAccess(!canAccessOnlineSchool);
                            },
                      icon: isUpdatingAccess
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              canAccessOnlineSchool
                                  ? Icons.school
                                  : Icons.school_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Delete Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      GenerateUser.deleteUserCode(
                        context,
                        widget.userId,
                        "0",
                        API.deleteUser,
                        widget.name,
                        "Deleted successfully!",
                      );
                    },
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon,
      {Color? color, bool isItalic = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color ?? Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "$title $value",
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.black87,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  void _generateCodeAndSetLimit() async {
    try {
      String generatedCode = randomNumeric(6);
      int createdAt = DateTime.now().millisecondsSinceEpoch;

      await GenerateUser.generateCodeAndNotify(
        context,
        widget.userId,
        generatedCode,
        widget.name,
        "Generated code is $generatedCode for",
        widget.phone,
        "0",
        createdAt.toString(),
      );

      await _pickDateAndSetLimit();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while generating a code.')),
        );
      }
    }
  }

  Future<void> _pickDateAndSetLimit() async {
    try {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        int updatedAt = DateTime.now().millisecondsSinceEpoch;

        bool success = await GenerateUser.setCodeLimit(
          context,
          widget.userId,
          API.setLimitTime,
          updatedAt.toString(),
          pickedDate.millisecondsSinceEpoch.toString(),
          widget.phone,
          "0",
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Expiration time set successfully!'
                  : 'Failed to set expiration time.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while picking a date.')),
        );
      }
    }
  }
}
