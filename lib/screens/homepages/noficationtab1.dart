import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwanda_traffic_rules/components/notification_list_modified.dart';
import '../../utils/constants.dart';

class NotificationTab1 extends StatefulWidget {
  const NotificationTab1({super.key});

  @override
  State createState() => _NotificationTab1State();
}

class _NotificationTab1State extends State<NotificationTab1> {
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

  int from = 0;
  int totalRows = 0;
  int to = 10; // Initial range, fetch the first 10 records
  bool isDisposed = false;

  Future<void> fetchAbafiteCode() async {
    final apiUrl = "${API.fetchAbafiteCode}?from=$from&to=$to";
    isLoading = true;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (!isDisposed) {
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
              List<Map<String, dynamic>> newData =
                  List<Map<String, dynamic>>.from(data['data']);

              newData.removeWhere((newItem) => allUsersList
                  .any((existingItem) => newItem['id'] == existingItem['id']));

              allUsersList.addAll(newData);
              if (!mounted) return;
              setState(() {
                isLoading = false;
                totalRows = int.tryParse(data['total'])!.toInt();
              });

              // Update 'from' and 'to' for the next load
              from = to;
              to += 10; // Fetch the next 10 records
            });
          } else {
            print("Failed to execute query");
          }
        } else {
          throw Exception('Failed to load data from the API');
        }
      }
    } catch (e) {
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
    fetchAbafiteCode(); // Load the initial 10 records
  }

  @override
  void dispose() {
    super.dispose();
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
      child: !isLoading
          ? allUsersList.isEmpty
              ? _buildEmptyState()
              : _buildUserList()
          : _buildLoadingState(),
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
              Icons.verified_user_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Users With Code",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No users with codes found in the system",
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
            "Loading users with codes...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: allUsersList.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final data = allUsersList[index];
              return ModifiedUsersNotificationList(
                  name: data["name"] ?? '',
                  time: data["createdAt"],
                  userId: data["userId"],
                  phone: data["phone"] ?? '',
                  code: data["code"] ?? '',
                  ex_type: data['ex_type'] ?? '',
                  endTime: data["endTime"] ?? "1684242113231",
                  docId: data['id'],
                  updatedAt: data["updatedAt"] ?? '');
            },
          ),
        ),
        if (to <= totalRows)
          Container(
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        isLoading = true;
                      });
                      fetchAbafiteCode(); // Load more records
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Load More",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
