import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/foundation.dart';
import 'package:rwanda_traffic_rules/utils/utils.dart';
import 'package:rwanda_traffic_rules/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rwanda_traffic_rules/screens/SplashScreen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:rwanda_traffic_rules/ads/ad_manager.dart'; // Import ad manager

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Configure test device for AdMob
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ['SP1A.210812.016TECNO'],
    ),
  );
  MobileAds.instance.initialize();

  // Initialize ads
  AdManager.initializeAds();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rwanda Traffic Rules Pro',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English US
        Locale('en', 'GB'), // English UK
      ],
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: UpgradeAlert(
        child: const DisclaimerWrapper(), // Show disclaimer first
      ),
    );
  }
}

class DisclaimerWrapper extends StatefulWidget {
  const DisclaimerWrapper({super.key});

  @override
  _DisclaimerWrapperState createState() => _DisclaimerWrapperState();
}

class _DisclaimerWrapperState extends State<DisclaimerWrapper> {
  @override
  void initState() {
    super.initState();
    _checkDisclaimer();
  }

  Future<void> _checkDisclaimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool disclaimerShown = prefs.getBool('disclaimerShown') ?? false;

    if (!disclaimerShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDisclaimerDialog();
      });
    } else {
      _navigateToHome();
    }
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: kPrimaryColor,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Disclaimer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: kPrimaryColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'This app is not affiliated with or endorsed by the Rwandan government or the Rwanda Police. It provides educational resources for learning about traffic rules, based on publicly available documents. For official guidance, please refer to the Rwanda Police website directly.',
                style: TextStyle(
                    fontSize: 15, color: Colors.grey[800], height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  const url =
                      'https://police.gov.rw/uploads/tx_download/Traffic_Law_2015_02.pdf';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
                child: Text(
                  'View the official document',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Agree'),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('disclaimerShown', true);
                  Navigator.of(context).pop();
                  _navigateToHome();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
