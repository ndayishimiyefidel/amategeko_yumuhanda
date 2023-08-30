import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/notification_list.dart';
import '../../utils/constants.dart';
import '../../widgets/changing_banner.dart';

class NotificationTab2 extends StatefulWidget {
  const NotificationTab2({super.key});

  @override
  _NotificationTab2State createState() => _NotificationTab2State();
}

class _NotificationTab2State extends State<NotificationTab2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late BannerAd _bannerAd;
  bool isBannerLoaded = false;
  bool isBannerVisible = true;
  Timer? bannerTimer;

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

    //banner
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
    _interstitialAd?.dispose();
    interstitialTimer?.cancel();
    bannerTimer?.cancel();
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
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("Quiz-codes")
                  .where("code", isEqualTo: "")
                  .where("createdAt", isNotEqualTo: "")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kPrimaryColor));
                } else if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.size == 0) {
                  return Center(
                    child: Text("No data available"),
                  );
                } else {
                  List<DocumentSnapshot<Map<String, dynamic>>> documents =
                      snapshot.data!.docs;
                  documents
                      .removeWhere((doc) => doc["userId"] == currentuserid);
                  allUsersList = documents;
                  print("Abadafite code");
                  print(documents.length);
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: documents.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final data = documents[index].data();
                      return UsersNotificationList(
                        name: data!["name"],
                        // image: data["photoUrl"],
                        time: data["createdAt"],
                        email: data["email"],
                        userId: data["userId"],
                        phone: data["phone"],
                        // quizId: data["quizId"],
                        quizTitle: data["quizTitle"],
                        code: data["code"],
                        endTime: data.containsKey("endTime")
                            ? data["endTime"]
                            : "1684242113231",
                        docId: documents[index].reference.id.toString(),
                        // isQuiz: data["isQuiz"],
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
