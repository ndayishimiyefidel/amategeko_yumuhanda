import 'dart:convert';
import 'package:amategeko/screens/homepages/notificationtab.dart';
import 'package:amategeko/screens/irembo/irembo_widget.dart';
import 'package:amategeko/utils/constants.dart';
import 'package:amategeko/widgets/MainDrawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../backend/apis/db_connection.dart';

class Abiyandikishe extends StatefulWidget {
  const Abiyandikishe({super.key});

  @override
  State createState() => _AbiyandikisheState();
}

class _AbiyandikisheState extends State<Abiyandikishe> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  Future<void> fetchAllUsers() async {
    final apiUrl = API.abiyandikishije+"?from=$from&to=$to";
    isLoading = true;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print(data);

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
    fetchAllUsers(); // Load the initial 10 records
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            key: _scaffoldKey,
      drawer:const Drawer(
        elevation: 0,
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: const Text(
          "Abashaka Kwiyandikisha",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Notifications(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 25,
              ),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
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
                        child: Text("no data available"),
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
                              return IremboUsersList(
                                name: data["name"] ?? '',
                                time: data["createdAt"],
                                userId: data["uid"] ?? '',
                                myPhone: data["phone"] ?? '',
                                identity: data['identity'] ?? '',
                                myAddress: data["address"] ?? '',
                                code: data["code"] ?? 'nocode',
                                type: data['type'] ?? 'notype',
                                category: data['category'] ?? 'nocategory',
                              );
                            },
                          ),
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
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
