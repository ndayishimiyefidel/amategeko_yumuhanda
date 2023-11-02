import 'package:amategeko/screens/irembo/components/body.dart';
import 'package:amategeko/utils/constants.dart';
import 'package:flutter/material.dart';

class IremboSignUpScreen extends StatelessWidget {
  const IremboSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('KWIYANDIKISHA'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),

      body: SignUp(),
    );
  }
}
