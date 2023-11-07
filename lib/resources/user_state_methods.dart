import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enume/user_state.dart';
import '../screens/Login/login_screen.dart';

class UserStateMethods {
  late SharedPreferences preferences;

  void setUserState(
      {required String userId,
      required UserState userState,
      required String userRole}) {}

  Future<void> logoutuser(BuildContext context) async {
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  }
}
