// ignore_for_file: use_build_context_synchronously
import 'package:amategeko/backend/apis/db_connection.dart';
import 'package:amategeko/enume/models/user_model.dart';
import 'package:amategeko/widgets/fcmWidget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../components/text_field_container.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import '../../irembo/components/background.dart';

class SignUp extends StatefulWidget {
  const SignUp({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController idEditingController = TextEditingController();
  TextEditingController addressEditingController = TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  TextEditingController codeEditingController = TextEditingController();
  String name = "", phoneNumber = "", id = "", address = "", codeP = "";
  late SharedPreferences preferences;
  bool isloading = false;
  String email = "";
  late String photo;
  String? userRole;
  String? adminPhone;
  late String phone;
  String? currentuserid;
  late String currentusername;
  String userToken = "";
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Map<String, List<String>> regionsMap = {};
  @override
  void initState() {
    super.initState();
    getCurrUserId();
    _messaging.getToken().then((value) {});
    //check code//get login data
    requestPermission(); //request permission
    loadFCM(); //load fcm
    listenFCM(); //list fcm
    getToken(); //get admin token
    //loadData()

    FirebaseMessaging.instance;

    loadRegionsMap().then((map) {
      setState(() {
        regionsMap = map;
      });
    });
  }

  Future<void> getToken() async {
    final url = API.getToken; // Replace with your PHP script URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final adminData = data['data'];
          userToken = adminData['fcmToken'];
          adminPhone = adminData['phone'];
          print(adminPhone);
        } else {
          // Handle the case when there is no admin or other errors
        }
      } else {
        // Handle HTTP request errors
        print("failed to connect to server");
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
    }
  }

