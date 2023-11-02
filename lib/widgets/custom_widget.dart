import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 5, top: 10, bottom: 10),
        child: Container(
          padding: EdgeInsets.all(5),
          child: Text(
            text,
            style: TextStyle(fontSize: 18),
          ),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            border: Border.all(
              color: Colors.red, // Border color
            ),
            borderRadius: BorderRadius.circular(10.0), // Border radius
          ),
        ),
      ),
    );
  }
}
