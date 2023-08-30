import 'package:amategeko/screens/homepages/usernotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/MainDrawer.dart';
import 'UserList.dart';
import 'UserList100.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers>
    with SingleTickerProviderStateMixin {
  var allUsersList;
  String? currentuserid;
  String? currentusername;
  String? currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  String? quizTitle;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
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
            _scaffoldKey.currentState!.openDrawer();
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
                  currentusername: currentusername.toString(),
                  currentuserphoto: currentuserphoto.toString(),
                  phoneNumber: phoneNumber.toString(),
                  code: code.toString(),
                  quizTitle: quizTitle.toString(),
                ),
              );
            },
          ),
        ],
      ),
      body: userRole == "Admin" || userRole == "Caller"
          ? SingleChildScrollView(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  DefaultTabController(
                    length: 2, // length of tabs
                    initialIndex: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Container(
                            child: const TabBar(
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.black26,
                              indicatorColor: Colors.black,
                              tabs: [
                                Tab(text: 'New users'),
                                Tab(text: 'All Users'),
                              ],
                            ),
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
                              UserList100(),
                              UserList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Users")
                            .orderBy("createdAt", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox(
                              height: MediaQuery.of(context)
                                      .copyWith()
                                      .size
                                      .height -
                                  MediaQuery.of(context)
                                          .copyWith()
                                          .size
                                          .height /
                                      5,
                              width:
                                  MediaQuery.of(context).copyWith().size.width,
                              child: const Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                  kPrimaryColor,
                                )),
                              ),
                            );
                          } else {
                            snapshot.data!.docs.removeWhere(
                                (i) => i["uid" ?? ''] == currentuserid);
                            allUsersList = snapshot.data!.docs;
                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 16, left: 20),
                              itemCount: snapshot.data!.docs.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  child: null,
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const UserNotification(),
    );
  }

  //shared preferences
  late SharedPreferences preferences;
  late String email;
  late String photo;
  late String phone;
  String userToken = "";

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      photo = preferences.getString("photo")!;
      phone = preferences.getString("phone")!;
      email = preferences.getString("email")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
  }
}

class DataSearch extends SearchDelegate {
  DataSearch({
    this.allUsersList,
    required this.currentuserid,
    required this.currentusername,
    required this.currentuserphoto,
    required this.phoneNumber,
    required this.code,
    required this.quizTitle,
  });

  var allUsersList;
  String currentuserid;
  String quizTitle;
  String currentusername;
  String currentuserphoto;
  String phoneNumber;
  String code;

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
      userList.forEach((element) {
        if (element["name"].toLowerCase().startsWith(query.toLowerCase()) ||
            element["phone"].toLowerCase().startsWith(query.toLowerCase()) ||
            element["email"].toLowerCase().startsWith(query.toLowerCase()) ||
            element["password"].toLowerCase().startsWith(query.toLowerCase())) {
          suggestionList.add(element);
        }
      });
    }
    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              onTap: () {},
              leading: const Icon(Icons.person),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: suggestionList[index]["name"]
                            .toLowerCase()
                            .substring(0, query.length),
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        children: [
                          TextSpan(
                              text: suggestionList[index]["name"]
                                  .toLowerCase()
                                  .substring(query.length),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16))
                        ]),
                  ),
                  RichText(
                    text: TextSpan(
                        text: suggestionList[index]["email"]
                            .toLowerCase()
                            .substring(0, query.length),
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        children: [
                          TextSpan(
                              text: suggestionList[index]["email"]
                                  .toLowerCase()
                                  .substring(query.length),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16))
                        ]),
                  ),
                  RichText(
                    text: TextSpan(
                        text: suggestionList[index]["password"]
                            .toLowerCase()
                            .substring(0, query.length),
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                        children: [
                          TextSpan(
                              text: suggestionList[index]["password"]
                                  .toLowerCase()
                                  .substring(query.length),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16))
                        ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: suggestionList[index]["phone"]
                                .toLowerCase()
                                .substring(0, query.length),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16),
                            children: [
                              TextSpan(
                                  text: suggestionList[index]["phone"]
                                      .toLowerCase()
                                      .substring(query.length),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 16))
                            ]),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      IconButton(
                        onPressed: () async {
                          await FlutterPhoneDirectCaller.callNumber(
                              suggestionList[index]["phone"]
                                  .toLowerCase()
                                  .substring(query.length));
                        },
                        icon: const Icon(
                          Icons.call,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        itemCount: suggestionList.length);
  }
}
