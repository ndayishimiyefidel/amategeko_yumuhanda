import 'dart:convert';
import 'package:rwanda_traffic_rules/screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/MainDrawer.dart';
import '../../widgets/ModernAppBar.dart';
import 'package:http/http.dart' as http;
import '../../widgets/ProgressWidget.dart';
import '../../backend/apis/db_connection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../resources/user_state_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

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
      appBar: ModernAppBar(
        title: 'Account Information',
        subtitle: 'Settings',
        onMenuPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
        actions: [
          InkWell(
            onTap: () => {
              UserStateMethods().logoutuser(context),
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Icon(
                Icons.logout_outlined,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
  bool isAlreadyLoggedIn = false;
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
    isAlreadyLoggedIn = preferences.getBool("isLoggedIn") ?? false;

    if (preferences.getString("uid") != null && isAlreadyLoggedIn) {
      setState(() {
        id = preferences.getString("uid") ?? "";
        name = preferences.getString("name") ?? "";
        phone = preferences.getString("phone") ?? "";
      });
    } else {
      setState(() {
        isInitialLoading = false;
      });
      Fluttertoast.showToast(msg: "User not found");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }

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
            Fluttertoast.showToast(msg: "Profile updated successfully!");
          } else {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: data['message'] ?? "Failed to update profile");
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
        Fluttertoast.showToast(msg: "Failed to update profile");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Password is required");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isInitialLoading
        ? oldcircularprogress()
        : Stack(
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    // Modern Profile Header
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(24),
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         kPrimaryColor.withValues(alpha: 0.1),
                    //         kPrimaryColor.withValues(alpha: 0.05),
                    //       ],
                    //       begin: Alignment.topLeft,
                    //       end: Alignment.bottomRight,
                    //     ),
                    //     borderRadius: BorderRadius.circular(24),
                    //     border: Border.all(
                    //       color: kPrimaryColor.withValues(alpha: 0.2),
                    //       width: 1,
                    //     ),
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       // Profile Avatar
                    //       Container(
                    //         padding: const EdgeInsets.all(4),
                    //         decoration: BoxDecoration(
                    //           color: kPrimaryColor.withValues(alpha: 0.1),
                    //           shape: BoxShape.circle,
                    //         ),
                    //         child: CircleAvatar(
                    //           radius: 50,
                    //           backgroundColor: kPrimaryColor.withValues(alpha: 0.15),
                    //           child: Icon(
                    //             Icons.person,
                    //             size: 60,
                    //             color: kPrimaryColor,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 16),
                    //       Text(
                    //         name,
                    //         style: TextStyle(
                    //           fontSize: 24,
                    //           fontWeight: FontWeight.bold,
                    //           color: kPrimaryColor,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       Text(
                    //         "Account Settings",
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           color: Colors.grey[600],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 24),

                    // Loading Indicator
                    if (isLoading)
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: oldcircularprogress(),
                      ),

                    // Personal Information Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: kPrimaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Name Field
                            _buildFormField(
                              label: 'Full Name',
                              controller: nameTextEditingController,
                              focusNode: nameFocusNode,
                              icon: Icons.person,
                              enabled: !_status,
                              onChanged: (value) => name = value,
                            ),
                            const SizedBox(height: 20),

                            // Phone Field
                            _buildFormField(
                              label: 'Phone Number',
                              controller: phoneTextEditingController,
                              focusNode: phoneFocusNode,
                              icon: Icons.phone,
                              enabled: !_status,
                              onChanged: (value) => phone = value,
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            _buildFormField(
                              label: 'Password',
                              controller: passwordTextEditingController,
                              focusNode: passwordFocusNode,
                              icon: Icons.lock,
                              enabled: !_status,
                              isPassword: true,
                              onChanged: (value) => password = value,
                            ),

                            const SizedBox(height: 24),

                            // Action Buttons
                            if (!_status) _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 100), // Bottom padding for navigation
                  ],
                ),
              )
            ],
          );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required bool enabled,
    bool isPassword = false,
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
            color: enabled ? Colors.white : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? kPrimaryColor.withValues(alpha: 0.3)
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: isPassword,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 16,
              color: enabled ? Colors.black87 : Colors.grey[600],
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: enabled ? kPrimaryColor : Colors.grey[400],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: enabled ? "Enter your $label" : "Password",
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _status = true;
                FocusScope.of(context).requestFocus(FocusNode());
              });
              updateData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _status = true;
                FocusScope.of(context).requestFocus(FocusNode());
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }
}
