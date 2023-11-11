import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InstructionItems extends StatelessWidget {
  final String title;
  final List<String> phoneNumbers;

  InstructionItems({
    required this.title,
    required this.phoneNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildPhoneList(),
        ),
      ],
    );
  }

  List<Widget> _buildPhoneList() {
    List<Widget> phoneWidgets = [];

    for (int i = 0; i < phoneNumbers.length; i++) {
      phoneWidgets.add(_buildPhoneItem(i, phoneNumbers[i]));
    }

    return phoneWidgets;
  }

  Widget _buildPhoneItem(int number, String phoneNumber) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Phone ${number + 1}: $phoneNumber',
          style: TextStyle(fontSize: 10),
        ),
        SizedBox(
          width: 30,
        ),
        IconButton(
          icon: Icon(Icons.phone),
          color: Colors.blueAccent,
          iconSize: 25,
          onPressed: () {
            // ignore: deprecated_member_use
            launch('tel:$phoneNumber');
          },
        ),
      ],
    );
  }
}
