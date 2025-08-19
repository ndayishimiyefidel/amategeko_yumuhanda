import 'package:flutter/material.dart';
import 'package:rwanda_traffic_rules/screens/Signup/components/body.dart';

class SignUpScreen extends StatelessWidget {
  final String? referralCode;

  const SignUpScreen({super.key, this.referralCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignUp(referralCode: referralCode),
    );
  }
}
