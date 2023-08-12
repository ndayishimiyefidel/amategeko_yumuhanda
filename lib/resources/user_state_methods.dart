import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enume/user_state.dart';
import '../screens/Login/login_screen.dart';
import '../utils/utils.dart';

class UserStateMethods {
  late SharedPreferences preferences;

  void setUserState(
      {required String userId,
      required UserState userState,
      required String userRole}) {
    int stateNum = Utils.stateToNum(userState);
    FirebaseFirestore.instance.collection("Users").doc(userId).update({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({required String uid}) =>
      FirebaseFirestore.instance.collection("Users").doc(uid).snapshots();

  Future<void> logoutuser(BuildContext context) async {
    preferences = await SharedPreferences.getInstance();
    setUserState(
        userId: preferences.getString("uid").toString(),
        userRole: preferences.getString("role").toString(),
        userState: UserState.Offline);
    await FirebaseAuth.instance.signOut();
    // await preferences.clear();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false);
  }
}
