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
import '../../../widgets/apptext.dart';
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
      final checkUrl = API.notInIrembo;
      // Continue with user registration
      int dateF = DateTime.now().millisecondsSinceEpoch;

      IremboModel userModel = IremboModel(
        uid: currentuserid.toString(),
        createdAt: dateF.toString(),
        phone: phoneNumber.toString().trim(),
        name: name.trim().toString(),
        identity: id.trim().toString(),
        address: selectedRegion.trim().toString() +
            " " +
            selectedDistrict.trim().toString(),
        code: codeP.trim().toString(),
        category: selectedValue != "Provisoire"
            ? selectedCategory.trim().toString()
            : "",
        type: selectedValue.trim(),
      );

      //check if not already registed.

      try {
        final checkResponse = await http.post(Uri.parse(checkUrl),
            body: {'userId': currentuserid.toString()});

        if (checkResponse.statusCode == 200) {
          final resResult = jsonDecode(checkResponse.body);
          if (resResult['alreadyRegistered'] == true) {
            Fluttertoast.showToast(
                msg:
                    "Wamaze kwiyandikisha! Tegereza Tugukorere ibijyanye no kukwandika");
            Navigator.pop(context);
          } else {
            //if not register.
            try {
              final registrationResponse = await http.post(
                Uri.parse(iyandikisheUrl),
                body: userModel.toJson(),
              );

              if (registrationResponse.statusCode == 200) {
                final registrationResult =
                    jsonDecode(registrationResponse.body);

                if (registrationResult['registered'] == true) {
                  await FlutterPhoneDirectCaller.callNumber(
                      "*182*8*1*644209*1000#");
                  Fluttertoast.showToast(msg: AppText.requestSent);

                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                      textColor: Colors.red,
                      fontSize: 18,
                      msg: registrationResult['message'] ??
                          "Registration Failed");
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
    final int exam = 0;
    String body = AppText.requestCodeBody(senderName, phone);

    String notificationTitle = AppText.requestCodeTitle;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': currentuserid, 'ex_type': exam.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  AppText.requestCodeSuccessMessage,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppText.requestCodeSuccessCloseButtonText),
                  )
                ],
              );
            },
          );
        } else {
          try {
            final res = await http.post(
              Uri.parse(sabaCodeUrl),
              body: {
                'userId': currentuserid.toString(),
                'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
                "phone": phone.toString(),
                "name": currentusername,
                "ex_type": exam.toString()
              },
            );

            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              if (data['requestSent'] == true) {
                sendPushMessage(userToken, body, notificationTitle);
                isloading = false;

                Size size = MediaQuery.of(context).size;
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                        AppText.requestCodeSuccessAlertMessage,
                      ),
                      actions: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          width: size.width * 0.7,
                          height: size.height * 0.07,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                              ),
                              onPressed: () async {
                                await FlutterPhoneDirectCaller.callNumber(
                                    "*182*8*1*329494*1500#");
                              },
                              child: Text(
                                AppText.requestCodeSuccessButtonText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child:
                              Text(AppText.requestCodeSuccessCloseButtonText),
                        )
                      ],
                    );
                  },
                );
              } else {
                Fluttertoast.showToast(
                  msg: AppText.requestCodeErrorMessage,
                  textColor: Colors.red,
                  fontSize: 10,
                );
              }
            } else {
              Fluttertoast.showToast(
                msg: "Failed to connect to the API",
                textColor: Colors.red,
                fontSize: 10,
              );
            }
          } catch (e) {
            print("Error: $e");
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to connect to the API",
          textColor: Colors.red,
          fontSize: 10,
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text(
                    AppText.registerHeaderText,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppText.noticeTitle,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        AppText.noticeIssueContent,
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
                              child: Text(
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
                              child: Text(
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
                      labelText: AppText.selectLicenseType,
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
                      print(name);
                    },
                    validator: (nameValue) {
                      if (nameValue!.isEmpty) {
                        return AppText.nameFieldRequired;
                      }
                      if (nameValue.length < 3) {
                        return AppText.nameLengthError;
                      }
                      const String p = "^[a-zA-Z\\s]+";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(nameValue)) {
                        return null;
                      }

                      return AppText.invalidName;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: kPrimaryColor,
                      ),
                      hintText: AppText.nameHintText,
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
                      print(id);
                    },
                    validator: (id) {
                      if (id!.isEmpty) {
                        return AppText.idFieldRequired;
                      } else if (id.length != 16) {
                        return AppText.invalidIdLength;
                      }
                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.numbers,
                        color: kPrimaryColor,
                      ),
                      hintText: AppText.idHintText,
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
                            print(codeP);
                          },
                          validator: (codeP) {
                            if (codeP!.isEmpty) {
                              return AppText.codeFieldRequired;
                            }
                            return null;
                          },
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.code,
                              color: kPrimaryColor,
                            ),
                            hintText: AppText.provisionalCodeHint,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
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
                            labelText: AppText.selectCategory,
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
                      print(phoneNumber);
                    },
                    validator: (phoneValue) {
                      if (phoneValue!.isEmpty) {
                        return AppText.phoneFieldRequired;
                      }
                      if (phoneValue.length != 10) {
                        return AppText.invalidPhoneNumberLength;
                      }
                      const String p = "^07[2,389]\\d{7}";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(phoneValue)) {
                        return null;
                      }

                      return AppText.invalidPhoneNumber;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.phone,
                        color: kPrimaryColor,
                      ),
                      hintText: AppText.phoneNumberHintText,
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
                        if (selectedRegion == "Kigali") {
                          selectedDistrict = "Gasabo";
                        } else if (selectedRegion == "West") {
                          selectedDistrict = "Karongi";
                        } else if (selectedRegion == "South") {
                          selectedDistrict = "Gisagara";
                        } else if (selectedRegion == "North") {
                          selectedDistrict = "Burera";
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: AppText.selectRegion,
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
                    decoration: InputDecoration(
                      labelText: AppText.selectDistrict,
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.blue,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Text(
                    AppText.servicePaymentInstruction,
                    style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
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
                      child: Text(
                        AppText.payFee,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
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
                      child: Text(
                        AppText.requestExamsCode,
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
