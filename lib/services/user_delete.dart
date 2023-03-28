import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String uid;

  DatabaseServices({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  Future deleteuser() {
    return userCollection.doc(uid).delete();
  }
}
