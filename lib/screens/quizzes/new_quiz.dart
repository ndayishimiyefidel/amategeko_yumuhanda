import 'dart:async';

import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/questions/add_question.dart';
import 'package:amategeko/services/auth.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_network/image_network.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants.dart';
import '../../widgets/ProgressWidget.dart';
import '../../widgets/banner_widget.dart';
import '../../widgets/fcmWidget.dart';
import 'edit_quiz.dart';
import 'open_quiz.dart';

class NewQuiz extends StatefulWidget {
  const NewQuiz({Key? key}) : super(key: key);

  @override
  State<NewQuiz> createState() => _NewQuizState();
}

class _NewQuizState extends State<NewQuiz> {
  BannerAd? _bannerAd;
  bool isBannerLoaded = false;
  bool isBannerVisible = false;
  Timer? bannerTimer;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Stream<dynamic>? quizStream;
  bool isLoading = false;
  DatabaseService databaseService = DatabaseService();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  AuthService authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  //shared preferences
  late SharedPreferences preferences;
  late String currentuserid;
  late String currentusername;
  late String email;
  late String photo;
  String? userRole;
  String? adminPhone;
  int examno = 0;

  late String phone;
  String userToken = "";
  late int totalQuestion = 0;
  bool hasCode = false;

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      photo = preferences.getString("photo")!;
      phone = preferences.getString("phone")!;
      email = preferences.getString("email")!;
    });
    FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentuserid.toString())
        .where("isOpen", isEqualTo: true)
        .get()
        .then((value) {
      if (value.size == 1) {
        setState(() {
          hasCode = true;
          print(hasCode);
        });
      }
    });
  }

  getToken() async {
    //delete quiz
    await FirebaseFirestore.instance
        .collection("Users")
        .where("role", isEqualTo: "Admin")
        .get()
        .then((value) {
      if (value.size == 1) {
        Map<String, dynamic> adminData = value.docs.first.data();
        userToken = adminData["fcmToken"];
        adminPhone = adminData["phone"];
        print("Admin Token is  $userToken");
      }
    });
  }

  //check if user has code
  Widget quizList() {
    return Expanded(
      child: StreamBuilder(
        stream: quizStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.none:
              // Use cached data if available
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collectionGroup("Quizmaker")
                    .where("quizType", isEqualTo: "Paid")
                    .orderBy("quizTitle", descending: true)
                    .get(const GetOptions(source: Source.cache)),
                builder: (context, cacheSnapshot) {
                  if (cacheSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (cacheSnapshot.hasError) {
                    return const Text('Error loading cached data');
                  }
                  if (cacheSnapshot.data == null ||
                      cacheSnapshot.data!.docs.isEmpty) {
                    return const Text('Error: No cached data available');
                  }
                  return ListView.builder(
                    itemCount: cacheSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      // Use cached data
                      final doc = cacheSnapshot.data!.docs[index];
                      return QuizTile(
                        index: index,
                        quizId: doc.data()['quizId'],
                        imgurl: doc.data()["quizImgUrl"],
                        title: doc.data()["quizTitle"],
                        desc: doc.data()["quizDesc"],
                        quizType: doc.data()["quizType"],
                        totalQuestion: totalQuestion,
                        userRole: userRole.toString(),
                        userToken: userToken,
                        senderName: currentusername,
                        currentUserId: currentuserid,
                        phone: phone,
                        email: email,
                        photoUrl: photo,
                        quizPrice: doc.data()["quizPrice"],
                        adminPhone: adminPhone.toString(),
                      );
                    },
                  );
                },
              );
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return snapshot.data == null
                    ? const Center(
                        child: Text(
                          "There is no available quiz at this time ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 2,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          // Update cache with new data
                          FirebaseFirestore.instance
                              .collection("Quizmaker")
                              .doc(snapshot.data.docs[index].data()['quizId'])
                              .collection("QNA")
                              .get()
                              .then((value) {
                            // Cache the new data
                            value.docs.forEach((doc) {
                              doc.reference
                                  .set(doc.data(), SetOptions(merge: true));
                            });
                          });

                          return QuizTile(
                            index: index,
                            quizId: snapshot.data!.docs[index].data()['quizId'],
                            imgurl:
                                snapshot.data!.docs[index].data()["quizImgUrl"],
                            title:
                                snapshot.data.docs[index].data()["quizTitle"],
                            desc: snapshot.data.docs[index].data()["quizDesc"],
                            quizType:
                                snapshot.data.docs[index].data()["quizType"],
                            totalQuestion: totalQuestion,
                            userRole: userRole.toString(),
                            userToken: userToken,
                            senderName: currentusername,
                            currentUserId: currentuserid,
                            phone: phone,
                            email: email,
                            photoUrl: photo,
                            quizPrice:
                                snapshot.data.docs[index].data()["quizPrice"],
                            adminPhone: adminPhone.toString(),
                          );
                        },
                      );
              }
          }
        },
      ),
    );
  }

  @override
  void initState() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2864387622629553/7276208106',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
        // Add other banner ad listener callbacks as needed.
      ),
    );

    _bannerAd!.load();
    // Initialize the banner timer
    // bannerTimer = Timer.periodic(const Duration(seconds: 300), (timer) {
    //   setState(() {
    //     isBannerVisible = true;
    //   });
    // });

    ///update

    _messaging.getToken().then((value) {
      print("My token is $value");
    });
    databaseService.getNewQuizData().then((value) async {
      setState(() {
        quizStream = value;
      });
    });
    //check code
    getCurrUserData(); //get login data
    requestPermission(); //request permission
    loadFCM(); //load fcm
    listenFCM(); //list fcm
    getToken(); //get admin token
    FirebaseMessaging.instance;
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the banner timer when the widget is disposed
    _bannerAd!.dispose();
    bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appbar
        key: _scaffoldKey,
        body: Column(
          children: [
            quizList(),
            const SizedBox(
              height: 10,
            ),
            const AdBannerWidget(),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
        floatingActionButton: (userRole != "Admin" && hasCode == false)
            ? FloatingActionButton.extended(
                label: const Row(
                  children: [
                    Text(
                      "Saba Code ya application",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Column(
                            children: [
                              Text(
                                "REQUEST CODE",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "1.Saba code igufasha gufungura application,kugirango uhabwe kode ubanza kwishyura 1500 rwf ukanze mu ibara ry'icyatsi cyangwa ukanze *182*8*1*329494*1500# kuri momo pay",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.blueAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          "2.Iyo Umanze kwishyura ukanda hano hasi handitse saba kode mu ibara ry'umuhondo ibi byose ubikora wafunguye connection",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.redAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          "3.Hanyuma ugategereza hagati y'iminota 2 kugeza kuri 5 ubundi ugasubira inyuma ugakanda ahanditse Tangira Exam ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.blueAccent,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow, elevation: 3),
                              onPressed: () async {
                                //saba code
                                requestCode(userToken, currentuserid,
                                    currentusername, "Exam");
                              },
                              child: const Text(
                                "Saba Code",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  onPressed: () async {
                                    //direct phone call
                                    await FlutterPhoneDirectCaller.callNumber(
                                        "*182*8*1*329494*1500#");
                                  },
                                  child: const Text(
                                    "Kanda hano *182*8*1*329494*1500# wishyure",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            // TextButton(
                            //     onPressed: () {
                            //       Navigator.of(context).pop();
                            //     },
                            //     child: const Text("Close"))
                          ],
                        );
                      });
                },
              )
            : null);
  }

  Future<void> requestCode(String userToken, String currentUserId,
      String senderName, String title) async {
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName naho nimero ya telefoni ni  Namaze kwishyura amafaranga 1500 kuri 0788659575 yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    //make sure that request is not already sent
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("isQuiz", isEqualTo: true)
        .get()
        .then((value) {
      if (value.size == 0) {
        Map<String, dynamic> checkCode = {
          "userId": currentUserId,
          "name": senderName,
          "email": email,
          "phone": phone,
          "photoUrl": photo,
          "quizId": "gM34wj99547j4895",
          "quizTitle": title,
          "code": "",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "isOpen": false,
          "isQuiz": true,
        };
        FirebaseFirestore.instance
            .collection("Quiz-codes")
            .add(checkCode)
            .then((value) {
          //send push notification
          sendPushMessage(userToken, body, notificationTitle);
          setState(() {
            isLoading = false;
            Size size = MediaQuery.of(context).size;
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                        "Ubusabe bwawe bwakiriwe neza, Kugirango ubone kode ikwinjiza muri exam banza wishyure."),
                    actions: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: size.width * 0.7,
                        height: size.height * 0.07,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor),
                            onPressed: () async {
                              //direct phone call
                              await FlutterPhoneDirectCaller.callNumber(
                                  "*182*8*1*329494*1500#");
                            },
                            child: const Text(
                              "Ishyura 1500 Rwf.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close"))
                    ],
                  );
                });
          });
        });
      } else {
        setState(() {
          print(value.size);
          isLoading = false;
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text(
                      "Your request have been already sent,Please wait the team is processing it."),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"))
                  ],
                );
              });
        });
      }
    });
  }
}

