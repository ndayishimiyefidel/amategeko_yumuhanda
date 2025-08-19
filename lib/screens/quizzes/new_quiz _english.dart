import 'dart:async';
import 'dart:convert';
import 'open_quiz.dart';
import '../../utils/constants.dart';
import '../../widgets/fcmWidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../backend/apis/db_connection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class NewQuizEnglish extends StatefulWidget {
  const NewQuizEnglish({Key? key}) : super(key: key);

  @override
  State<NewQuizEnglish> createState() => _NewQuizEnglishState();
}

class _NewQuizEnglishState extends State<NewQuizEnglish> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  late SharedPreferences preferences;
  late String currentUserId, currentUsername, userToken, phone;
  String? userRole, adminPhone;
  bool hasCode = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await getCurrUserData();
    requestPermission();
    loadFCM();
    listenFCM();
    getAdminToken();
  }

  Future<void> getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    currentUserId = preferences.getString("uid") ?? "";
    currentUsername = preferences.getString("name") ?? "";
    userRole = preferences.getString("role");
    phone = preferences.getString("phone") ?? "";
    userToken = preferences.getString("fcmToken") ?? "";

    if (currentUserId.isEmpty ||
        currentUsername.isEmpty ||
        phone.isEmpty ||
        userToken.isEmpty) {
      print("Error: Required user data is missing.");
      return;
    }

    print(currentUserId);
    if (kDebugMode) {
      print(userRole);
    }
    checkQuizCode();
  }

  Future<void> checkQuizCode() async {
    try {
      const url = API.checkCode;
      final response = await http.post(
        Uri.parse(url),
        body: {
          'userId': currentUserId,
          'ex_type': '1',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (!mounted) return;
          setState(() {
            hasCode = data['hasCode'] == true;
          });
        }
      } else {
        print(
            "Error: Failed to check quiz code - Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error checking quiz code: $e");
      // Don't show error to user for this background check
    }
  }

  Future<void> getAdminToken() async {
    try {
      const url = API.getToken;
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          userToken = data['data']['fcmToken'];
          adminPhone = data['data']['phone'];
          print(adminPhone);
        }
      } else {
        print(
            "Error: Failed to get admin token - Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error getting admin token: $e");
      // Don't show error to user for this background check
    }
  }

  Widget quizList() {
    return FutureBuilder(
      future:
          DefaultAssetBundle.of(context).loadString('assets/files/endata.json'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  "Loading exams...",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading exams',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No exams available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        } else {
          final exams = json.decode(snapshot.data as String)['exams'];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return ModernQuizCard(
                index: index,
                quizId: exam['quizId'],
                imgurl: exam['examImgUrl'],
                title: exam['title'],
                quizType: exam['examType'],
                totalQuestion: 20,
                userRole: userRole.toString(),
                userToken: userToken,
                senderName: currentUsername,
                currentUserId: currentUserId,
                phone: phone,
                adminPhone: adminPhone.toString(),
                questions: List<Map<String, dynamic>>.from(exam['questions']),
              );
            },
          );
        }
      },
    );
  }

  Future<void> requestCode() async {
    if (await Connectivity().checkConnectivity() == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg:
            "No internet connection. Please try again when you have a stable connection.",
        textColor: Colors.red,
        fontSize: 18,
      );
      return;
    }
    const url = API.requestCode;
    final response = await http.post(
      Uri.parse(url),
      body: {
        'userId': currentUserId,
        'phone': phone,
        'ex_type': "1",
      },
    );
    print("Response:  ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        showMessage(
            "Your request has already been sent. Please wait for processing.");
      } else {
        sendCodeRequest();
      }
    } else {
      showError("Failed to connect to API");
    }
  }

  static const int exam = 1;
  static const int quizId = 0;

  Future<void> sendCodeRequest() async {
    const sabaCodeUrl = API.sabaCode;
    final response = await http.post(
      Uri.parse(sabaCodeUrl),
      body: {
        'userId': currentUserId,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'phone': phone,
        'name': currentUsername,
        'quizId': quizId.toString(),
        'ex_type': exam.toString(),
      },
    );
    print("Response data:$response");
    print("Response Status Code:${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['requestSent'] == true) {
        sendPushMessage(
            userToken, _buildRequestMessage(), "Requesting Quiz Code");
        showMessage(
            "Your request has been received. Please complete the payment to proceed.");
      } else {
        showError("Failed to request code");
      }
    } else {
      showError("Failed to connect to API");
    }
  }

  String _buildRequestMessage() {
    return "Hello, my name is $currentUsername and my phone number is $phone. I have paid 5000 Rwf to 0788659575 for the exam. I need the access code. Thank you.";
  }

  void showRequestCodeInstruction() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    // Container(
                    //   padding: const EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: kPrimaryColor.withValues(alpha: 0.1),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: Icon(
                    //     Icons.vpn_key_rounded,
                    //     color: kPrimaryColor,
                    //     size: 48,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    Text(
                      "Request Access Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Follow these steps to get your exam access code",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Instructions
                    _buildInstructionStep(
                      1,
                      "Pay 5000 Rwf to 0788659575/0728877442 or use the green button below",
                      Colors.blue,
                    ),
                    _buildInstructionStep(
                      2,
                      "Click 'Request Code' button after payment",
                      Colors.red,
                    ),
                    _buildInstructionStep(
                      3,
                      "Wait 2-5 minutes, then return and click 'Start Exam'",
                      Colors.green,
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          requestCode();
                        },
                        child: const Text(
                          "Request Code",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          await FlutterPhoneDirectCaller.callNumber(
                              "*182*8*1*329494*5000#");
                        },
                        child: const Text(
                          "Pay 5000 Rwf (6 Months)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Contact Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                color: kPrimaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Need help? Call us:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: [
                              _buildPhoneNumber('0788659575'),
                              const SizedBox(height: 8),
                              _buildPhoneNumber('0728877442'),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildInstructionStep(int step, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumber(String number) {
    return GestureDetector(
      onTap: () async {
        await FlutterPhoneDirectCaller.callNumber(number);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          number,
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      textColor: Colors.red,
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPrimaryColor.withValues(alpha: 0.05),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryColor.withValues(alpha: 0.1),
                    kPrimaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "English Practice Exams",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "To start the learning process, if you have not paid, click the 'Request Access Code' button below otherwise click start exam! \n Happy Learning!",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Quiz List
            Expanded(
              child: quizList(),
            ),
          ],
        ),
      ),
      floatingActionButton: (userRole != "Admin" && !hasCode)
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                label: const Text(
                  "Request Access Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: const Icon(Icons.vpn_key_rounded),
                onPressed: showRequestCodeInstruction,
              ),
            )
          : null,
    );
  }
}

