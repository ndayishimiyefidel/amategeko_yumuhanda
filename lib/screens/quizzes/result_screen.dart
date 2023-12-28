import 'package:amategeko/screens/quizzes/exams.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../ads/reward_video_manager.dart';
import '../../utils/constants.dart';
import '../homepages/notificationtab.dart';

class Results extends StatefulWidget {
  final int correct, incorrect, total;

  const Results(
      {super.key,
      required this.correct,
      required this.incorrect,
      required this.total});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  //check whether the person is failed or not
  String status = "";

  _checkFailed() {
    // double pass = (widget.correct + widget.incorrect) / 2 + 2;
    if (widget.correct < 12) {
      if (kDebugMode) {
        print("failed");
      }
      status = "Failed";
    } else {
      status = "Passed";
      if (kDebugMode) {
        print("passed");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFailed();
    RewardedVideoAdManager.loadRewardAd();
  }

  void showRewardedAd() {
    bool adShown = RewardedVideoAdManager.showRewardAd();

    if (!adShown) {
      print('Rewarded Ad is not loaded yet.');
    }
  }

  @override
  void dispose() {
    RewardedVideoAdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Results",
          style: TextStyle(
            letterSpacing: 1.25,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Notifications(),
                ),
              );
            },
          )
        ],
        centerTitle: true,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You have $status ",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "${widget.correct} / ${widget.total}",
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "You have Answered ${widget.correct}  correctly and ${widget.incorrect} incorrectly",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withOpacity(1.0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  showRewardedAd();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Exams()));
                },
                child: const Text("Go Home"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
