import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/apis/db_connection.dart';
import '../../resources/user_state_methods.dart';
import '../../utils/constants.dart';
import '../../widgets/MainDrawer.dart';
import '../../widgets/ProgressWidget.dart';
import 'package:http/http.dart' as http;

class UserSettings extends StatelessWidget {
  UserSettings({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(
        elevation: 0,
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: const Text(
          "Account Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.25,
            fontSize: 24,
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
            onTap: () => {
              UserStateMethods().logoutuser(context),
            },
            child: const Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Icon(
                Icons.logout_outlined,
                size: 25,
              ),
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
      body: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences preferences;
  late TextEditingController nameTextEditingController;
  late TextEditingController phoneTextEditingController;
  late TextEditingController passwordTextEditingController;

  String id = "";
  String name = "";
  String password = "";
  String phone = "";
  bool isLoading = false;
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  bool _status = true;
  bool isInitialLoading = false;
  final FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    readDataFromLocal();
  }

  void readDataFromLocal() async {
    isInitialLoading = true;
    preferences = await SharedPreferences.getInstance();

    setState(() {
      id = preferences.getString("uid")!;
      name = preferences.getString("name")!;
      phone = preferences.getString("phone")!;
    });

    nameTextEditingController = TextEditingController(text: name);
    phoneTextEditingController = TextEditingController(text: phone);
    passwordTextEditingController = TextEditingController();

    isInitialLoading = false;
  }

  void updateData() async {
    nameFocusNode.unfocus();
    phoneFocusNode.unfocus();
    passwordFocusNode.unfocus();
    setState(() {
      isLoading = true;
    });

    if (password != "") {
      final String updateUrl = API.updateProfile;

      // Create a map with the updated user data
      Map<String, dynamic> updatedUserData = {
        "uid": id,
        "name": name,
        "phone": phone,
        "password": password,
      };

      try {
        final response = await http.post(
          Uri.parse(updateUrl),
          body: updatedUserData,
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data['updated'] == true) {
            await preferences.setString("name", name);
            await preferences.setString("phone", phone);

            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Updated Successfully.");
          } else {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: data['message'] ?? "Failed to update user data");
          }
        } else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Failed to connect to the server");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Update Error: $e");
        Fluttertoast.showToast(msg: "Failed to update user profile data");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Password is required.");
    }
  }

  // void updateData() {
  //   nameFocusNode.unfocus();
  //   phoneFocusNode.unfocus();
  //   passwordFocusNode.unfocus();
  //   setState(() {
  //     isLoading = false;
  //   });

  //   if (password != "") {
  //     FirebaseFirestore.instance
  //         .collection("Users")
  //         .doc(id)
  //         .update({"name": name, "phone": phone, "password": password}).then(
  //             (data) async {
  //       await preferences.setString("photo", photoUrl);
  //       await preferences.setString("name", name);
  //       await preferences.setString("phone", phone);

  //       setState(() {
  //         isLoading = false;
  //       });
  //       Fluttertoast.showToast(msg: "Updated Successfully.");
  //     });
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Fluttertoast.showToast(msg: "key is required please");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return isInitialLoading
        ? oldcircularprogress()
        : Stack(
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Material(
                                    // display new updated image
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(125.0)),
                                    clipBehavior: Clip.hardEdge,
                                    // display new updated image
                                    child: Image.asset(
                                      "assets/profile.png",
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    )),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Padding(
                                  padding:
                                      EdgeInsets.only(top: 150.0, right: 120.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 25.0,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: isLoading ? oldcircularprogress() : Container(),
                      ),
                    ]),
                    Container(
                      color: const Color(0xFFFFFFFF),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Personal Information',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        _status ? _getEditIcon() : Container(),
                                      ],
                                    )
                                  ],
                                )),
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Name',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextField(
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          hintText: "Enter Your Name",
                                        ),
                                        controller: nameTextEditingController,
                                        enabled: !_status,
                                        autofocus: !_status,
                                        onChanged: (value) {
                                          name = value;
                                        },
                                        focusNode: nameFocusNode,
                                      ),
                                    ),
                                  ],
                                )),
                            //Telephone
                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Telephone',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextField(
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                            hintText: "Enter Phone number"),
                                        enabled: !_status,
                                        controller: phoneTextEditingController,
                                        focusNode: phoneFocusNode,
                                        onChanged: (value) {
                                          phone = value;
                                        },
                                      ),
                                    ),
                                  ],
                                )),

                            const Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'password',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "Enter Password",
                                        ),
                                        controller:
                                            passwordTextEditingController,
                                        enabled: !_status,
                                        autofocus: !_status,
                                        onChanged: (value) {
                                          password = value;
                                        },
                                        focusNode: passwordFocusNode,
                                      ),
                                    ),
                                  ],
                                )),

                            !_status ? _getActionButtons() : Container(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                  updateData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text("Update"),
                // style: new RoundedRectangleBorder(
                //     borderRadius: new BorderRadius.circular(20.0)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text("Cancel"),
                // shape: new RoundedRectangleBorder(
                //     borderRadius: new BorderRadius.circular(20.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: const CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}