class ModernQuizCard extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String imgurl;
  final String title;
  final String quizId;
  final String quizType;
  final int totalQuestion;
  final String userRole;
  final String userToken;
  final String adminPhone;
  final String senderName;
  final String phone;
  final String currentUserId;
  final int index;

  ModernQuizCard({
    Key? key,
    required this.imgurl,
    required this.title,
    required this.quizId,
    required this.quizType,
    required this.totalQuestion,
    required this.userToken,
    required this.senderName,
    required this.phone,
    required this.currentUserId,
    required this.userRole,
    required this.adminPhone,
    required this.index,
    required this.questions,
  }) : super(key: key);

  @override
  State<ModernQuizCard> createState() => _ModernQuizCardState();
}

class _ModernQuizCardState extends State<ModernQuizCard> {
  bool _isLoading = false;
  bool isAlreadyOpened = false;
  late String endTime;
  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    initializePreferences();
  }

  Future<void> initializePreferences() async {
    preferences = await SharedPreferences.getInstance();
    checkRequestStatus();
  }

  void checkRequestStatus() {
    setState(() {
      isAlreadyOpened = preferences.getBool("isOpened") ?? false;
    });
  }

  void startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> handleButtonClick() async {
    startLoading();
    print("exam type:${widget.quizType}");
    print("myuser role:${widget.userRole}");
    try {
      if (widget.quizType == "Free" || widget.userRole == "Admin") {
        navigateToQuiz();
      } else {
        endTime = preferences.getString("endTime") ?? "0";

        if (isAlreadyOpened) {
          print("isAlreadyOpened is : " + isAlreadyOpened.toString());

          try {
            int endTimeMillis = int.tryParse(endTime) ?? 0;
            print("endTime is : " + endTimeMillis.toString());
            if (endTimeMillis >= DateTime.now().millisecondsSinceEpoch) {
              navigateToQuiz();
            } else {
              if (!mounted) return;
              setState(() async {
                await preferences.setBool("isOpened", false);
                showErrorDialog(
                    "Your study period has expired. Please pay again to continue studying.");
              });
            }
          } catch (e) {
            print("Error parsing endTime: $e");
            showErrorDialog(
                "There was an error processing the end time. Please try again.");
          }
        } else {
          var connectivityResult = await Connectivity().checkConnectivity();
          if (connectivityResult == ConnectivityResult.none) {
            Fluttertoast.showToast(
                textColor: Colors.red,
                fontSize: 18,
                msg:
                    "No internet connection. Please try again when you have a stable connection.");
          } else {
            await checkQuizStatus();
          }
        }
      }
    } finally {
      stopLoading();
    }
  }

  Future<void> checkQuizStatus() async {
    const isOpenUrl = API.isQuizOpen;
    final response = await http.post(
      Uri.parse(isOpenUrl),
      body: {
        'userId': widget.currentUserId,
        "phone": widget.phone.toString(),
        'ex_type': '1',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['isOpen'] == true) {
        endTime = data['endTime'].toString();

        try {
          int endTimeMillis = int.tryParse(endTime) ?? 0;
          if (endTimeMillis >= DateTime.now().millisecondsSinceEpoch) {
            await preferences.setBool("isOpened", true);
            await preferences.setString("endTime", endTime);
            navigateToQuiz();
          } else {
            bool wasAlreadyOpened = await preferences.setBool("isOpened", true);

            if (!mounted) return;
            setState(() {
              isAlreadyOpened = wasAlreadyOpened;
            });
            showErrorDialog(
                "Your study period has expired. Please pay again to continue studying.");
          }
        } catch (e) {
          showErrorDialog("Please wait a moment.");
        }
      } else {
        showErrorDialog(
            "Exams are not open. Click the blue 'Request Code' button to open the exams.");
      }
    } else {
      print("Failed to connect to API");
    }
  }

  void navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OpenQuiz(
            quizId: widget.quizId,
            title: widget.title + " " + (widget.index + 1).toString(),
            quizNumber: widget.index + 1,
            questions: widget.questions,
            quizType: widget.quizType,
            examType: "English",
          );
        },
      ),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle card tap
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quiz Header
                Row(
                  children: [
                    // Small Circular Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          widget.imgurl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.quiz_rounded,
                                color: kPrimaryColor,
                                size: 28,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.index + 1}. ${widget.title}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    widget.userRole == "Admin"
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.quizType == "Free"
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.quizType,
                              style: TextStyle(
                                color: widget.quizType == "Free"
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),

                const SizedBox(height: 12),

                // Start Button
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: handleButtonClick,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.userRole == "Admin"
                                ? "Open Exam"
                                : "Start Exam",
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.play_arrow_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
