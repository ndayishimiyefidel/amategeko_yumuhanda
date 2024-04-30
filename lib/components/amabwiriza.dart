import 'package:amategeko/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/insttruction.dart';
import '../widgets/apptext.dart';

class AmabwirizaList extends StatelessWidget {
  void shareApp() {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.amategeko.amategeko";

    final String message = "${AppText.playStoreMessage} $playStoreLink";

    // Share the message containing the link (with or without referral code)
    Share.share(
      message,
      subject: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppText.appRules,
        ),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.ikaze,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              InstructionItem(
                title: AppText.instruction1Title,
                description: AppText.instruction1Description,
              ),
              InstructionItem(
                title: AppText.instruction2Title,
                description: AppText.instruction2Description,
              ),
              InstructionItem(
                title: AppText.instruction3Title,
                description: AppText.instruction3Description,
              ),
              InstructionItem(
                title: AppText.instruction4Title,
                description: AppText.instruction4Description,
              ),
              InstructionItems(
                title: AppText.instruction5Title,
                phoneNumbers: ['0788659575', '0728877442'],
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: shareApp, // Call the shareApp function
                leading: IconButton(
                  onPressed: shareApp, // Call the shareApp function
                  icon: const Icon(
                    Icons.share,
                    size: 30,
                    color: Colors.blueAccent,
                  ),
                ),
                contentPadding: const EdgeInsets.only(
                  left: 60,
                  top: 5,
                  bottom: 5,
                ),
                title: const Text(
                  AppText.shareButtonText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InstructionItem extends StatelessWidget {
  final String title;
  final String description;

  InstructionItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          description,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
