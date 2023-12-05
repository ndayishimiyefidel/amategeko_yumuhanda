import 'dart:io';
import 'package:amategeko/components/amabwiriza.dart';
import 'package:amategeko/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../../widgets/MainDrawer.dart';

class GroupList extends StatefulWidget {
  const GroupList({Key? key}) : super(key: key);
  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  //shared preferences
  late SharedPreferences preferences;
  late String? currentuserid;
  late String currentusername;
  late String photo;
  late String phone;
  String? adminPhone;

  void getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      phone = preferences.getString("phone")!;
    });
  }

  @override
  void initState() {
    getCurrUserData();
    super.initState();
  }

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
          "Groups",
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
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          CustomButton(
            text: "Amabwiriza",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => AmabwirizaList(),
                ),
              );
            },
          )
        ],
        centerTitle: false,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
      body: Container(
          child: Center(
        child: Column(
          children: [
            FileTile(
                linkUrl: "https://chat.whatsapp.com/EqHwyLVDT6Z6FdRnLFibmu",
                groupName: "Amategeko yumuhanda VIP1"),
            FileTile(
                linkUrl: "https://chat.whatsapp.com/JHfdbKSYVFz1s5jlTKfpcm",
                groupName: "Amategeko yumuhanda VIP2")
          ],
        ),
      )),
    );
  }
}

class FileTile extends StatefulWidget {
  final String linkUrl, groupName;
  const FileTile({
    Key? key,
    required this.linkUrl,
    required this.groupName,
  }) : super(key: key);

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  bool _isLoading = false;
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
              onTap: () {},
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            //removing overflow on row widget
                            child: Column(
                              children: [
                                Text(widget.groupName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.start),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              _joinGroupIcon(),
                              SizedBox(
                                height: size.height * 0.03,
                              ),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : Container(
                                      child: null,
                                    ),
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

  Widget _joinGroupIcon() {
    return GestureDetector(
      child: const Text(
        "Join Group",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      onTap: () {
        setState(() {
          _isLoading = true;
        });
        _launchURL(widget.linkUrl);
      },
    );
  }

  _launchURL(String url) async {
    if (Platform.isIOS) {
      setState(() {
        _isLoading = false;
      });
    } else {
      //web platform, android
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        setState(() {
          _isLoading = false;
        });
      } else {
        throw 'Could not launch $url';
      }
      setState(() {
        _isLoading = false;
      });
    }
  }
}
