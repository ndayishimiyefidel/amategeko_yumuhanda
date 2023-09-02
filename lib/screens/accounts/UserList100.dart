import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/chat_for_users_list.dart';
import '../../utils/constants.dart';
import '../../widgets/changing_banner.dart';

class UserList100 extends StatefulWidget {
  const UserList100({super.key});

  @override
  _UserList100State createState() => _UserList100State();
}

class _UserList100State extends State<UserList100> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late BannerAd _bannerAd;
  bool isBannerLoaded = false;
  bool isBannerVisible = false;
  Timer? bannerTimer;

  // List allUsers = [];
  var allUsersList;
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late String userRole;
  late SharedPreferences preferences;
  late int numbers = 0;

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
    FirebaseFirestore.instance
        .collection("Users")
        .orderBy("createdAt", descending: true)
        .get()
        .then((value) {
      numbers = value.docs.length;
      print(numbers);
    });
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
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .orderBy("createdAt", descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                    child: const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(kPrimaryColor)),
                    ),
                  );
                } else {
                  snapshot.data!.docs
                      .removeWhere((i) => i["uid"] == currentuserid);
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
                              quizCode: quizCode.toString(),
                              // Pass the quiz code to the ChatUsersList widget.
                              deviceId: snapshot.data!.docs[index]["deviceId"],
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
