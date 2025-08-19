import 'package:rwanda_traffic_rules/screens/irembo/components/body.dart';
import 'package:rwanda_traffic_rules/widgets/ModernAppBar.dart';
import 'package:flutter/material.dart';

class IremboSignUpScreen extends StatelessWidget {
  const IremboSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Register',
        subtitle: 'New User',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              _showHelpDialog(context);
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: SignUp(),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Help'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please fill in all required fields:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Full Name (required)'),
              Text('• Phone Number (required)'),
              Text('• Identity Number (required)'),
              Text('• Address (required)'),
              Text('• User Type (required)'),
              SizedBox(height: 8),
              Text(
                'For Permit users, additional fields will appear for category and code.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
