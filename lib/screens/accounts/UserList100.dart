import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/chat_for_users_list.dart';
import '../../utils/constants.dart';

class UserList100 extends StatefulWidget {
  const UserList100({Key? key}) : super(key: key);

  @override
  State createState() => _UserList100State();
}

class _UserList100State extends State<UserList100> {
  late String currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> loadedUsers = [];
  int initialUserCount = 10;
  int totalUserCount = 0;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initCurrentUser();
    _loadInitialUsers();
  }

  Future<void> _initCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUserId = preferences.getString("uid")!;
      });
    }
  }

  Future<void> _loadInitialUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection("Users")
          .orderBy("createdAt", descending: true)
          .limit(initialUserCount)
          .get();

      totalUserCount = querySnapshot.size;
      final initialUsers = querySnapshot.docs
          .where((doc) => doc["uid"] != currentUserId)
          .toList();
      print("total rows user $totalUserCount");

      if (mounted) {
        setState(() {
          loadedUsers.addAll(initialUsers);
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Firestore Error: $e");
      }

      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kPrimaryLightColor),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: loadedUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder<String?>(
                    future: _fetchQuizCode(loadedUsers[index]["uid"]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else {
                        final quizCode = snapshot.data ?? "nocode";
                        final deviceId = loadedUsers[index].get("deviceId") ??
                            "No device captured";
                        return ChatUsersList(
                          name: loadedUsers[index].get("name"),
                          time: loadedUsers[index].get("createdAt") ??
                              "1696125054318",
                          userId: loadedUsers[index].get("uid"),
                          phone: loadedUsers[index].get("phone"),
                          password: loadedUsers[index].get("password"),
                          role: loadedUsers[index].get("role") ?? "User",
                          deviceId: deviceId,
                          quizCode: quizCode,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          if (loadedUsers.length < totalUserCount)
            ElevatedButton(
              onPressed: _loadMoreUsers,
              child: Text('Load MoreloadedUsers'),
            ),
          if (hasError) Text('An error has occurred.'),
        ],
      ),
    );
  }

  Future<void> _loadMoreUsers() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final querySnapshot = await _firestore
          .collection("Users")
          .orderBy("createdAt", descending: true)
          .startAfterDocument(loadedUsers.last)
          .limit(initialUserCount)
          .get();

      if (mounted) {
        final moreUsers = querySnapshot.docs
            .where((doc) => doc["uid"] != currentUserId)
            .toList();

        setState(() {
          loadedUsers.addAll(moreUsers);
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Firestore Error: $e");
      }

      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }

  Future<String> _fetchQuizCode(String userId) async {
    final querySnapshot = await _firestore
        .collection("Quiz-codes")
        .where("userId", isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0]["code"].toString();
    } else {
      return "nocode";
    }
  }

  @override
  void dispose() {
    // Dispose of any resources here.
    super.dispose();
  }
}
