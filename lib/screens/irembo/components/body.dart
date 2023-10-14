// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String name = "", phoneNumber = "", id = "", address = "";
  late SharedPreferences preferences;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    getCurrUserId();
  }

  String? currentuserid;

  getCurrUserId() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      // ignore: avoid_print
      print("current user id");
      // ignore: avoid_print
      print(currentuserid);
    });
  }

  void _registerUser() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      preferences = await SharedPreferences.getInstance();
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection("irembo-users")
          .where("uid", isEqualTo: currentuserid.toString())
          .get();

      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        FirebaseFirestore.instance
            .collection("irembo-users")
            .doc(currentuserid.toString())
            .set({
          "uid": currentuserid.toString(),
          "name": name.toString().trim(),
          "phone": phoneNumber.trim(),
          "identity": id.trim(),
          "address": address.trim(),
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
        });
        await FlutterPhoneDirectCaller.callNumber("*182*8*1*644209*1000#");
        Fluttertoast.showToast(msg: "Ubusabe bwawe bwakiriwe neza");

        Navigator.pop(context);
      } else {
        setState(() {
          isloading = false;
        });
        Fluttertoast.showToast(msg: "Usanzwe wariyandikishije");

        Navigator.pop(context);
      }
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
                        "Niba ufite ikibazo kijyanye no gukorera uruhurwa rw'agateganyo(provoire) cg rwa burundi(permin) kandi ukaba ukeneye ubufasha mukwiyandikisha  wahamagara kuri izi nimero zikurikira:",
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
                      }
                      else if (id.length !=16) {
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
                      if (phoneValue.length !=10) {
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
                  child: TextFormField(
                    controller: addressEditingController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      address = val;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      hintText: "AKARERE UZAKORERAMO",
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: kPrimaryColor,
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
