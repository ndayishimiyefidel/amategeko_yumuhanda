import 'dart:convert';
import 'UserList.dart';
import 'UserList100.dart';
import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import '../../widgets/MainDrawer.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwanda_traffic_rules/components/chat_for_users_list.dart';
import 'package:rwanda_traffic_rules/screens/homepages/usernotification.dart';
import '../../widgets/ModernAppBar.dart';

// ignore_for_file: use_build_context_synchronously

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers>
    with SingleTickerProviderStateMixin {
  var allUsersList = [];
  String? currentuserid;
  String? currentusername;
  String? userRole;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        elevation: 0,
        child: MainDrawer(
          userRole: userRole.toString(),
        ),
      ),
      appBar: ModernAppBar(
        title: userRole == "Admin" || userRole == "Caller"
            ? 'User Management'
            : '',
        subtitle:
            userRole == "Admin" || userRole == "Caller" ? 'Manage Users' : '',
        onMenuPressed: () {
          scaffoldKey.currentState!.openDrawer();
        },
        actions: userRole == "Admin" || userRole == "Caller"
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: DataSearch(
                        allUsersList: allUsersList,
                        currentuserid: currentuserid.toString(),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: userRole == "Admin" || userRole == "Caller"
          ? Container(
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
                    padding: const EdgeInsets.all(16),
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
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.people_rounded,
                                color: kPrimaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "User Management",
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Manage and monitor user accounts",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${allUsersList.length} total users',
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
                      ],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      initialIndex: 0,
                      child: Column(
                        children: [
                          // Modern Tab Bar
                          Container(
                            margin: const EdgeInsets.all(4),
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
                            child: TabBar(
                              labelColor: kPrimaryColor,
                              unselectedLabelColor: Colors.grey[600],
                              indicatorColor: kPrimaryColor,
                              indicatorWeight: 2,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              tabs: const [
                                Tab(
                                  icon: Icon(Icons.person_add_rounded),
                                  text: 'New Users',
                                ),
                                Tab(
                                  icon: Icon(Icons.people_rounded),
                                  text: 'All Users',
                                ),
                              ],
                            ),
                          ),

                          // Tab Content
                          Expanded(
                            child: TabBarView(
                              children: <Widget>[
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: const UserList100(),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: const UserList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const UserNotification(),
    );
  }

  //shared preferences
  late SharedPreferences preferences;
  late String phone;
  Set<String> uniqueUserIds = {};

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      phone = preferences.getString("phone")!;
    });
  }

  Future<void> fetchUserData() async {
    const apiUrl = API.searchUser;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response code :${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print("response body $data");
        if (data['success'] == true) {
          if (!mounted) return;
          setState(() {
            allUsersList.addAll(List<Map<String, dynamic>>.from(data['data']));
          });
        } else {
          print("Failed to execute query");
        }
      } else {
        print("Failed to connect to apis server");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
    fetchUserData();
  }
}

class DataSearch extends SearchDelegate {
  DataSearch({
    this.allUsersList,
    required this.currentuserid,
  });
  var allUsersList;
  String currentuserid;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading Icon on left of appBar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on selection

    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show when someone searches for something
    var userList = [];
    allUsersList.forEach((e) {
      userList.add(e);
    });
    var suggestionList = userList;

    if (query.isNotEmpty) {
      suggestionList = [];
      for (var element in userList) {
        String name = element["name"] ?? "noname";
        String phone = element["phone"] ?? "nophone";
        String uid = element["uid"] ?? "nouid";
        String addedToClass = element["addedToClass"] ?? "noclass";
        String code = element["code"] ?? "nocode";

        if (name.toLowerCase().startsWith(query.toLowerCase()) ||
            phone.toLowerCase().startsWith(query.toLowerCase()) ||
            uid.toLowerCase().startsWith(query.toLowerCase()) ||
            addedToClass.toLowerCase().startsWith(query.toLowerCase()) ||
            code.toLowerCase().startsWith(query.toLowerCase())) {
          suggestionList.add(element);
        }
      }
    }

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
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16),
        itemCount: suggestionList.length,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemBuilder: (context, index) {
          final data = suggestionList[index];

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
    );
  }
}
