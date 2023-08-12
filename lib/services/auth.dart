import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      print(e.toString());
      Utils.ShowSnackBar(e.message);
    }
  }

  // PHONE SIGN IN
  // Future<void> phoneSignIn(
  //     BuildContext context,
  //     String phoneNumber,
  //     ) async {
  //   TextEditingController codeController = TextEditingController();
  //   if (kIsWeb) {
  //     // !!! Works only on web !!!
  //     ConfirmationResult result =
  //     await _auth.signInWithPhoneNumber(phoneNumber);
  //
  //     // Diplay Dialog Box To accept OTP
  //     showOTPDialog(
  //       codeController: codeController,
  //       context: context,
  //       onPressed: () async {
  //         PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //           verificationId: result.verificationId,
  //           smsCode: codeController.text.trim(),
  //         );
  //
  //         await _auth.signInWithCredential(credential);
  //         Navigator.of(context).pop(); // Remove the dialog box
  //       },
  //     );
  //   } else {
  //     // FOR ANDROID, IOS
  //     await _auth.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       //  Automatic handling of the SMS code
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         // !!! works only on android !!!
  //         await _auth.signInWithCredential(credential);
  //       },
  //       // Displays a message when verification fails
  //       verificationFailed: (e) {
  //         showSnackBar(context, e.message!);
  //       },
  //       // Displays a dialog box when OTP is sent
  //       codeSent: ((String verificationId, int? resendToken) async {
  //         showOTPDialog(
  //           codeController: codeController,
  //           context: context,
  //           onPressed: () async {
  //             PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //               verificationId: verificationId,
  //               smsCode: codeController.text.trim(),
  //             );
  //
  //             // !!! Works only on Android, iOS !!!
  //             await _auth.signInWithCredential(credential);
  //             Navigator.of(context).pop(); // Remove the dialog box
  //           },
  //         );
  //       }),
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         // Auto-resolution timed out...
  //       },
  //     );
  //   }
  // }

  //logout
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
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
