import 'package:amategeko/screens/Signup/components/body.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  final String? referralCode;

  SignUpScreen({this.referralCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignUp(referralCode: referralCode),
    );
  }
}
