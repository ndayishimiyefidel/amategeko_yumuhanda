import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/chat_for_users_list.dart';
import '../../utils/constants.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List allUsers = [];
  var allUsersList;
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late SharedPreferences preferences;
  late int number = 0;

  @override
  initState() {
    super.initState();
    getCurrUserId();
    FirebaseFirestore.instance.collection("Users").get().then((value) {
      number = value.docs.length;
      print(number);
    });
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentuserphoto = preferences.getString("photo")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Users List',
          style: TextStyle(letterSpacing: 1.25, fontSize: 24),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
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
                      currentuserid: currentuserid,
                      currentusername: currentusername,
                      currentuserphoto: currentuserphoto));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
              child: Text(
                "Total number of users is : $number",
                style: const TextStyle(
                  fontSize: 22,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .where("role", isNotEqualTo: "Admin")
                  // .orderBy("role", descending: true)
                  // .orderBy("createAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                    child: const Center(
                      child: Text(
                        "There is no user registered yet!",
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
                      .removeWhere((i) => i["uid"] == currentuserid);
                  allUsersList = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatUsersList(
                        name: snapshot.data!.docs[index]["name"],
                        image: snapshot.data!.docs[index]["photoUrl"],
                        time: snapshot.data!.docs[index]["createdAt"],
                        email: snapshot.data!.docs[index]["email"],
                        isMessageRead: true,
                        userId: snapshot.data!.docs[index]["uid"],
                        phone: snapshot.data!.docs[index]["phone"],
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
  DataSearch(
      {this.allUsersList,
      required this.currentuserid,
      required this.currentusername,
      required this.currentuserphoto});

  var allUsersList;
  String currentuserid;
  String currentusername;
  String currentuserphoto;

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
              onTap: () {
                // close(context, null);
                // Navigator.push(context, MaterialPageRoute(builder: (context) {
                //   return Chat(
                //     receiverId: suggestionList[index]["uid"],
                //     receiverAvatar: suggestionList[index]["photoUrl"],
                //     receiverName: suggestionList[index]["name"],
                //     currUserId: currentuserid,
                //     currUserName: currentusername,
                //     currUserAvatar: currentuserphoto,
                //   );
                // }));
              },
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
