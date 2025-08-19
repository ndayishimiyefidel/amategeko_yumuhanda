import 'dart:convert';
import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rwanda_traffic_rules/components/notification_list_modified.dart';

class UserNotification extends StatefulWidget {
  const UserNotification({super.key});

  @override
  _UserNotificationState createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {
  List<Map<String, dynamic>> allUsersList = [];
  late SharedPreferences preferences;
  late String currentuserid = '',
      currentusername = '',
      userToken = '',
      phone = '';
  bool isLoading = false, hasCode = false;
  String? userRole = '', adminPhone = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    // Cancel any ongoing operations to prevent setState after dispose
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _getCurrentUserData();
    _initializeFCM();
    await _fetchNotifications();
    await _getAdminToken();
  }

  Future<void> _getCurrentUserData() async {
    preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentuserid = preferences.getString("uid") ?? '';
        currentusername = preferences.getString("name") ?? '';
        userRole = preferences.getString("role");
        phone = preferences.getString("phone") ?? '';
        userToken = preferences.getString("fcmToken") ?? '';
      });
    }
    checkQuizCode();
  }

  Future<void> checkQuizCode() async {
    const url = API.checkCode;
    final response =
        await http.post(Uri.parse(url), body: {'userId': currentuserid});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        if (mounted) {
          setState(() {
            hasCode = data['hasCode'] == true;
          });
        }
      }
    } else {
      print("Error: Failed to check quiz code");
    }
  }

  Future<void> _getAdminToken() async {
    const url = API.getToken;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        userToken = data['data']['fcmToken'];
        adminPhone = data['data']['phone'];
        print(adminPhone);
      }
    } else {
      print("Error: Failed to get admin token");
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final response =
          await http.get(Uri.parse('${API.fetchById}?userId=$currentuserid'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("My Data $data");
        if (data['success']) {
          if (mounted) {
            setState(() {
              allUsersList = List<Map<String, dynamic>>.from(data['data']);
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _initializeFCM() {
    FirebaseMessaging.instance.subscribeToTopic("Traffic-Notification");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withValues(alpha: 0.05),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Header Section
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
                        Icons.notifications_rounded,
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
                            "My Notifications",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "View your quiz requests and updates",
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

                const SizedBox(height: 20),

                // Status Card
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hasCode
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          hasCode
                              ? Icons.check_circle_rounded
                              : Icons.pending_rounded,
                          color: hasCode ? Colors.green : Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasCode ? "Quiz Code Active" : "Waiting for Code",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: hasCode ? Colors.green : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasCode
                                  ? "You can now access all quiz features"
                                  : "Your request is being processed",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : allUsersList.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationList(),
          ),

          // Banner Ad
          // const BannerWidget(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading notifications...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Notifications",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You don't have any notifications yet",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allUsersList.length,
      itemBuilder: (context, index) {
        final data = allUsersList[index];
        return ModifiedUsersNotificationList(
          name: data["name"] ?? '',
          time: data["createdAt"] ?? '',
          userId: data["userId"] ?? '',
          phone: data["phone"] ?? '',
          code: data["code"] ?? '',
          ex_type: data['ex_type'] ?? '',
          endTime: data["endTime"] ?? "1684242113231",
          docId: data['id'] ?? '',
          updatedAt: data["updatedAt"] ?? '',
        );
      },
    );
  }
}
