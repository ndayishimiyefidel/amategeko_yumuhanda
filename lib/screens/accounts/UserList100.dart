import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';
import '../../components/chat_for_users_list.dart';

class UserList100 extends StatefulWidget {
  const UserList100({super.key});

  @override
  State createState() => _UserList100State();
}

class _UserList100State extends State<UserList100> {
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
  bool isDisposed = false;

  int from = 0;
  int totalRows = 0;
  int to = 100; // Initial range, fetch the first 10 records

  // Update the fetchAllUsers function to handle the response data
  Future<void> fetchAllUsers() async {
    final apiUrl = "${API.userWithNoCode}?from=$from&to=$to";
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (!isDisposed) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['success'] == true) {
            if (!mounted) return;
            setState(() {
              if (from == 0) {
                allUsersList.clear();
              }
              List<Map<String, dynamic>> newData =
                  List<Map<String, dynamic>>.from(data['data'] ?? []);

              newData.removeWhere((newItem) => allUsersList
                  .any((existingItem) => newItem['id'] == existingItem['id']));

              allUsersList.addAll(newData);
              print("user list response data: $allUsersList");
              isLoading = false;
              totalRows = int.tryParse(data['total'] ?? '0') ?? 0;

              from = to;
              to += 10; // Fetch the next 10 records
            });
          } else {
            setState(() {
              isLoading = false;
            });
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

                              return ChatUsersList(
                                name: data["name"] ?? '',
                                time: data["createdAt"],
                                userId: data["uid"],
                                phone: data["phone"] ?? '',
                                deviceId: data["deviceId"] ?? 'nodevice',
                                role: data['role'],
                                password: data['password'],
                                quizCode: data['code'] ?? 'nocode',
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
                            fetchAllUsers(); // Load more records
                          },
                          child: const Text("Load More"),
                        ),
                      ),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
