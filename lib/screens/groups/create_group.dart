import 'package:amategeko/components/text_field_container.dart';
import 'package:amategeko/screens/groups/group_list.dart';
import 'package:amategeko/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

import '../../utils/constants.dart';
import '../homepages/notificationtab.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  //from

  _CreateGroupState() {
    _selectedType = _groupType[0];
  }

  final _formkey = GlobalKey<FormState>();
  String linkUrl = "", groupName = "", quizDesc = "";
  String _selectedType = "";

  final _groupType = ["Whatsapp", "Facebook"];

  //adding controller
  final TextEditingController groupUrlController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupPriceController = TextEditingController();
  String groupPrice = "";

  //database service
  bool _isLoading = false;
  final bool isNew = true;
  DatabaseService databaseService = DatabaseService();

  Future createquizOnline() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String groupId = randomAlphaNumeric(16);

      Map<String, String> groupMap = {
        "quizId": groupId,
        "groupName": groupName,
        "linkUrl": linkUrl,
        "groupType": _selectedType,
        "groupPrice": groupPrice
      };
      await databaseService.uploadGroupData(groupMap).then((value) {
        setState(() {
          _isLoading = false;
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: const Text("Group created successfully"),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    //quiz url image
    Size size = MediaQuery.of(context).size;
    final groupLinkField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: groupUrlController,
        onSaved: (value) {
          groupUrlController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.url,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.link_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Group Url",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          linkUrl = val;
          print(linkUrl);
        },
      ),
    );
    final groupPriceField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: groupPriceController,
        onSaved: (value) {
          groupPriceController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        enabled: _selectedType == "Whatsapp",
        decoration: const InputDecoration(
          icon: Icon(
            Icons.price_change_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Group Price",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          groupPrice = val;
          print(groupPrice);
        },
      ),
    );
    //quiz title field
    final groupTitleField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: groupNameController,
        onSaved: (value) {
          groupNameController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.title_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Group Name",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          groupName = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter quiz title' : null,
      ),
    );

    final groupTypeField = TextFieldContainer(
      child: DropdownButtonFormField(
        value: _selectedType,
        items: _groupType
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (val) {
          setState(() {
            _selectedType = val as String;
            print(_selectedType);
          });
        },
        icon: const Icon(
          Icons.arrow_drop_down_circle,
          // color: kPrimaryColor,
        ),
        dropdownColor: Colors.white,
        decoration: const InputDecoration(
          hintText: "Group Type",
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.group_add_outlined,
            color: kPrimaryColor,
          ),
        ),
      ),
    );
    final createGroupBtn = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.7,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
            createquizOnline();
          },
          child: const Text(
            "CREATE GROUP",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Create Groups",
          style:
              TextStyle(letterSpacing: 1.25, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Notifications(),
                ),
              );
            },
          )
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  const Text(
                    "GROUP MAKER",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 2),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  const Text(
                    "Create group,it's simple and easy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black26,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  groupTitleField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  groupLinkField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  groupTypeField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  groupPriceField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  createGroupBtn,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  _isLoading
                      ? const LinearProgressIndicator()
                      : Container(
                          child: null,
                        ),
                  SizedBox(height: size.height * 0.03),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      const Text(
                        "Already created group ? ",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const GroupList();
                              },
                            ),
                          );
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
