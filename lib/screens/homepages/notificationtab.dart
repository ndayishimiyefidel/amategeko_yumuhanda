import 'dart:convert';
import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import '../../widgets/MainDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../homepages/notificationtab2.dart';
import '../../backend/apis/db_connection.dart';
import 'package:rwanda_traffic_rules/components/search_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwanda_traffic_rules/screens/homepages/noficationtab1.dart';
import '../../widgets/ModernAppBar.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allUsersList = [];
  String? currentUserId;
  String? userRole;
  late SharedPreferences preferences;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = preferences.getString("uid");
      userRole = preferences.getString("role");
    });

    if (userRole == "Admin" || userRole == "Caller") {
      fetchQuizData();
    } else {
      // Delay execution to prevent UI glitches
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _shareApp(context);
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchQuizData() async {
    const apiUrl = API.fetchQuizData;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            allUsersList = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print("Failed to execute query");
        }
      } else {
        print("Failed to connect to API");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _shareApp(BuildContext context) {
    const String appLink =
        "https://play.google.com/store/apps/details?id=com.rwanda.trafficrules";
    SharePlus.instance.share(
      ShareParams(
        text:
            "Iyi application igizwe n'ibibazo n'ibisubizo babaza muri examin ya provisoire iga examin zose zirimo kuko bazakubaza imwe muri zo: $appLink",
        subject:
            'Check out this amazing RWANDA TRAFFIC RULE app on Play Store!',
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    if (isLoading) {
      return Scaffold(
        body: Container(
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
          child: Center(
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
          ),
        ),
      );
    }

    if (userRole == "Admin" || userRole == "Caller") {
      return Scaffold(
        key: scaffoldKey,
        drawer: const Drawer(child: MainDrawer()),
        appBar: ModernAppBar(
          title: 'Notifications',
          subtitle: 'Manage Requests',
          onMenuPressed: () => scaffoldKey.currentState!.openDrawer(),
          actions: [
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
                      currentuserid: currentUserId!),
                );
              },
            )
          ],
        ),
        body: Container(
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
                                "Notification Center",
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Manage user requests and notifications",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Total Requests: ${allUsersList.length}",
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
                        margin: const EdgeInsets.all(16),
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
                        child: TabBar(
                          labelColor: kPrimaryColor,
                          unselectedLabelColor: Colors.grey[600],
                          indicatorColor: kPrimaryColor,
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.person_add_rounded),
                              text: 'Without Code',
                            ),
                            Tab(
                              icon: Icon(Icons.verified_user_rounded),
                              text: 'With Code',
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
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: const NotificationTab2(),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: const NotificationTab1(),
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
        ),
      );
    } else {
      return Scaffold(
        body: Container(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  "Loading...",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
        if (element["name"]?.toLowerCase()?.startsWith(query.toLowerCase()) ==
                true ||
            element["phone"]?.toLowerCase()?.startsWith(query.toLowerCase()) ==
                true ||
            element["id"]?.toLowerCase()?.startsWith(query.toLowerCase()) ==
                true ||
            element["addedToClass"]
                    ?.toLowerCase()
                    ?.startsWith(query.toLowerCase()) ==
                true ||
            element["code"]?.toLowerCase()?.startsWith(query.toLowerCase()) ==
                true) {
          suggestionList.add(element);
        }
      }
    }

    if (suggestionList.isEmpty) {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No results found for "$query"',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
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
          return SearchWidget(
            name: data["name"] ?? '',
            time: data["createdAt"],
            userId: data["userId"] ?? '',
            phone: data["phone"] ?? '',
            code: data["code"] ?? '',
            ex_type: data['ex_type'] ?? '',
            endTime: data["endTime"] ?? "1684242113231",
            docId: data['id'] ?? '',
          );
        },
      ),
    );
  }
}
