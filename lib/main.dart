import 'package:amategeko/screens/Signup/signup_screen.dart';
import 'package:amategeko/screens/SplashScreen.dart';
import 'package:amategeko/utils/constants.dart';

import 'package:amategeko/utils/utils.dart';
import 'package:amategeko/widgets/exam_img_widget';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uni_links/uni_links.dart';
import 'package:upgrader/upgrader.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
      if (kDebugMode) {
        print('Handling a background message ${message.messageId}');
      }
  }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Initialize deep linking
  final initialLink = await getInitialLink();
  MobileAds.instance.initialize();
  try {
    // Enable Firestore offline persistence (only for web)
    if (kIsWeb) {
      await FirebaseFirestore.instance.enablePersistence();
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error enabling persistence on web: $e");
    }
  }

  // loadInterstitialAd();
  runApp(MyApp(
    initialLink: Uri.parse(initialLink.toString()),
  ));
}
Future<void> handleDeepLink(Uri? link) async {
  try {
    if (link != null && link.queryParameters.containsKey("referral")) {
      String? referralCode = link.queryParameters["referral"];
      if (referralCode != null && referralCode.isNotEmpty) {
        // Navigate to the SignUpScreen with the referral code
        if (kDebugMode) {
          print("my referral");
          print(referralCode);
        }
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignUpScreen(referralCode: referralCode),
          ),
        );
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error handling deep link: $e");
    }
  }
}

InterstitialAd? _interstitialAd;

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: 'ca-app-pub-2864387622629553/2309153588',
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
      },
      onAdFailedToLoad: (error) {
        if (kDebugMode) {
          print('InterstitialAd failed to load: $error');
        }
      },
    ),
  );
}

void showInterstitialAd() {
  if (_interstitialAd != null) {
    _interstitialAd!.show();
    _interstitialAd = null;
  } else {
    if (kDebugMode) {
      print('InterstitialAd is not loaded yet.');
    }
  }
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialLink});

  final Uri? initialLink;

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAdShown = false;
 final String img=Images.quiz10Image;
  @override
  void initState() {
    super.initState();
    handleDeepLink(widget.initialLink); // Handle deep link here
    // Load the interstitial ad when the app opens
    loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rwanda Traffic Rules',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      //flutter local time
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      //default time location
      supportedLocales: const [
        Locale('en', 'US'), // English US
        Locale('en', 'GB'), // English UK
      ],
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: UpgradeAlert(
        child: SplashScreen(
          onAdShown: () {
            if (!_isAdShown) {
              showInterstitialAd();
              _isAdShown = true;
            }
          },
        ),
      ),
    );
  }
}