class BannerAdWidget extends StatelessWidget {
  final BannerAd ad;

  const BannerAdWidget({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: size.width.toDouble(),
        height: 50.0, // Set the desired height for the banner ad
        child: AdWidget(ad: ad),
      ),
    );
  }
}

class QuizTile extends StatefulWidget {
  final String imgurl;
  final String title;
  final String desc;
  final String quizId;
  final String quizType;
  final int totalQuestion;
  final String userRole;
  final String userToken;
  final String adminPhone;
  final String senderName;
  final String phone;
  final bool isNew = false;
  final String currentUserId;
  final String quizPrice;
  final String email, photoUrl;
  final int index;

  const QuizTile({
    Key? key,
    required this.imgurl,
    required this.title,
    required this.desc,
    required this.quizId,
    required this.quizType,
    required this.totalQuestion,
    required this.userToken,
    required this.senderName,
    required this.phone,
    required this.currentUserId,
    required this.email,
    required this.photoUrl,
    required this.userRole,
    required this.quizPrice,
    required this.adminPhone,
    required this.index,
  }) : super(key: key);

  @override
  State<QuizTile> createState() => _QuizTileState();
}

class _QuizTileState extends State<QuizTile> {
  bool _isLoading = false;
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: kPrimaryColor,
                width: size.width * 0.003,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: InkWell(
              splashColor: kPrimaryColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      SizedBox(
                        width: double.infinity, // Full width
                        height: size.height * 0.4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ImageNetwork(
                            image: widget.imgurl.toString(),
                            imageCache: CachedNetworkImageProvider(
                                widget.imgurl.toString()),
                            height: size.height * 0.3,
                            width: size.width * 0.9,
                            fitAndroidIos: BoxFit.cover,
                            fitWeb: BoxFitWeb.cover,
                            onLoading: const CircularProgressIndicator(
                              color: Colors.indigoAccent,
                            ),
                            onError: const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                            // errorBuilder: (context, error, stackTrace) {
                            //   print(error);
                            //   return const Text(
                            //       "Failed to load image due network connection");
                            // },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Text("${widget.index + 1}. ${widget.title}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.start),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Text(
                        widget.desc,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.blueGrey,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      _isLoading
                          ? circularprogress()
                          : Container(
                              child: null,
                            ),
                      if (widget.userRole != "Admin")
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              side: const BorderSide(
                                  color: Colors.green, width: 1),
                            ),
                            onPressed: () {
                              if (widget.quizType == "Free") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return OpenQuiz(
                                        quizId: widget.quizId,
                                        title: widget.title,
                                        quizNumber: widget.index + 1,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                ///check whether you already have code.
                                FirebaseFirestore.instance
                                    .collection("Quiz-codes")
                                    .where("userId",
                                        isEqualTo: widget.currentUserId)
                                    .where("isOpen", isEqualTo: true)
                                    .where("isQuiz", isEqualTo: true)
                                    .get()
                                    .then((value) {
                                  if (value.size == 1) {
                                    //open quiz without code.
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return OpenQuiz(
                                            quizId: widget.quizId,
                                            title: widget.title,
                                            quizNumber: widget.index + 1,
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    ///display dialogue to enter exam code.

                                    final TextEditingController codeController =
                                        TextEditingController();
                                    String code = "";
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Column(
                                              children: [
                                                Text(
                                                  "CODE VERIFICATION",
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  "Shyiramo code wahawe umaze kwishyura application niba nta kode ufite kanda hepfo mwibara ry'ubururu uyisabe.",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                              ],
                                            ),
                                            content: Form(
                                              key: _formkey,
                                              child: TextFieldContainer(
                                                child: TextFormField(
                                                  autofocus: false,
                                                  controller: codeController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onSaved: (value) {
                                                    codeController.text =
                                                        value!;
                                                  },
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  decoration:
                                                      const InputDecoration(
                                                    icon: Icon(
                                                      Icons.code_off_outlined,
                                                      color: kPrimaryColor,
                                                    ),
                                                    hintText:
                                                        "Shyiramo kode ya appplication ",
                                                    border: InputBorder.none,
                                                  ),
                                                  onChanged: (val) {
                                                    code = val;
                                                  },
                                                  autovalidateMode:
                                                      AutovalidateMode.disabled,
                                                  validator: (input) => input!
                                                          .isEmpty
                                                      ? 'Gukomeza bisaba Kode'
                                                      : null,
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        kPrimaryColor,
                                                    elevation: 3),
                                                onPressed: () async {
                                                  if (_formkey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    checkValidCode(
                                                      widget.currentUserId,
                                                      code,
                                                      widget.quizId,
                                                    );
                                                  }
                                                },
                                                child: const Text(
                                                  "Emeza",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Close"))
                                            ],
                                          );
                                        });
                                  }
                                });
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Tangira Exam",
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: size.width * 0.02,
                                ),
                                const Icon(
                                  Icons.start,
                                  size: 30,
                                )
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return OpenQuiz(
                                              quizId: widget.quizId,
                                              title: widget.title,
                                              quizNumber: widget.index + 1,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "View",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.1,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryLightColor,
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return EditQuiz(
                                              quizId: widget.quizId,
                                              quizTitle: widget.title,
                                              quizType: widget.quizType,
                                              quizImage: widget.imgurl,
                                              quizDesc: widget.desc,
                                              quizPrice: widget.quizPrice,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Edit Quiz",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.03,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return AddQuestion(
                                              quizId: widget.quizId,
                                              quizTitle: widget.title,
                                              isNew: true,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Add",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.03,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryLightColor),
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      _showDeleteConfirmationDialog();
                                      //  deleteQuiz(widget.quizId);
                                    },
                                    child: const Text(
                                      "Delete Quiz",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//delete quiz
  Future<void> deleteQuiz(String docId) async {
    await FirebaseFirestore.instance
        .collection("Quizmaker")
        .doc(docId)
        .collection("QNA")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete().then((value) {
          //question delete
          setState(() {
            _isLoading = false;
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text("Quiz deleted successfully!"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close"))
                    ],
                  );
                });
          });
        });
      });
      FirebaseFirestore.instance.collection("Quizmaker").doc(docId).delete();
    });
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete Quiz'),
          content: const Text('Are you sure you want to delete this quiz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Perform the delete operation here
                deleteQuiz(widget.quizId);
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _isLoading = true;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> checkValidCode(
      String currentUserId, String code, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("code", isEqualTo: code)
        .where("isQuiz", isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.reference.id);
        FirebaseFirestore.instance
            .collection("Quiz-codes")
            .doc(doc.reference.id)
            .update({"isOpen": true}).then((value) {
          if (querySnapshot.size == 1) {
            setState(() {
              _isLoading = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return OpenQuiz(
                      quizId: widget.quizId,
                      title: widget.title,
                      quizNumber: widget.index + 1,
                    );
                  },
                ),
              );
            });
          } else {
            setState(() {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text(
                          "Invalid code for this quiz,Double check and try again"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Close"))
                      ],
                    );
                  });
            });
          }
        });
      });
    });
  }

