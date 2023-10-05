import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/notification_list_modified.dart';
import '../../utils/constants.dart';
import '../../widgets/changing_banner.dart';
class NotificationTab1 extends StatefulWidget {
  const NotificationTab1({Key? key}) : super(key: key);

  @override
  State createState() => _NotificationTab1State();
}
class _NotificationTab1State extends State<NotificationTab1> {
  late BannerAd _bannerAd;
  bool isBannerLoaded = false;
  bool isBannerVisible = true;

  List<Map<String, dynamic>> allUsersList = [];
  String? currentuserid;
  String? currentusername;
  late String currentuserphoto;
  String? userRole;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    getCurrUserId();
    loadAds();
  }

  Future<void> loadAds() async {
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
    await _bannerAd.load();
  }

  Future<void> getCurrUserId() async {
    final preferences = await SharedPreferences.getInstance();
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
    _bannerAd.dispose();
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
            if (isBannerVisible && isBannerLoaded) BannerAdWidget(ad: _bannerAd),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("Quiz-codes")
                  .orderBy("createdAt", descending: true)
                  .limit(500)
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
                  // documents.removeWhere((doc) => doc["userId"] == currentuserid);
                  allUsersList = documents
                  .where((doc) => doc["code"] != null && doc["code"].isNotEmpty) // Filter out empty or null "code" fields
                  .where((doc) => doc["userId"] != currentuserid)
                  .map((doc) {
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
                  // allUsersList.sort((a, b) => b["time"].compareTo(a["time"]));
                  if (kDebugMode) {
                    print("Abafite code  ${allUsersList.length}");
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: allUsersList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final data = allUsersList[index];
                      return ModifiedUsersNotificationList(
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
