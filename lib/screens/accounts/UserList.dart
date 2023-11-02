import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/chat_for_users_list.dart';
import '../../utils/constants.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late String currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initCurrentUser();
  }

  Future<void> _initCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString("uid") ?? "defaultUserID";
    setState(() {
      currentUserId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _fetchUserList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingIndicator();
            } else if (snapshot.hasError) {
              return _buildErrorText(snapshot.error.toString());
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return _buildNoDataText();
            } else {
              return _buildUserListView(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _fetchUserList() async {
    final querySnapshot = await _firestore
        .collection("Users")
        .orderBy("createdAt", descending: true)
        .get();

    return querySnapshot.docs
        .where((doc) => doc.get("uid") != currentUserId)
        .toList();
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(kPrimaryLightColor),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    if (kDebugMode) {
      print("Firestore Error: $error");
    }
    return Center(child: Text("An error has occurred: $error"));
  }

  Widget _buildNoDataText() {
    return Center(child: Text("No data available"));
  }

  Widget _buildUserListView(List<QueryDocumentSnapshot> users) {
    print("Fetched Users ${users.length} ");
    return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            // final data = users[index].data();
            final userId = users[index].get("uid") ?? currentUserId;

            return FutureBuilder<String>(
              future: _fetchQuizCode(userId.toString()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  final quizCode = snapshot.data ?? "nocode";
                  final deviceId =
                      users[index].get("deviceId") ?? "No device captured";
                  final name = users[index].get("name") ?? "Unknown Name";
                  final time = users[index].get("createdAt") ?? "1696125054318";
                  //final userId = users[index].get("uid") ?? currentUserId;
                  final phone = users[index].get("phone");
                  final password = users[index].get("password");
                  final role = users[index].get("role") ?? "User";
                  return ChatUsersList(
                    name: name,
                    time: time,
                    userId: userId,
                    phone: phone,
                    password: password,
                    role: role,
                    deviceId: deviceId,
                    quizCode: quizCode,
                  );
                }
              },
            );
          },
        ));
  }

  Future<String> _fetchQuizCode(String userId) async {
    final querySnapshot = await _firestore
        .collection("Quiz-codes")
        .where("userId", isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0].get("code").toString();
    } else {
      return "nocode";
    }
  }
}
