import 'package:flutter/material.dart';

class OpenNotification extends StatefulWidget {
  final String notificationId;
  const OpenNotification({Key? key, required this.notificationId})
      : super(key: key);

  @override
  State<OpenNotification> createState() => _OpenNotificationState();
}

class _OpenNotificationState extends State<OpenNotification> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