//request code
  Future<void> requestCode(String userToken, String currentUserId,
      String senderName, String title) async {
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName  naho nimero ya telefoni ni ${widget.phone} .\n  Namaze kwishyura amafaranga ${widget.quizPrice.isEmpty ? 1000 : widget.quizPrice} frw kuri nimero ${widget.adminPhone.isEmpty ? 0788659575 : widget.adminPhone} yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    //make sure that request is not already sent
    await FirebaseFirestore.instance
        .collection("Quiz-codes")
        .where("userId", isEqualTo: currentUserId)
        .where("isQuiz", isEqualTo: true)
        .get()
        .then((value) {
      if (value.size != 0) {
        setState(() {
          _isLoading = false;
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text(
                      "Your request have been already sent,Please wait the team is processing it."),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"))
                  ],
                );
              });
        });
      } else {
        Map<String, dynamic> checkCode = {
          "userId": currentUserId,
          "name": senderName,
          "email": widget.email,
          "phone": widget.phone,
          "photoUrl": widget.photoUrl,
          "quizId": widget.quizId,
          "quizTitle": title,
          "code": "",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "isOpen": false,
          "isQuiz": true,
        };
        FirebaseFirestore.instance
            .collection("Quiz-codes")
            .add(checkCode)
            .then((value) {
          //send push notification
          sendPushMessage(userToken, body, notificationTitle);
          setState(() {
            _isLoading = false;
            Size size = MediaQuery.of(context).size;
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                        "Ubusabe bwawe bwakiriwe neza, Kugirango ubone kode ikwinjiza muri exam banza wishyure."),
                    actions: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: size.width * 0.7,
                        height: size.height * 0.07,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor),
                            onPressed: () async {
                              //direct phone call
                              await FlutterPhoneDirectCaller.callNumber(
                                  "*182*8*1*329494*1500#");
                            },
                            child: const Text(
                              "Ishyura 1500 Rwf.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close"))
                    ],
                  );
                });
          });
        });
      }
    });
  }
}
