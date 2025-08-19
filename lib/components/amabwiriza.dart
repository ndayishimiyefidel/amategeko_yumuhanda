import '../widgets/ModernAppBar.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rwanda_traffic_rules/utils/constants.dart';

class AmabwirizaList extends StatelessWidget {
  void shareApp() {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.rwanda.trafficrules";

    final String message =
        "Check out this amazing RWANDA TRAFFIC RULE app on Play Store! It contains all the questions and answers asked in the provisional license exam. All exams are included as they will ask you one of them or give you 20 questions from the app. Perfect for anyone wanting to get their Provisional license using an easy and reliable method. This app will be very helpful for you! Download here: $playStoreLink";

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
    return Scaffold(
      appBar: ModernAppBar(
        title: 'ABOUT THE APPLICATION',
        subtitle: 'Instructions & Guidelines',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              kPrimaryLightColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withValues(alpha: 0.1),
                      kPrimaryLightColor.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school,
                        size: 40,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Rwanda Traffic Rules Pro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Master traffic regulations with confidence',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Instructions Cards
              _buildInstructionCard(
                icon: Icons.info_outline,
                title: 'ABOUT THE APPLICATION',
                description:
                    "This application called ``Rwanda Traffic Rules Pro`` is an educational app that teaches traffic laws. It contains all the questions asked in the provisional license exam (temporary driving permit).",
                color: Colors.blue,
              ),

              const SizedBox(height: 16),

              _buildInstructionCard(
                icon: Icons.how_to_reg,
                title: 'HOW TO USE THE APPLICATION',
                description:
                    '1. To use this application, you must first register on the app when you download it for the first time. You will be asked to enter your name and phone number.\n\n2. If you are already registered, you don\'t need to register again. Instead, click on "Login" and enter your phone number, then click "Confirm" and you will go to the dashboard where you will find all the content in the application.\n\n3. To start learning, click on "Exam". When you open it, there will be 21 exams, each exam has 20 questions, but the first exam is free, the remaining ones require payment.\n\n4. When you are practicing in this application, click on the box you have selected. If it turns green, it means you got it right, if it turns red, it means you got it wrong. After you finish, click "next" to go to the next question. When you reach the end, click "Finish exam" and you will immediately see your score, then click on "home" to choose another exam to study.',
                color: Colors.green,
              ),

              const SizedBox(height: 16),

              _buildInstructionCard(
                icon: Icons.computer,
                title: 'WHAT YOU WILL FIND IN THE ACTUAL EXAM',
                description:
                    "1. When you go to the provisional exam on the machine, you will find these questions that are in this application exactly as they appear in the exam. No question they will ask in the provisional exam is not in this application. When you select an answer, click on it and continue to the next question, then click next and continue with other questions. When you finish, click ``FINISH EXAM`` and you will immediately know your score right away, and you can also review what you answered and what you did.\n\n2. The same applies to the provisional exam on the machine - when you click here, they will show you the correct answer below, and you won't see it elsewhere.",
                color: Colors.orange,
              ),

              const SizedBox(height: 16),

              _buildInstructionCard(
                icon: Icons.payment,
                title: 'PAYMENT TO UNLOCK ALL EXAMS',
                description:
                    '1. As I explained earlier, the first exam is free, the remaining 20 require payment of 1500 RWF to 0788659575/0728877442 or via MOMO PAY: 329494 registered to Alexis.\n\n2. After you make the payment, check if you have an internet connection, then open the exam and click on "Request code" in blue color, or click on "Request code" in yellow color, then go back and wait for five minutes before you start studying, and you will see that they have been unlocked.',
                color: Colors.purple,
              ),

              const SizedBox(height: 16),

              // Contact Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
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
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.contact_phone,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'IMPORTANT CONTACT INFORMATION',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem('0788659575'),
                    const SizedBox(height: 8),
                    _buildContactItem('0728877442'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Share App Card
              GestureDetector(
                onTap: shareApp,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.1),
                        Colors.blue.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.share,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share Application',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Share with friends and family',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String phoneNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            phoneNumber,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Call',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the existing InstructionItem class for backward compatibility
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
