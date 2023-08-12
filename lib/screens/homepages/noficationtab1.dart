import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/notification_list_modified.dart';
import '../../widgets/changing_banner.dart';

class NotificationTab1 extends StatefulWidget {
  const NotificationTab1({super.key});

  @override
  _NotificationTab1State createState() => _NotificationTab1State();
}

class _NotificationTab1State extends State<NotificationTab1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late BannerAd _bannerAd;
  bool isBannerLoaded = false;
  bool isBannerVisible = true;
  Timer? bannerTimer;

  var allUsersList;
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  late String quizTitle;
  late SharedPreferences preferences;

  InterstitialAd? _interstitialAd;
  Timer? interstitialTimer;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2864387622629553/2309153588',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      //_interstitialAd = null;
    } else {
      print('InterstitialAd is not loaded yet.');
    }
  }

  @override
  void initState() {
    super.initState();
    loadInterstitialAd();

    // Start the timer to show the interstitial ad every 4 minutes
    // interstitialTimer = Timer.periodic(const Duration(minutes: 4), (timer) {
    //   showInterstitialAd();
    // });

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
    // bannerTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
    //   setState(() {
    //     isBannerVisible = true;
    //   });
    // });
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
  void dispose() {
    // Dispose the banner timer when the widget is disposed
    _bannerAd.dispose();
    bannerTimer?.cancel();
    _interstitialAd!.dispose();
    interstitialTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (isBannerVisible && isBannerLoaded)
              BannerAdWidget(ad: _bannerAd),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Quiz-codes")
                  // .where("createdAt", isNotEqualTo: "")
                  .orderBy("createdAt", descending: true)
                  .limit(200)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  var filteredDocs = snapshot.data!.docs;
                  filteredDocs.removeWhere((i) => i["userId"] == currentuserid);

                  // Eliminate duplicates based on document ID
                  var docIds = <String>{};
                  var uniqueDocs = <DocumentSnapshot>[];
                  for (var doc in filteredDocs) {
                    if (docIds.add(doc.id)) {
                      uniqueDocs.add(doc);
                    }
                  }

                  // Sort the unique documents by "createdAt" field
                  uniqueDocs.sort((a, b) {
                    DateTime dateTimeA = DateTime.fromMillisecondsSinceEpoch(
                        int.parse((a["createdAt"] as String)) ~/ 1000);
                    DateTime dateTimeB = DateTime.fromMillisecondsSinceEpoch(
                        int.parse((b["createdAt"] as String)) ~/ 1000);
                    return dateTimeA.compareTo(dateTimeB);
                  });

                  allUsersList = uniqueDocs;
                  print("abafite code");
                  print(uniqueDocs.length);
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: filteredDocs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final data =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      return Column(
                        children: <Widget>[
                          ModifiedUsersNotificationList(
                            name: data["name"] ?? "Unknown Name",
                            // image: data["photoUrl"],
                            time: data["createdAt"] ?? "Unknown Time",
                            email: data["email"] ?? "Unknown Email",
                            userId: data["userId"] ?? "Unknown User ID",
                            phone: data["phone"] ?? "Unknown Phone",
                            // quizId: data["quizId"],
                            quizTitle:
                                data["quizTitle"] ?? "Unknown Quiz Title",
                            code: data["code"] ?? "Unknown Code",
                            docId: uniqueDocs[index].reference.id.toString(),
                            // isQuiz: data["isQuiz"],
                            endTime: data.containsKey("endTime")
                                ? data["endTime"]
                                : "1684242113231",
                          ),
                          if (index <
                              uniqueDocs.length -
                                  1) // Check if not the last item
                            const Divider(),
                          // Add a Divider widget between items
                        ],
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
