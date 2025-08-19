import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rwanda_traffic_rules/widgets/fcmWidget.dart';
import 'package:rwanda_traffic_rules/enume/models/user_model.dart';
import 'package:rwanda_traffic_rules/backend/apis/db_connection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
// ignore_for_file: use_build_context_synchronously

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
    requestPermission();
    loadFCM();
    listenFCM();
    getToken();

    FirebaseMessaging.instance;

    loadRegionsMap().then((map) {
      setState(() {
        regionsMap = map;
      });
    });
  }

  Future<void> getToken() async {
    final url = API.getToken;
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final adminData = data['data'];
          userToken = adminData['fcmToken'];
          adminPhone = adminData['phone'];
        }
      } else {
        print("failed to connect to server");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  String selectedValue = "Provisoire";
  String selectedCategory = "A";
  String selectedRegion = "East";
  String selectedDistrict = "Bugesera";

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

      try {
        final checkResponse = await http.post(Uri.parse(checkUrl),
            body: {'userId': currentuserid.toString()});

        if (checkResponse.statusCode == 200) {
          final resResult = jsonDecode(checkResponse.body);
          if (resResult['alreadyRegistered'] == true) {
            Fluttertoast.showToast(
                msg: "You are already registered! Please wait for processing");
            Navigator.pop(context);
          } else {
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
                  Fluttertoast.showToast(
                      msg: "Your request has been received successfully");
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
            }
          }
        }
      } catch (e) {
        print("Error: $e");
      }
      setState(() {
        isloading = false;
      });
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
    String body =
        "Hello, my name is $senderName and my phone number is $phone. I have paid 1500 Rwf to 0788659575 for the exam. I need the access code. Thank you.";
    String notificationTitle = "Requesting Quiz Code";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userId': currentuserid, "ex_type": exam.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text(
                      "Your request has already been sent. Please wait while the team processes it."),
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
                "name": currentusername,
                "ex_type": exam.toString()
              },
            );

            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              if (data['requestSent'] == true) {
                sendPushMessage(userToken, body, notificationTitle);
                isloading = false;

                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text(
                            "Your request has been received. To get the exam access code, please pay first."),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor),
                            onPressed: () async {
                              await FlutterPhoneDirectCaller.callNumber(
                                  "*182*8*1*329494*1500#");
                            },
                            child: const Text(
                              "Pay 1500 Rwf",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
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
              }
            }
          } catch (e) {
            print("Error: $e");
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withValues(alpha: 0.1),
                      kPrimaryColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.app_registration_rounded,
                      size: 48,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Driver Registration",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Register for driving license services",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // License Type Field
              _buildDropdownField(
                value: selectedValue,
                label: "License Type",
                icon: Icons.drive_file_rename_outline_rounded,
                items: [
                  DropdownMenuItem(
                      value: "Provisoire", child: Text("Provisoire")),
                  DropdownMenuItem(value: "Permit", child: Text("Permit")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedValue = value.toString();
                  });
                },
              ),
              const SizedBox(height: 20),

              // Name Field
              _buildFormField(
                controller: nameEditingController,
                label: "Full Name",
                icon: Icons.person_outline_rounded,
                validator: (nameValue) {
                  if (nameValue!.isEmpty) {
                    return 'This field is mandatory';
                  }
                  if (nameValue.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  const String p = "^[a-zA-Z\\s]+";
                  RegExp regExp = RegExp(p);
                  if (regExp.hasMatch(nameValue)) {
                    return null;
                  }
                  return 'This is not a valid name';
                },
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 20),

              // ID Field
              _buildFormField(
                controller: idEditingController,
                label: "National ID",
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                validator: (id) {
                  if (id!.isEmpty) {
                    return 'This field is mandatory';
                  } else if (id.length != 16) {
                    return 'ID must be exactly 16 digits';
                  }
                  return null;
                },
                onChanged: (val) => id = val,
              ),
              const SizedBox(height: 20),

              // Phone Field
              _buildFormField(
                controller: phoneNumberEditingController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (phoneValue) {
                  if (phoneValue!.isEmpty) {
                    return 'This field is mandatory';
                  }
                  if (phoneValue.length != 10) {
                    return 'Phone must be exactly 10 digits';
                  }
                  const String p = "^07[2,389]\\d{7}";
                  RegExp regExp = RegExp(p);
                  if (regExp.hasMatch(phoneValue)) {
                    return null;
                  }
                  return 'This is not a valid phone number';
                },
                onChanged: (val) => phoneNumber = val,
              ),
              const SizedBox(height: 20),

              // Region Field
              _buildDropdownField(
                value: selectedRegion,
                label: "Region",
                icon: Icons.location_on_outlined,
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
              ),
              const SizedBox(height: 20),

              // District Field
              _buildDropdownField(
                value: selectedDistrict,
                label: "District",
                icon: Icons.location_city_outlined,
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
              ),
              const SizedBox(height: 24),

              // Payment Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.1),
                      Colors.blue.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payment_rounded,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Service Payment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Click below to pay the service fee (1000 Rwf)",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isloading
                            ? null
                            : () {
                                _registerUser();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: isloading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Pay 1000 Rwf",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Request Code Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.vpn_key_rounded,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Request Exam Code",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Request access code for driving exam",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          requestCode(userToken, currentuserid.toString(),
                              currentusername, "Exams");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Request Exam Code",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: kPrimaryColor,
                size: 20,
              ),
              hintText: "Enter $label",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: kPrimaryColor,
                size: 20,
              ),
              hintText: "Select $label",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
