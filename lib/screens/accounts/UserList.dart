import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/chat_for_users_list.dart';
import '../../utils/constants.dart';
import '../../widgets/changing_banner.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late BannerAd _bannerAd;
  bool isBannerLoaded = false;
  bool isBannerVisible = false;
  Timer? bannerTimer;

  // List allUsers = [];

  List<DocumentSnapshot> allUsersList = [];
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late SharedPreferences preferences;
  late int numbers = 0;

  // Define a variable to keep track of the number of users to load at once
  final int usersPerPage = 20;

  // Define a variable to keep track of the current page (chunk) of users
  int currentPage = 0;

  // Define a variable to store whether more users are being loaded
  bool isLoadingMore = false;

  @override
  initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2864387622629553/7276208106',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
        // Add other banner ad listener callbacks as needed.
      ),
    );

    _bannerAd.load();
    // Initialize the banner timer
    bannerTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {
        isBannerVisible = true;
      });
    });
    getCurrUserId();
    _loadUserData(); // Initial fetching of users
  }

  // Function to check internet connectivity
  Future<bool> _checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _loadUserData() async {
    bool isConnected = await _checkInternetConnectivity();

    if (isConnected) {
      // Fetch and load user data from Firestore
      _fetchUsers();
    } else {
      // Handle no internet connection
      // Load cached user data from SharedPreferences
      await _loadCachedUserData();
    }
  }

  Future<void> _loadCachedUserData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String cachedUserData = preferences.getString("cachedUserData") ?? "";

    setState(() {
      allUsersList = List.from(jsonDecode(cachedUserData));
      numbers = allUsersList.length;
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

  // Define a function to fetch the next chunk of users from Firestore
// Define a variable to store the last document of the previous page
  DocumentSnapshot? lastDocument;

  // Define a function to fetch the next chunk of users from Firestore
  Future<void> _fetchUsers() async {
    setState(() {
      isLoadingMore = true;
    });

    Query query = FirebaseFirestore.instance
        .collection("Users")
        .orderBy("createdAt", descending: true)
        .limit(usersPerPage);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final QuerySnapshot querySnapshot = await query.get();

    setState(() {
      isLoadingMore = false;
      currentPage++;
      numbers = querySnapshot.size; // Update the total number of users

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last; // Store the last document
      }
    });

    if (querySnapshot.docs.isNotEmpty) {
      allUsersList.addAll(querySnapshot.docs);
    }
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;

      // Cache the fetched user data
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("cachedUserData", jsonEncode(allUsersList));
    }
  }

  @override
  void dispose() {
    // Dispose the banner timer when the widget is disposed
    _bannerAd.dispose();
    bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            if (isBannerVisible && isBannerLoaded)
              BannerAdWidget(ad: _bannerAd),
            Center(
              child: Container(
                decoration: const BoxDecoration(color: Colors.green),
                child: Text(
                  "Total User: $numbers",
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                      ),
                    ),
                  );
                } else {
                  snapshot.data!.docs
                      .removeWhere((i) => i["uid"] == currentuserid);
                  allUsersList = snapshot.data!.docs;

                  return ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.only(top: 16, left: 20),
                    itemCount: allUsersList.length + 1,
                    // Add one for loading indicator
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index < allUsersList.length) {
                        final user = allUsersList[index];
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Quiz-codes")
                              .where("userId", isEqualTo: user["uid"])
                              .snapshots(),
                          builder: (context, quizSnapshot) {
                            if (!quizSnapshot.hasData) {
                              return const SizedBox.shrink();
                            } else {
                              final quizData = quizSnapshot.data!.docs;
                              String? quizCode = quizData.isNotEmpty
                                  ? quizData[0]["code"]
                                  : "nocode";

                              return ChatUsersList(
                                name: user["name"],
                                image: user["photoUrl"],
                                time: user["createdAt"],
                                email: user["email"],
                                userId: user["uid"],
                                phone: user["phone"],
                                password: user["password"],
                                role: user["role"],
                                quizCode: quizCode.toString(),
                                deviceId: user["deviceId"],
                              );
                            }
                          },
                        );
                      } else {
                        // If it's the last item, show a loading indicator to fetch more users
                        return isLoadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }
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

// The rest of your code (ChatUsersList class and other imports) remains unchanged

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
