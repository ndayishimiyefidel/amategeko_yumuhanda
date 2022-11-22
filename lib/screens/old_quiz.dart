import 'package:amategeko/screens/sign_page.dart';
import 'package:amategeko/services/auth.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/appbar.dart';
import 'create_quiz.dart';
import 'open_quiz.dart';

class OldQuiz extends StatefulWidget {
  const OldQuiz({Key? key}) : super(key: key);

  @override
  State<OldQuiz> createState() => _OldQuizState();
}

class _OldQuizState extends State<OldQuiz> {
  Stream<dynamic>? quizStream;
  bool _isLoading = false;
  DatabaseService databaseService = new DatabaseService();
  AuthService authService = new AuthService();
  final user = FirebaseAuth.instance.currentUser;

  Widget quizList() {
    return Container(
        child: StreamBuilder(
      stream: quizStream,
      builder: (context, snapshot) {
        return snapshot.data == null
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return QuizTile(
                    quizId: snapshot.data!.docs[index].data()['quizId'],
                    imgurl: snapshot.data!.docs[index].data()["quizImgUrl"],
                    title: snapshot.data.docs[index].data()["quizTitle"],
                    desc: snapshot.data.docs[index].data()["quizDesc"],
                  );
                });
      },
    ));
  }

  @override
  void initState() {
    databaseService.getQuizData().then((value) async {
      setState(() {
        quizStream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: appBar(context),
        leading: IconButton(
          icon: Icon(Icons.logout_outlined),
          color: Colors.redAccent,
          iconSize: 25,
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });
            await authService.signOut().then((value) {
              setState(() {
                _isLoading = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignInPage();
                    },
                  ),
                );
              });
            });
          },
        ),
      ),
      body: quizList(),
      //floating button

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const CreateQuiz();
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class QuizTile extends StatelessWidget {
  final String imgurl;
  final String title;
  final String desc;
  final String quizId;

  QuizTile(
      {required this.title,
      required this.desc,
      required this.imgurl,
      required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                color: Colors.blueAccent,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OpenQuiz(quizId);
                    },
                  ),
                );
              },
              splashColor: Colors.green,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      height: 5,
                    ),
                    Image.network(
                      imgurl.toString(),
                      height: 100,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    //80% of screen width
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16.0),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(title, textAlign: TextAlign.left),
                          new Text(desc, textAlign: TextAlign.left),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
