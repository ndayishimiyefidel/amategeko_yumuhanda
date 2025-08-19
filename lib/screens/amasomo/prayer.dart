import '../../utils/constants.dart';
import 'package:flutter/material.dart';
import '../homepages/notificationtab.dart';

class Prayer extends StatefulWidget {
  const Prayer({Key? key}) : super(key: key);

  @override
  State<Prayer> createState() => _PrayerState();
}

class _PrayerState extends State<Prayer> {
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
          "Prayer & Blessings",
          style: TextStyle(
            letterSpacing: 1.25,
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Prayer for Success",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Seeking God's guidance for your driving exam",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Prayer Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    _buildPrayerSection(
                      title: "Greeting",
                      content:
                          "Hello and welcome! I am Mwarimu Alexis NSHIMIYIMANA, and I am honored to have you in this application. I am dedicated to helping students register and prepare for their driving permits.",
                    ),

                    const SizedBox(height: 24),

                    // Services Offered
                    _buildPrayerSection(
                      title: "Services Offered",
                      content:
                          "I assist students in preparing for driving permits including:\n• Provisional License\n• Definitive License\n• Categories: A, B, C, D, E, F, and more",
                    ),

                    const SizedBox(height: 24),

                    // Prayer Request
                    _buildPrayerSection(
                      title: "Prayer for Success",
                      content:
                          "We pray to God to help us prepare well for our driving exams. May He grant us good results and provide us with all the resources we need, including school fees and other necessities. May God hear our prayers and grant them in His perfect timing.",
                      isPrayer: true,
                    ),

                    const SizedBox(height: 24),

                    // Application Users
                    _buildPrayerSection(
                      title: "For All Users",
                      content:
                          "This application is open to everyone: teachers, professors, doctors, medical professionals, business people, students, soldiers, police officers, government workers, and all others. Let us pray together, for prayer is the key to everything.",
                    ),

                    const SizedBox(height: 24),

                    // Thanksgiving Prayer
                    _buildPrayerSection(
                      title: "Thanksgiving Prayer",
                      content:
                          "Lord God in heaven, we thank You and praise You for the grace You have shown us. You have protected us today and in the past, and You continue to watch over us so that the enemy cannot harm us. We breathe the Spirit of life, but first, forgive us all our sins that we have committed against You, so that our prayer may reach You like a sweet fragrance. We trust in You for our exams. You are the one who gives success, help us prepare well for what we study, give us what we need (school fees, minutes, MBs, time, and other things). When we succeed, give us good jobs, our own vehicles, and other blessings. Protect us from accidents, keep us away from evil spirits and demons in our lives and our families. In the name of JESUS, we ask this, believing that You will do everything. AMEN. Thank you.",
                      isPrayer: true,
                    ),

                    const SizedBox(height: 24),

                    // Contact Information
                    _buildPrayerSection(
                      title: "Contact Information",
                      content:
                          "For support or inquiries, please contact:\nMwarimu NSHIMIYIMANA Alexis\nPhone: 0788659575",
                      isContact: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerSection({
    required String title,
    required String content,
    bool isPrayer = false,
    bool isContact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPrayer
                    ? Colors.blue.withValues(alpha: 0.1)
                    : isContact
                        ? Colors.green.withValues(alpha: 0.1)
                        : kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPrayer
                    ? Icons.favorite_rounded
                    : isContact
                        ? Icons.contact_phone_rounded
                        : Icons.info_outline_rounded,
                color: isPrayer
                    ? Colors.blue
                    : isContact
                        ? Colors.green
                        : kPrimaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPrayer
                      ? Colors.blue
                      : isContact
                          ? Colors.green
                          : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.6,
            fontStyle: isPrayer ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
