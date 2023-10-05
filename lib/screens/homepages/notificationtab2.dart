import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/notification_list.dart';
import '../../utils/constants.dart';
import '../../widgets/changing_banner.dart';

class NotificationTab2 extends StatefulWidget {
  const NotificationTab2({super.key});

  @override
  State createState() => _NotificationTab2State();
}

class _NotificationTab2State extends State<NotificationTab2> {
  late BannerAd _bannerAd;
  bool isBannerLoaded = false;
  bool isBannerVisible = true;
  Timer? bannerTimer;

  // List allUsers = [];
  List<Map<String, dynamic>> allUsersList = [];
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;
  String? code;
  late String quizTitle;
  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    getCurrUserId();
    _loadAds();
  }
  void _loadAds() async{
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
      ),
    );

    _bannerAd.load();
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentuserphoto = preferences.getString("photo")!;
      userRole = preferences.getString("role")!;
      phoneNumber = preferences.getString("phone")!;
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
                  return const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(kPrimaryColor));
                } else if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.size == 0) {
                  return const Center(
                    child: Text("No data available"),
                  );
                } else {
                  final documents = snapshot.data!.docs;
                  documents.removeWhere((doc) => doc["userId"] == currentuserid);
                  allUsersList = documents.map((doc) {
                    final data = doc.data();
                    return {
                      "name": data["name"],
                      "time": data["createdAt"],
                      "email": data["email"],
                      "userId": data["userId"],
                      "phone": data["phone"],
                      "quizTitle": data["quizTitle"],
                      "code": data["code"],
                      "endTime": data.containsKey("endTime")
                          ? data["endTime"]
                          : "1684242113231",
                      "docId": doc.reference.id.toString(),
                    };
                  }).toList();
                  if (kDebugMode) {
                    print("Abadafite code ${allUsersList.length}");
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: allUsersList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                    final data = allUsersList[index];
                      return UsersNotificationList(
                        name: data["name"],
                        time: data["time"],
                        email: data["email"],
                        userId: data["userId"],
                        phone: data["phone"],
                        quizTitle: data["quizTitle"],
                        code: data["code"],
                        endTime: data.containsKey("endTime")
                            ? data["endTime"]
                            : "1684242113231",
                        docId: data['docId'],
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
