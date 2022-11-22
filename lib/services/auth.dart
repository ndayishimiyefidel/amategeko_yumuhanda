import 'package:firebase_auth/firebase_auth.dart';

import '../utils/utils.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

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

  //logout
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
