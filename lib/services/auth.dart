import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../utils/utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //create user
  Future createUser({email, password}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      Utils.ShowSnackBar(e.message);
    }
  }

  //login user
  Future loginUser({email, password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      Utils.ShowSnackBar(e.message);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      Utils.ShowSnackBar(e.message);
    }
  }

  //logout
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  Future<void> deleteUser(String uid) async {
    // Step 1: Delete the user from the "Users" collection
    await FirebaseFirestore.instance.collection("Users").doc(uid).delete();

    // Step 2: Check and delete documents with the same UID from "Quiz-codes" collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: uid)
        .get();

    List<DocumentSnapshot> documents = querySnapshot.docs;
    for (DocumentSnapshot doc in documents) {
      // Delete each document that matches the user's UID
      await doc.reference.delete();
    }
  }

  Future<void> deleteIremboUser(String uid) async {
    // Step 1: Delete the user from the "Users" collection
    await FirebaseFirestore.instance
        .collection("irembo-users")
        .doc(uid)
        .delete();
  }
}
