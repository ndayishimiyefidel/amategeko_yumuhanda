import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwanda_traffic_rules/utils/constants.dart';
import 'package:rwanda_traffic_rules/utils/generate_code.dart';
import 'package:rwanda_traffic_rules/backend/apis/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class IremboUsersList extends StatefulWidget {
  final String name, time, userId, myPhone, identity, myAddress, type;
  final String? code, category;

  const IremboUsersList({
    super.key,
    required this.name,
    required this.time,
    required this.identity,
    required this.userId,
    required this.myPhone,
    required this.myAddress,
    this.code,
    required this.type,
    this.category,
  });

  @override
  State createState() => _IremboUsersListState();
}

class _IremboUsersListState extends State<IremboUsersList> {
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late String currentUserPhone;
  String? userRole;
  late String phoneNumber;
  late SharedPreferences preferences;
  bool isLoading = false;
  bool hasBeenCalled = false;

  Future<bool> _hasUserBeenCalled() async {
    preferences = await SharedPreferences.getInstance();
    hasBeenCalled = preferences.getBool('called_${widget.userId}') ?? false;
    return hasBeenCalled;
  }

  Future<void> _setUserCalled() async {
    preferences = await SharedPreferences.getInstance();
    preferences.setBool("called_${widget.userId}", true);
  }

  @override
  void initState() {
    super.initState();
    getCurrUser();
  }

  getCurrUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentUserPhone = preferences.getString("phone")!;
      userRole = preferences.getString("role")!;
    });
  }

  Future<bool?> _showCallConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: hasBeenCalled != true
              ? const Text("Call Confirmation")
              : const Text("Call Confirmation Again"),
          content: hasBeenCalled != true
              ? const Text("Are you sure you want to call this person?")
              : const Text(
                  "Are you sure you want to call this person again?",
                  style: TextStyle(color: Colors.brown),
                ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Call"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String textToCopy) {
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$textToCopy copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    int timestamp = int.parse(widget.time);
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var dateTimeFormat = DateFormat('dd/MM/yyyy, hh:mm a').format(date);

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
          splashColor: kPrimaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Header
                Row(
                  children: [
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
                            widget.name,
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
                            "Type: ${widget.type}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.type,
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // User Details
                _buildDetailRow(Icons.phone_rounded, "Phone", widget.myPhone),
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.badge_rounded, "Identity", widget.identity),
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.location_on_rounded, "Address", widget.myAddress),
                if (widget.type == "Permit") ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.category_rounded, "Category",
                      widget.category ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      Icons.code_rounded, "Code", widget.code ?? 'N/A'),
                ],
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _copyToClipboard(widget.myPhone);
                            },
                            icon: const Icon(
                              Icons.copy,
                              size: 20,
                              color: kPrimaryColor,
                            ),
                            tooltip: 'Copy Phone',
                          ),
                          IconButton(
                            onPressed: () async {
                              bool hasBeenCalled = await _hasUserBeenCalled();
                              if (!hasBeenCalled) {
                                bool? confirmed =
                                    await _showCallConfirmationDialog(context);
                                if (confirmed == true) {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      widget.myPhone);
                                  await _setUserCalled();
                                  setState(() {});
                                }
                              } else {
                                bool? confirmed =
                                    await _showCallConfirmationDialog(context);
                                if (confirmed == true) {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      widget.myPhone);
                                }
                              }
                            },
                            icon: FutureBuilder<bool>(
                              future: _hasUserBeenCalled(),
                              builder: (context, snapshot) {
                                final hasBeenCalled = snapshot.data ?? false;
                                final callColor = hasBeenCalled
                                    ? Colors.grey
                                    : Colors.blueAccent;
                                return Icon(
                                  Icons.call,
                                  size: 20,
                                  color: callColor,
                                );
                              },
                            ),
                            tooltip: 'Call User',
                          ),
                          if (widget.type == "Permit")
                            IconButton(
                              onPressed: () {
                                _copyToClipboard(widget.code.toString());
                              },
                              icon: const Icon(
                                Icons.copy,
                                size: 20,
                                color: kPrimaryColor,
                              ),
                              tooltip: 'Copy Code',
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      color: Colors.red,
                      onPressed: () async {
                        final url = API.deleteIremboUser;
                        GenerateUser.deleteUserCode(
                          context,
                          widget.userId,
                          "0",
                          url,
                          widget.name,
                          "deleted successfully!",
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      tooltip: 'Delete User',
                    ),
                  ],
                ),

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
                      "Registered: $dateTimeFormat",
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
      ],
    );
  }
}
