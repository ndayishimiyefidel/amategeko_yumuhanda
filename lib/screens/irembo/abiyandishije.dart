import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/MainDrawer.dart';
import '../homepages/notificationtab.dart';
import 'irembo_widget.dart';

class Abiyandikishe extends StatefulWidget {
  const Abiyandikishe({super.key});

  @override
  State createState() => _AbiyandikisheState();
}

class _AbiyandikisheState extends State<Abiyandikishe> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List allUsers = [];
  var allUsersList;
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late String userRole;
  late SharedPreferences preferences;
  late int numbers = 0;

  @override
  initState() {
    super.initState();
    getCurrUserId();
    FirebaseFirestore.instance
        .collection("irembo-users")
        .orderBy("createdAt", descending: true)
        .get()
        .then((value) {
      numbers = value.docs.length;
      print(numbers);
    });
  }

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();

    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer:const Drawer(
        elevation: 0,
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: const Text(
          "Abashaka Kwiyandikisha",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Notifications(),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 25,
              ),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("irembo-users")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height -
                        MediaQuery.of(context).copyWith().size.height / 5,
                    width: MediaQuery.of(context).copyWith().size.width,
                    child: const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(kPrimaryColor)),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16, left: 20),
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return IremboUsersList(
                        name: snapshot.data!.docs[index]["name"],
                        time: snapshot.data!.docs[index]["createdAt"],
                        userId: snapshot.data!.docs[index]["uid"],
                        myPhone: snapshot.data!.docs[index]["phone"],
                        identity: snapshot.data!.docs[index]["identity"],
                        myAddress: snapshot.data!.docs[index]["address"],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