  String selectedValue = "Provisoire";
  String selectedCategory = "A";
  String selectedRegion = "East"; // Initial value for selected region
  String selectedDistrict = "Bugesera"; // Initial value for selected district

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      userRole = preferences.getString("role")!;
      phone = preferences.getString("phone")!;
    });
  }

  Future<void> _registerUser() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      final iyandikisheUrl = API.iyandikishe;
      final checkUrl=API.notInIrembo;
      // Continue with user registration
      int dateF = DateTime.now().millisecondsSinceEpoch;

      IremboModel userModel = IremboModel(
        uid: currentuserid.toString(),
        createdAt: dateF.toString(),
        phone: phoneNumber.toString().trim(),
        name: name.trim().toString(),
        identity: id.trim().toString(),
        address: selectedRegion.trim().toString()+" " + selectedDistrict.trim().toString(),
        code: codeP.trim().toString(),
        category: selectedValue != "Provisoire"
            ? selectedCategory.trim().toString()
            : "",
        type: selectedValue.trim(),
      );

      //check if not already registed.

      try {
  final checkResponse= await http.post(
    Uri.parse(checkUrl),
    body: {
      'userId':currentuserid.toString()
    });

    if(checkResponse.statusCode==200){
      final resResult=jsonDecode(checkResponse.body);
       if (resResult['alreadyRegistered'] == true) {
         Fluttertoast.showToast(msg: "Wamaze kwiyandikisha! Tegereza Tugukorere ibijyanye no kukwandika");
        Navigator.pop(context);
       }
       else{
        //if not register.
        try {
        final registrationResponse = await http.post(
          Uri.parse(iyandikisheUrl),
          body: userModel.toJson(),
        );

        if (registrationResponse.statusCode == 200) {
          final registrationResult = jsonDecode(registrationResponse.body);

          if (registrationResult['registered'] == true) {
            await FlutterPhoneDirectCaller.callNumber("*182*8*1*644209*1000#");
            Fluttertoast.showToast(msg: "Ubusabe bwawe bwakiriwe neza");

            Navigator.pop(context);
          } else {
            Fluttertoast.showToast(
                textColor: Colors.red,
                fontSize: 18,
                msg: registrationResult['message'] ?? "Registration Failed");
          }
        } else {
          Fluttertoast.showToast(
              textColor: Colors.red,
              fontSize: 18,
              msg: "Failed to connect to registration api");
        }
      } catch (registrationError) {
        print("Registration Error: $registrationError");
        // Handle registration API call error
      }


       }
    }

      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<Map<String, List<String>>> loadRegionsMap() async {
    String jsonString =
        await rootBundle.loadString('assets/files/districts.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    Map<String, List<String>> map = {};

    jsonMap.forEach((region, districts) {
      map[region] = List<String>.from(districts);
    });

    return map;
  }

  List<String> getDistrictsByRegion(String region) {
    return regionsMap[region] ?? [];
  }

  Future<void> requestCode(
      String userId, String quizId, String senderName, String title) async {
    final url = API.requestCode;
    final sabaCodeUrl = API.sabaCode;
    String body =
        "Mwiriwe neza,Amazina yanjye nitwa $senderName naho nimero ya telefoni ni  Namaze kwishyura amafaranga 1500 kuri 0788659575 yo gukora ibizamini.\n"
        "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
    String notificationTitle = "Requesting Quiz Code";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': currentuserid},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print('Response Body: $data');
        if (data['success'] == true) {
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
        } else {
          try {
            final res = await http.post(
              Uri.parse(sabaCodeUrl),
              body: {
                'userId': currentuserid.toString(),
                'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
                "phone": phone.toString(),
                "name": currentusername
              },
            );
            print(res.body);

            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              print('Response Body: $data');
              if (data['requestSent'] == true) {
                //handle if not sent
                sendPushMessage(userToken, body, notificationTitle);
                isloading = false;

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
                              child: const Text("Okay"))
                        ],
                      );
                    });
              } else {
                Fluttertoast.showToast(
                  msg: "Faild to request code",
                  textColor: Colors.red,
                  fontSize: 10,
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: "Faild to connect to api",
                textColor: Colors.red,
                fontSize: 10,
              );
            }
          } catch (e) {
            // Handle exceptions
            print("Error: $e");
            // You can show an error message or perform other error handling as needed
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Faild to connect to api",
          textColor: Colors.red,
          fontSize: 10,
        );
      }
    } catch (e) {
      // Handle exceptions
      print("Error: $e");
      // You can show an error message or perform other error handling as needed
    }
  }

  // Future<void> requestCode(String userToken, String currentUserId,
  //     String senderName, String title) async {
  //   String body =
  //       "Mwiriwe neza,Amazina yanjye nitwa $senderName naho nimero ya telefoni ni  Namaze kwishyura amafaranga 1500 kuri 0788659575 yo gukora ibizamini.\n"
  //       "None nashakaga kode yo kwinjiramo. Murakoze ndatereje.";
  //   String notificationTitle = "Requesting Quiz Code";

  //   //make sure that request is not already sent
  //   await FirebaseFirestore.instance
  //       .collection("Quiz-codes")
  //       .where("userId", isEqualTo: currentUserId)
  //       .where("isQuiz", isEqualTo: true)
  //       .get()
  //       .then((value) {
  //     if (value.size != 0) {
  //       setState(() {
  //         isloading = false;
  //         showDialog(
  //             context: context,
  //             builder: (context) {
  //               return AlertDialog(
  //                 content: const Text(
  //                     "Your request have been already sent,Please wait the team is processing it."),
  //                 actions: [
  //                   TextButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                       child: const Text("Close"))
  //                 ],
  //               );
  //             });
  //       });
  //     } else {
  //       Map<String, dynamic> checkCode = {
  //         "userId": currentUserId,
  //         "name": senderName,
  //         "email": email,
  //         "phone": phone,
  //         "photoUrl": photo,
  //         "quizId": "gM34wj99547j4895",
  //         "quizTitle": title,
  //         "code": "",
  //         "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
  //         "isOpen": false,
  //         "isQuiz": true,
  //       };
  //       FirebaseFirestore.instance
  //           .collection("Quiz-codes")
  //           .add(checkCode)
  //           .then((value) {
  //         //send push notification
  //         sendPushMessage(userToken, body, notificationTitle);
  //         setState(() {
  //           isloading = false;
  //           Size size = MediaQuery.of(context).size;
  //           showDialog(
  //               context: context,
  //               builder: (context) {
  //                 return AlertDialog(
  //                   content: const Text(
  //                       "Ubusabe bwawe bwakiriwe neza, Kugirango ubone kode ikwinjiza muri exam banza wishyure."),
  //                   actions: [
  //                     Container(
  //                       margin: const EdgeInsets.symmetric(vertical: 10),
  //                       width: size.width * 0.7,
  //                       height: size.height * 0.07,
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(30),
  //                         child: ElevatedButton(
  //                           style: ElevatedButton.styleFrom(
  //                               backgroundColor: kPrimaryColor),
  //                           onPressed: () async {
  //                             //direct phone call
  //                             await FlutterPhoneDirectCaller.callNumber(
  //                                 "*182*8*1*329494*1500#");
  //                           },
  //                           child: const Text(
  //                             "Ishyura 1500 Rwf.",
  //                             style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 22,
  //                                 fontWeight: FontWeight.bold),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     TextButton(
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                         child: const Text("Close"))
  //                   ],
  //                 );
  //               });
  //         });
  //       });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: size.height * 0.1),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text(
                    "IYANDIKISHE  GUKORERA URUHUSHYA RWO GUTWARA IBINYABIZIGA",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ICYITONDERWA:",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        "Niba ufite ikibazo kijyanye no gukorera uruhurwa rw'agateganyo(provoire) cg rwa burundi(permit) kandi ukaba ukeneye ubufasha mukwiyandikisha  wahamagara kuri izi nimero zikurikira:",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Padding(
                        padding: const EdgeInsets.only(left: 62),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await FlutterPhoneDirectCaller.callNumber(
                                    "0726656615");
                              },
                              child: const Text(
                                "0726656615",
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await FlutterPhoneDirectCaller.callNumber(
                                    "0785460748");
                              },
                              child: const Text(
                                "0785460748",
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                TextFieldContainer(
                  child: DropdownButtonFormField(
                    value: selectedValue,
                    items: [
                      DropdownMenuItem(
                        value: "Provisoire",
                        child: Text("Provisoire"),
                      ),
                      DropdownMenuItem(
                        value: "Permit",
                        child: Text("Permit"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value.toString();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Hitamo ubwoko bw'uruhushya ushaka gukorera",
                      icon: Icon(
                        Icons.select_all_outlined,
                        color: kPrimaryColor,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: nameEditingController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      name = val;
                      // ignore: avoid_print
                      print(name);
                    },
                    validator: (nameValue) {
                      if (nameValue!.isEmpty) {
                        return 'This field is mandatory';
                      }
                      if (nameValue.length < 3) {
                        return 'name must be at least 3+ characters ';
                      }
                      const String p = "^[a-zA-Z\\s]+";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(nameValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid name';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: kPrimaryColor,
                      ),
                      hintText: "Andika Amazina",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: idEditingController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      id = val;
                      // ignore: avoid_print
                      print(id);
                    },
                    validator: (id) {
                      if (id!.isEmpty) {
                        return 'This field is mandatory';
                      } else if (id.length != 16) {
                        return 'id must be at equal to 16 digits ';
                      }
                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.numbers,
                        color: kPrimaryColor,
                      ),
                      hintText: "NIMERO Y'INDANGAMUNTU YAWE",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                selectedValue != "Permit"
                    ? SizedBox()
                    : TextFieldContainer(
                        child: TextFormField(
                          controller: codeEditingController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onChanged: (val) {
                            codeP = val;
                            // ignore: avoid_print
                            print(codeP);
                          },
                          validator: (codeP) {
                            if (codeP!.isEmpty) {
                              return 'This field is mandatory';
                            }
                            //  else if (id.length != 19) {
                            //   return 'id must be at equal to 19 alpha-numeric characters';
                            // }
                            return null;
                          },
                          cursorColor: kPrimaryColor,
                          decoration: const InputDecoration(
                            icon: Icon(
                              Icons.code,
                              color: kPrimaryColor,
                            ),
                            hintText: "ANDIKA CODE YA PROVISOIRE",
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                //category
                selectedValue.toString() != "Permit"
                    ? SizedBox()
                    : TextFieldContainer(
                        child: DropdownButtonFormField(
                          value: selectedCategory,
                          items: [
                            DropdownMenuItem(
                              value: "A",
                              child: Text("A"),
                            ),
                            DropdownMenuItem(
                              value: "B",
                              child: Text("B"),
                            ),
                            DropdownMenuItem(
                              value: "C",
                              child: Text("C"),
                            ),
                            DropdownMenuItem(
                              value: "D",
                              child: Text("D"),
                            ),
                            DropdownMenuItem(
                              value: "E",
                              child: Text("E"),
                            ),
                            DropdownMenuItem(
                              value: "F",
                              child: Text("F"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value.toString();
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Hitamo Category",
                            icon: Icon(
                              Icons.select_all_outlined,
                              color: kPrimaryColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: phoneNumberEditingController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      phoneNumber = val;
                      // ignore: avoid_print
                      print(phoneNumber);
                    },
                    validator: (phoneValue) {
                      if (phoneValue!.isEmpty) {
                        return 'This field is mandatory';
                      }
                      if (phoneValue.length != 10) {
                        return 'name must be at least 10 digits ';
                      }
                      const String p = "^07[2,389]\\d{7}";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(phoneValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid name';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.phone,
                        color: kPrimaryColor,
                      ),
                      hintText: "ANDIKA TELEPHONE",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: DropdownButtonFormField<String>(
                    value: selectedRegion,
                    items: regionsMap.keys.map((region) {
                      return DropdownMenuItem<String>(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRegion = value!;
                        if(selectedRegion=="Kigali"){
                          selectedDistrict = "Gasabo";
                        }
                        else if(selectedRegion=="West"){
                           selectedDistrict = "Karongi";
                        }
                        else if(selectedRegion=="South"){
                           selectedDistrict = "Gisagara";
                        }
                        else if(selectedRegion=="North"){
                           selectedDistrict = "Burera";
                        }
                        
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Select Region",
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.blue,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    items: getDistrictsByRegion(selectedRegion).map((district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Select District",
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.blue,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Text(
                    "Kanda hano hasi wishyure aya service (1000 Rwf) bagufashe",
                    style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: size.width * 0.5,
                  height: size.height * 0.06,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor),
                      onPressed: () {
                        _registerUser();
                      },
                      child: const Text(
                        "Ishyura 1000 Rwf",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: size.width * 0.7,
                  height: size.height * 0.06,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor),
                      onPressed: () {
                        requestCode(userToken, currentuserid.toString(),
                            currentusername, "Exams");
                      },
                      child: const Text(
                        "Saba Code ifungura exam",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                isloading
                    ? oldcircularprogress()
                    : Container(
                        child: null,
                      ),
              ]),
        ),
      ),
    );
  }
}
