import 'dart:convert';

import 'package:amategeko/screens/homepages/usernotification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../backend/apis/db_connection.dart';
import '../../utils/constants.dart';
import '../../utils/generate_code.dart';
import '../../widgets/MainDrawer.dart';
import 'UserList.dart';
import 'UserList100.dart';
import 'package:http/http.dart' as http;

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
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        title: userRole == "Admin" || userRole == "Caller"
            ? const Text(
                'User List',
                style: TextStyle(letterSpacing: 1.25, fontSize: 24),
              )
            : const Text(
                '',
                style: TextStyle(letterSpacing: 1.25, fontSize: 24),
              ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
        ],
      ),
      body: userRole == "Admin" || userRole == "Caller"
          ? SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  DefaultTabController(
                    length: 2, // length of tabs
                    initialIndex: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black26,
                            indicatorColor: Colors.black,
                            tabs: [
                              Tab(text: 'New Users'),
                              Tab(text: 'Old Users'),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height *
                              0.9, //height of TabBarView
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: const TabBarView(
                            children: <Widget>[
                              UserList(),
                              UserList100(),
                            ],
                          ),
                        ),
                      ],
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
    final apiUrl = API.searchUser;

    try {
      final response = await http.get(Uri.parse(apiUrl));

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
        print("Failed to connect to api");
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

    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) => ListTile(
        onTap: () {},
        leading: const Icon(Icons.person),
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text at the beginning
          children: [
            RichText(
              text: TextSpan(
                text: suggestionList[index]["name"]
                    .toLowerCase()
                    .substring(0, query.length),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text: suggestionList[index]["name"]
                        .toLowerCase()
                        .substring(query.length),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: suggestionList[index]["code"] != null
                        ? suggestionList[index]["code"]
                            .toLowerCase()
                            .substring(0, query.length)
                        : "",
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: suggestionList[index]["phone"]
                        .toLowerCase()
                        .substring(0, query.length),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: suggestionList[index]["phone"]
                            .toLowerCase()
                            .substring(query.length),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                IconButton(
                  onPressed: () async {
                    await FlutterPhoneDirectCaller.callNumber(
                      suggestionList[index]["phone"].toLowerCase(),
                    );
                  },
                  icon: const Icon(
                    Icons.call,
                    size: 30,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),

            //row for delete,add to class,generate code
            (suggestionList[index]["userId"] != null ||
                    suggestionList[index]["userId"] != "")
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final url = API.addedToClass;
                          if (suggestionList[index]["addedToClass"] == null ||
                              suggestionList[index]["addedToClass"] == "") {
                            GenerateUser.addedRemoveToClass(
                                context,
                                suggestionList[index]["uid"].toString(),
                                url,
                                "Success added to class",
                                "Added");
                          } else {
                            GenerateUser.addedRemoveToClass(
                                context,
                                suggestionList[index]["uid"].toString(),
                                url,
                                "Remove from  class successfully",
                                "");
                          }
                        },
                        icon: Icon(
                          (suggestionList[index]["addedToClass"] == "" ||
                                  suggestionList[index]["addedToClass"] == null)
                              ? Icons.add_outlined
                              : Icons.remove,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final code = suggestionList[index]["code"];
                          bool hasKey = code != "" ? true : false;
                          final confirmed =
                              await _showConfirmationDialog(context, hasKey);
                          if (confirmed == true) {
                            // Perform the delete operation
                            String generatedCode = randomNumeric(6);
                            if (hasKey) {
                              GenerateUser.generateCodeAndNotify(
                                  context,
                                  suggestionList[index]["uid"],
                                  "",
                                  suggestionList[index]["name"],
                                  "code deleted successfully of ",
                                  0);
                            } else {
                              GenerateUser.generateCodeAndNotify(
                                  context,
                                  suggestionList[index]["uid"].toString(),
                                  generatedCode,
                                  suggestionList[index]["name"].toString(),
                                  "Generate code is $generatedCode of ",
                                  1);
                            }
                          } else {
                            final url = API.deleteCode;
                            GenerateUser.deleteUserCode(
                                context,
                                suggestionList[index]["uid"],
                                url,
                                suggestionList[index]["name"].toString(),
                                "Deleted successfully");
                          }
                        },
                        icon: const Icon(
                          Icons.close_outlined,
                          size: 30,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
      itemCount: suggestionList.length,
    );
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context, bool hasCode) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Remove/Deletion'),
          content: const Text('Are you sure you want to delete or remove ?'),
          actions: <Widget>[
            TextButton(
              child: hasCode
                  ? const Text('Remove Code')
                  : const Text('Activate Code'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}
