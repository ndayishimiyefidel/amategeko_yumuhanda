import 'package:flutter/material.dart';

Widget appBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(0.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 20),
            children: <TextSpan>[
              TextSpan(
                  text: 'Traffic',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black54)),
              TextSpan(
                  text: 'Rules',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.search),
                color: Colors.blue[200],
                iconSize: 25,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.notifications),
                color: Colors.blue[200],
                iconSize: 25,
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.share_outlined),
                color: Colors.blue[200],
                iconSize: 25,
                onPressed: () {},
              ),
            ],
          ),
        )
      ],
    ),
  );
}
