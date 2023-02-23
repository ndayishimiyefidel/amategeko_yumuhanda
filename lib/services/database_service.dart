import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
//create account
  Future<void> createUserAccount(
      Map<String, dynamic> userData, String userId) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .set(userData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addQuizData(Map<String, dynamic> quizData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quizmaker")
        .doc(quizId)
        .set(quizData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> uploadGroupData(Map<String, dynamic> fileData) async {
    await FirebaseFirestore.instance
        .collection("Groups")
        .add(fileData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> uploadDocsData(Map<String, dynamic> fileData) async {
    await FirebaseFirestore.instance
        .collection("Documents")
        .add(fileData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> updateDocsData(Map<String, dynamic> fileData, docId) async {
    await FirebaseFirestore.instance
        .collection("Documents")
        .doc(docId)
        .update(fileData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUploadedDocs() async {
    return FirebaseFirestore.instance.collection("Documents").snapshots();
  }

  getGroupList() async {
    return FirebaseFirestore.instance.collection("Groups").snapshots();
  }

//adding question to quiz
  Future<void> addQuestionData(
      Map<String, dynamic> questionData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quizmaker")
        .doc(quizId)
        .collection("QNA")
        .add(questionData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> updateQuestionData(
      Map<String, dynamic> questionData, String quizId, String question) async {
    await FirebaseFirestore.instance
        .collection("Quizmaker")
        .doc(quizId)
        .collection("QNA")
        .where("question", isEqualTo: question)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        String docsId = doc.reference.id;
        print("subdoc_id${doc.reference.id}");
        await FirebaseFirestore.instance
            .collection("Quizmaker")
            .doc(quizId)
            .collection("QNA")
            .doc(docsId)
            .update(questionData)
            .onError((error, stackTrace) {
          print(error);
        });
      });
    });
  }

  getOldQuizData() async {
    return FirebaseFirestore.instance
        .collection("Quizmaker")
        .where("quizType", isEqualTo: "Free")
        .orderBy("quizTitle", descending: true)
        .snapshots();
  }

  getNewQuizData() async {
    return FirebaseFirestore.instance
        .collection("Quizmaker")
        .where("quizType", isEqualTo: "Paid")
        .orderBy("quizTitle", descending: true)
        .snapshots();
  }

  getQuizQuestion(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quizmaker")
        .doc(quizId)
        .collection("QNA")
        .get();
  }
}
