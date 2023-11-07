import 'dart:convert';
import 'package:amategeko/components/notification_list_modified.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';

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

  Future<void> fetchAbafiteCode() async {
    final apiUrl = API.fetchAbafiteCode + "?from=$from&to=$to";
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
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: !isLoading
            ? Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (allUsersList.isEmpty)
                      const Center(
                        child: Text("No user with code"),
                      )
                    else
                      Column(
                        children: [
                          ListView.builder(
                            padding: const EdgeInsets.only(top: 16),
                            itemCount: allUsersList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final data = allUsersList[index];
                              return ModifiedUsersNotificationList(
                                name: data["name"] ?? '',
                                time: data["createdAt"],
                                userId: data["userId"],
                                phone: data["phone"] ?? '',
                                code: data["code"],
                                endTime: data["endTime"] ?? "1684242113231",
                                docId: data['id'],
                              );
                            },
                          ),

                          ///1000=totalrows
                        ],
                      ),
                    if (to <=
                        totalRows) // Show "Load More" button if there are more records
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            isLoading = true;
                            fetchAbafiteCode(); // Load more records
                          },
                          child: const Text("Load More"),
                        ),
                      ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
