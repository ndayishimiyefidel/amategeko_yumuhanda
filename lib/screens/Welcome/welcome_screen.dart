import 'package:flutter/material.dart';
import 'package:rwanda_traffic_rules/screens/Welcome/components/body.dart';

class WelcomeScreen extends StatelessWidget {
  final String min_version;
  const WelcomeScreen({super.key, required this.min_version});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        minVersion: min_version,
      ),
    );
  }
}
