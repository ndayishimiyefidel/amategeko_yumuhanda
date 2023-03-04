import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import '../../widgets/MainDrawer.dart';
import '../../components/notification_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List allUsers = [];
  var allUsersList;
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  late String quizTitle;
  late SharedPreferences preferences;

  @override
  initState() {
    super.initState();
    getCurrUserId();
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentuserphoto = preferences.getString("photo")!;
      userRole = preferences.getString("role")!;
      phoneNumber = preferences.getString("phone")!;
      print("user role is $userRole");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        elevation: 0,
        child: MainDrawer(),
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
        title: userRole == "Admin"
            ? const Text(
                'Notifications',
                style: TextStyle(letterSpacing: 1.25, fontSize: 24),
              )
            : const Text(
                'My Notifications',
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
                  currentuserphoto: currentuserphoto,
                  phoneNumber: phoneNumber.toString(),
                  code: code.toString(),
                  quizTitle: quizTitle,
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
              stream: userRole == "Admin"
                  ? FirebaseFirestore.instance
                      .collection("Quiz-codes")
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("Quiz-codes")
                      .where("userId",
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .orderBy("createdAt", descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                    child: Center(
                      child: userRole == "Admin"
                          ? const Text(
                              "No available notification right now",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            )
                          : const Text(
                              "There is no notifications for you",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                    child: const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                        kPrimaryColor,
                      )),
                    ),
                  );
                } else {
                  snapshot.data!.docs
                      .removeWhere((i) => i["userId"] == currentuserid);
                  allUsersList = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return UsersNotificationList(
                        name: snapshot.data!.docs[index]["name"],
                        image: snapshot.data!.docs[index]["photoUrl"],
                        time: snapshot.data!.docs[index]["createdAt"],
                        email: snapshot.data!.docs[index]["email"],
                        userId: snapshot.data!.docs[index]["userId"],
                        phone: snapshot.data!.docs[index]["phone"],
                        quizId: snapshot.data!.docs[index]["quizId"],
                        quizTitle: snapshot.data!.docs[index]["quizTitle"],
                        code: snapshot.data!.docs[index]["code"],
                        docId:
                            snapshot.data!.docs[index].reference.id.toString(),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
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
        if (element["name"].toLowerCase().startsWith(query.toLowerCase())) {
          suggestionList.add(element);
        }
      });
    }

    // suggestionList = query.isEmpty
    //     ? suggestionList
    //     : suggestionList
    //         .where((element) => element.startsWith(query.toLowerCase()))
    //         .toList();

    return ListView.builder(
        itemBuilder: (context, index) => ListTile(
              onTap: () {},
              leading: const Icon(Icons.person),
              title: RichText(
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
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16))
                    ]),
              ),
            ),
        itemCount: suggestionList.length);
  }
}
