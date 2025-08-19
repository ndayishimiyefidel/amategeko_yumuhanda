import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';
import '../../components/chat_for_users_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});
  @override
  State createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<Map<String, dynamic>> allUsersList = [];
  Set<String> uniqueUserIds = {}; // Track unique userId's globally
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  late String quizTitle;
  late SharedPreferences preferences;

  bool isLoading = false;

  int from = 0;
  int totalRows = 0;
  int to = 10; // Initial range, fetch the first 10 records
  bool isDisposed = false;

  Future<void> fetchAllUsers() async {
    final apiUrl = "${API.userWithCode}?from=$from&to=$to";
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (!isDisposed) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print("Response Data:  $data");

          if (data['success'] == true) {
            if (!mounted) return;
            setState(() {
              if (from == 0) {
                allUsersList.clear();
                uniqueUserIds
                    .clear(); // Clear uniqueUserIds when starting fresh
              }

              List<Map<String, dynamic>> newData =
                  List<Map<String, dynamic>>.from(data['data']);

              newData = newData.where((newItem) {
                final userId = newItem['phone'] as String;
                if (!uniqueUserIds.contains(userId)) {
                  uniqueUserIds.add(userId); // Add to set of seen userIds
                  return true;
                }
                return false;
              }).toList();

              allUsersList.addAll(newData);

              print("usersList: " + allUsersList.toString());

              isLoading = false;
              totalRows = int.tryParse(data['total'])!.toInt();

              from = to;
              to += 10; // Fetch the next 10 records
            });
          } else {
            print("Failed to execute query");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content:
                    Text('Failed to execute query. Please try again later'),
              ));
            }
          }
        } else {
          throw Exception(
              'Failed to load data from the API. Status Code: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      print("Error occurs: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Failed to connect to the server. Please check your internet connection'),
        ));
      }
    } on FormatException catch (e) {
      print("Error occurs: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Unexpected response from the server. Please try again later'),
        ));
      }
    } catch (e) {
      print("Error occurs: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Failed to load data from the API. Please try again later')),
        );
      }
    } finally {
      if (!isDisposed && mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
    fetchAllUsers();
  }

  @override
  void initState() {
    super.initState();
    getCurrUserId();
  }

  @override
  void dispose() {
    isDisposed = true;
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
              Icons.people_outline_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Users Found",
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
            "Loading users...",
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
            padding: const EdgeInsets.only(top: 8),
            itemCount: allUsersList.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final data = allUsersList[index];

              return ChatUsersList(
                name: data["name"] ?? '',
                time: data["createdAt"],
                userId: data["uid"],
                phone: data["phone"] ?? '',
                deviceId: data["deviceId"] ?? 'nodevice',
                role: data['role'],
                password: data['password'],
                quizCode: data['code'] ?? 'nocode',
                canAccessOnlineSchool: data['can_access_online_school'] == 1 ||
                    data['can_access_online_school'] == true,
              );
            },
          ),
        ),
        if (to <= totalRows)
          Container(
            margin: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        isLoading = true;
                      });
                      fetchAllUsers();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Load More (${allUsersList.length} loaded)",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
