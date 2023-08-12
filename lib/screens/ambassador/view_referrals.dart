import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/chat_for_users_list.dart';
import '../../utils/constants.dart';

class ViewReferrals extends StatefulWidget {
  final String referralCode;
  final String refUid;

  const ViewReferrals(
      {Key? key, required this.referralCode, required this.refUid})
      : super(key: key);

  @override
  State<ViewReferrals> createState() => _ViewReferralsState();
}

class _ViewReferralsState extends State<ViewReferrals> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List allUsers = [];
  var allUsersList;
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  String? userRole;
  late SharedPreferences preferences;
  late int numbers = 0;
  String? code;
  String? quizTitle;
  String? phoneNumber;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: userRole == "Admin" || userRole == "Ambassador"
            ? const Text(
          'Referral List',
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
          )
        ],
      ),
      key: _scaffoldKey,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .where("referralCode", isEqualTo: widget.referralCode)
                  .orderBy("createdAt", descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery
                        .of(context)
                        .copyWith()
                        .size
                        .height -
                        MediaQuery
                            .of(context)
                            .copyWith()
                            .size
                            .height / 5,
                    width: MediaQuery
                        .of(context)
                        .copyWith()
                        .size
                        .width,
                    child: const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(kPrimaryColor)),
                    ),
                  );
                } else {
                  snapshot.data!.docs
                      .removeWhere((i) => i["uid" ?? ''] == currentuserid);
                  allUsersList = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16, left: 20),
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Quiz-codes")
                            .where("userId",
                            isEqualTo: snapshot.data!.docs[index]["uid"])
                            .snapshots(),
                        builder: (context, quizSnapshot) {
                          if (!quizSnapshot.hasData) {
                            return const SizedBox
                                .shrink(); // Return an empty widget if the quiz data is not available yet.
                          } else {
                            final quizData = quizSnapshot.data!.docs;
                            String? quizCode = quizData.isNotEmpty
                                ? quizData[0]["code"]
                                : "nocode"; // Get the quiz code from the first document in the quiz data.

                            return ChatUsersList(
                              name: snapshot.data!.docs[index]["name"],
                              image: snapshot.data!.docs[index]["photoUrl"],
                              time: snapshot.data!.docs[index]["createdAt"],
                              email: snapshot.data!.docs[index]["email"],
                              userId: snapshot.data!.docs[index]["uid"],
                              phone: snapshot.data!.docs[index]["phone"],
                              password: snapshot.data!.docs[index]["password"],
                              role: snapshot.data!.docs[index]["role"],
                              quizCode: quizCode
                                  .toString(),
                              // Pass the quiz code to the ChatUsersList widget.
                              deviceId: snapshot.data!.docs[index]
                              ["deviceId"],
                            );
                          }
                        },
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
        if (element["name"].toLowerCase().startsWith(query.toLowerCase()) ||
            element["phone"].toLowerCase().startsWith(query.toLowerCase()) ||
            element["email"].toLowerCase().startsWith(query.toLowerCase()) ||
            element["password"].toLowerCase().startsWith(query.toLowerCase())) {
          suggestionList.add(element);
        }
      });
    }
    return ListView.builder(
        itemBuilder: (context, index) =>
            ListTile(
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
