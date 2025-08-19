import 'dart:async';
import 'package:intl/intl.dart';
import '../widgets/fcmWidget.dart';
import '../utils/generate_code.dart';
import 'package:flutter/material.dart';
import '../backend/apis/db_connection.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../utils/constants.dart';

class UsersNotificationList extends StatefulWidget {
  final String name;
  final String time;
  final String userId;
  final String phone;
  final String code, docId;
  final bool? isQuiz;
  final String? endTime, ex_type, updatedAt;

  const UsersNotificationList({
    super.key,
    required this.name,
    required this.time,
    required this.userId,
    required this.phone,
    required this.code,
    required this.docId,
    this.isQuiz,
    this.endTime,
    this.ex_type,
    this.updatedAt,
  });

  @override
  State createState() => _UsersNotificationListState();
}

class _UsersNotificationListState extends State<UsersNotificationList> {
  late String currentuserid;
  late String currentusername;
  late String currentUserPhone;
  String? userRole;
  late SharedPreferences preferences;
  bool _isLoading = false;
  late String fcmToken;

  @override
  void initState() {
    super.initState();
    getCurrUser(); // Get login data
    requestPermission(); // Request permission
    loadFCM(); // Load FCM
    listenFCM(); // Listen to FCM
    FirebaseMessaging.instance.subscribeToTopic("Traffic-Notification");
  }

  getCurrUser() async {
    preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentUserPhone = preferences.getString("phone")!;
      userRole = preferences.getString("role");
      fcmToken = preferences.getString("fcmToken")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    int timestamp = int.parse(widget.time);
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var dateTimeFormat = DateFormat('dd/MM/yyyy, hh:mm a').format(date);

    return InkWell(
      onTap: () {},
      child: widget.code.isEmpty
          ? _buildNotificationContent(size, dateTimeFormat)
          : const SizedBox(),
    );
  }

  // My Data {success: true, data: [{id: 0, userId: 17243216779931724324234, name: Alexis TEST, phone: 0722877442, code: 178747, createdAt: 1724476341381, isOpen: 1, isQuiz: 1, endTime: 1730325600000, addedToClass: null}]}

  Widget _buildNotificationContent(Size size, String dateTimeFormat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            // User Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: kPrimaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: _buildNotificationDetails(dateTimeFormat),
            ),

            // Admin Actions
            if (userRole == "Admin") ...[
              const SizedBox(width: 16),
              _buildAdminActions(size),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationDetails(String dateTimeFormat) {
    int endTime = int.parse(widget.endTime.toString());
    var endDate = DateTime.fromMillisecondsSinceEpoch(endTime);
    var dateTimeFormat1 = DateFormat('dd/MM/yyyy, hh:mm a').format(endDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Language Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.ex_type == "1" ? "English" : "Kinyarwanda",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          widget.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Phone/Code Row
        Row(
          children: [
            Expanded(
              child: Text(
                userRole == "Admin"
                    ? widget.phone
                    : "Quiz-code: ${widget.code}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            if (userRole == "Admin")
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () async {
                    await FlutterPhoneDirectCaller.callNumber(widget.phone);
                  },
                  icon: const Icon(Icons.call, size: 20, color: Colors.blue),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Dates
        if (userRole == "User") ...[
          Text(
            dateTimeFormat,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
        if (userRole == "Admin") ...[
          Text(
            "Requested: $dateTimeFormat",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Expires: $dateTimeFormat1",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.isQuiz == true
                  ? "Quiz code: ${widget.ex_type}"
                  : "Code: ${widget.code}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildAdminActions(Size size) {
    return Column(
      children: <Widget>[
        // Generate Code Button
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _generateCodeAndSetLimit,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.generating_tokens_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Delete Button
        Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _deleteCode,
            icon: const Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  void _generateCodeAndSetLimit() async {
    setState(() => _isLoading = true);

    try {
      int createdAt = DateTime.now().millisecondsSinceEpoch;
      String generatedCode = randomNumeric(6);
      await GenerateUser.generateCodeAndNotify(
        context,
        widget.userId,
        generatedCode,
        widget.name,
        "Generated code is $generatedCode for",
        widget.phone,
        widget.ex_type.toString(),
        createdAt.toString(),
      );

      await _pickDateAndSetLimit();

      _getToken();
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            widget.ex_type.toString());

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
          SnackBar(content: Text('An error occurred while picking a date.')),
        );
      }
    }
  }

  Future<void> _deleteCode() async {
    setState(() => _isLoading = true);

    try {
      await GenerateUser.deleteUserCode(
        context,
        widget.userId,
        widget.ex_type.toString(),
        API.deleteCode,
        widget.name,
        ", Code has been deleted successfully",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _getToken() {
    String body =
        "Mwiriwe neza ${widget.name}, ubu ngubu wemerewe gukora ibizamini byose ntankomyi kuko wamaze kwishyura.\nMurakoze mukomeze kwiga neza";
    String notificationTitle = "Quiz App Generating Code";
    sendPushMessage(fcmToken, body, notificationTitle);
  }
}
