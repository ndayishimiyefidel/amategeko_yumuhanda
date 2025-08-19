import 'dart:convert';
import 'package:rwanda_traffic_rules/ads/ad_manager.dart';
import 'package:rwanda_traffic_rules/resources/user_state_methods.dart';
import 'package:flutter/material.dart';
import '../screens/quizzes/exams.dart';
import 'package:http/http.dart' as http;
import '../screens/amasomo/prayer.dart';
import 'package:app_links/app_links.dart';
import 'package:share_plus/share_plus.dart';
import '../backend/apis/db_connection.dart';
import '../screens/homepages/dashboard.dart';
import 'package:rwanda_traffic_rules/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwanda_traffic_rules/screens/Signup/signup_screen.dart';
import 'package:rwanda_traffic_rules/screens/accounts/AccountSettingsPage.dart';
import 'disclaimer_widget.dart'; // Import disclaimer widget

class MainDrawer extends StatefulWidget {
  final String? userRole;
  final String? referralCode;

  const MainDrawer({
    super.key,
    this.userRole,
    this.referralCode,
  });

  @override
  State createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  late SharedPreferences preferences;
  late String currentuserid = "";
  late String currentusername = "";
  late String userRole = "";
  late String userEmail = "user@email.com";

  final AppLinks _appLinks = AppLinks();

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid") ?? "";
      currentusername = preferences.getString("name") ?? "User";
      userRole = preferences.getString("role") ?? "User";
      userEmail = preferences.getString("email") ?? "user@email.com";
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
    initDeepLinks();
  }

  void showRewardedAd() {
    bool adShown = AdManager.showRewardedAd(context: 'logout');

    if (!adShown) {
      print('Rewarded Ad is not loaded yet.');
    }
  }

  /// ✅ Correct usage of app_links
  Future<void> initDeepLinks() async {
    try {
      final Uri? initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null) {
        handleDeepLink(initialLink);
      }

      _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          handleDeepLink(uri);
        }
      });
    } catch (e) {
      print('Error processing deep links: $e');
    }
  }

  void handleDeepLink(Uri link) {
    if (link.queryParameters.containsKey("referral")) {
      String referralCode = link.queryParameters["referral"]!;
      checkAppInstalled().then((isInstalled) {
        if (isInstalled) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => SignUpScreen(
                referralCode: referralCode,
              ),
            ),
          );
        } else {
          redirectToPlayStore();
        }
      });
    }
  }

  void redirectToPlayStore() {
    String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.rwanda.trafficrules";
    launchUrl(Uri.parse(playStoreLink));
  }

  Future<bool> checkAppInstalled() async {
    const String appPackage = "com.rwanda.trafficrules";
    bool isInstalled = await canLaunchUrl(Uri.parse(appPackage));
    return isInstalled;
  }

  void shareApp() {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.rwanda.trafficrules";
    String message =
        "Practice Rwanda Traffic Rules Pro and quizzes for your driving exam! Download now: $playStoreLink";
    SharePlus.instance.share(
      ShareParams(
        text: message,
        subject:
            'Check out this amazing RWANDA TRAFFIC RULE app on Play Store!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: kPrimaryColor, size: 36),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentusername,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userRole,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Scrollable drawer items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDrawerItem(
                        Icons.dashboard_rounded,
                        "Home",
                        () => Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const Home()))),
                    _buildDrawerItem(
                        Icons.quiz_rounded,
                        "Exams",
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const Exams()))),
                    _buildDrawerItem(
                        Icons.person_rounded,
                        "Profile",
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => UserSettings()))),
                    _buildDrawerItem(
                        Icons.share_rounded, "Share App", () => shareApp()),
                    _buildDrawerItem(
                        Icons.book,
                        "Prayer",
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => Prayer()))),
                    _buildDrawerItem(
                        Icons.info_outline_rounded,
                        "About App",
                        () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AboutPage()))),
                    _buildDrawerItem(
                        Icons.warning_amber_rounded,
                        "Legal Notice",
                        () => DisclaimerWidget.showDisclaimerDialog(context)),
                    _buildDrawerItem(
                        Icons.delete_forever_rounded, "Delete Account", () {
                      showRewardedAd();
                      deleteUser(currentuserid);
                    }, color: Colors.redAccent),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Logout",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  showRewardedAd();
                  UserStateMethods().logoutuser(context);
                  //Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? kPrimaryColor),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? kPrimaryColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  Future<void> deleteUser(String uid) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteSingleUser),
        body: {'uid': uid},
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                )),
            duration: Duration(seconds: 3),
          ),
        );
        UserStateMethods().logoutuser(context);
      } else {
        showErrorSnackBar(
            'Failed to delete account: ${responseData['message']}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      showErrorSnackBar('An error occurred while deleting the account');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            )),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          "About Rwanda Traffic Rules Pro",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 16),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColor,
                    kPrimaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.traffic_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Rwanda Traffic Rules Pro",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your Complete Driving Exam Companion",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content Sections
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Description
                  _buildSection(
                    icon: Icons.info_outline_rounded,
                    title: "About This App",
                    content:
                        "Rwanda Traffic Rules Pro is a comprehensive educational application designed to help users master traffic regulations, practice driving exam questions, and prepare effectively for their driving license tests. Our app provides an interactive learning experience with real exam questions and detailed explanations.",
                  ),

                  const SizedBox(height: 24),

                  // Features Section
                  _buildSection(
                    icon: Icons.star_rounded,
                    title: "Key Features",
                    content: "",
                    isFeatures: true,
                  ),

                  const SizedBox(height: 24),

                  // Educational Purpose
                  _buildSection(
                    icon: Icons.school_rounded,
                    title: "Educational Purpose",
                    content:
                        "This application serves as an educational tool to help users understand and memorize traffic rules, road signs, and driving regulations. It is designed to complement official driving school education and provide additional practice opportunities.",
                  ),

                  const SizedBox(height: 24),

                  // Disclaimer Section
                  _buildSection(
                    icon: Icons.warning_amber_rounded,
                    title: "Important Disclaimer",
                    content:
                        "This application is NOT affiliated with or endorsed by the Rwandan government, Rwanda Police, or any official driving authority. It is an independent educational tool created for learning purposes only. For official traffic laws and regulations, please refer to the Rwanda Police website and official documentation.",
                    isWarning: true,
                  ),

                  const SizedBox(height: 24),

                  // Official Document Link
                  _buildSection(
                    icon: Icons.description_rounded,
                    title: "Official Documentation",
                    content:
                        "For the most accurate and up-to-date traffic laws, please refer to the official Rwanda Traffic Law document published by the Rwanda Police.",
                    hasLink: true,
                  ),

                  const SizedBox(height: 24),

                  // Developer Info
                  _buildSection(
                    icon: Icons.person_rounded,
                    title: "Developer Information",
                    content:
                        "This application was developed by Fidèle Engineer, a dedicated educator committed to helping students prepare for their driving exams.\n\nTagline: Full Stack Developer | Mobile App Developer | Web Developer\n\nFor support or inquiries, please contact: +250780494000",
                  ),

                  const SizedBox(height: 24),

                  // Version Info
                  _buildSection(
                    icon: Icons.app_settings_alt_rounded,
                    title: "App Information",
                    content:
                        "Version: 1.0.0\nPlatform: Android & iOS\nLast Updated: 2024\nCategory: Education",
                  ),

                  const SizedBox(height: 32),

                  // Contact Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        const url =
                            'https://police.gov.rw/uploads/tx_download/Traffic_Law_2015_02.pdf';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text(
                        'View Official Traffic Law Document',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    bool isFeatures = false,
    bool isWarning = false,
    bool hasLink = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isWarning
                      ? Colors.orange.withValues(alpha: 0.1)
                      : kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isWarning ? Colors.orange : kPrimaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isWarning ? Colors.orange : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isFeatures) ...[
            _buildFeatureItem("📚 Comprehensive Question Bank"),
            _buildFeatureItem("🎯 Practice Exams & Quizzes"),
            _buildFeatureItem("📖 Traffic Rules & Regulations"),
            _buildFeatureItem("🚦 Road Signs & Signals"),
            _buildFeatureItem("📊 Progress Tracking"),
            _buildFeatureItem("🔄 Multiple Choice Questions"),
            _buildFeatureItem("📱 User-Friendly Interface"),
            _buildFeatureItem("🎓 Educational Content"),
          ] else ...[
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
          if (hasLink) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                const url =
                    'https://police.gov.rw/uploads/tx_download/Traffic_Law_2015_02.pdf';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: Text(
                "📄 Official Rwanda Traffic Law Document",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
