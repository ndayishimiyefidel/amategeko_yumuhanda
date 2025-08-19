import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

//notification channell
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
String? uToken;

// Singleton to prevent multiple permission requests
class FCMPermissionManager {
  static bool _isRequestingPermission = false;
  static bool _hasPermissionBeenRequested = false;
  static bool _isInitialized = false;

  static Future<void> initializeFCM() async {
    if (_isInitialized) {
      print('FCM already initialized, skipping...');
      return;
    }

    try {
      _isInitialized = true;

      if (!kIsWeb) {
        channel = const AndroidNotificationChannel(
          'high_importance_channel', // id
          'High Importance Notifications', // title
          importance: Importance.high,
          enableVibration: true,
        );

        flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

        /// Create an Android Notification Channel.
        ///
        /// We use this channel in the `AndroidManifest.xml` file to override the
        /// default FCM channel to enable heads up notifications.
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        /// Update the iOS foreground notification presentation options to allow
        /// heads up notifications.
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      print('Error initializing FCM: $e');
      _isInitialized = false;
    }
  }

  static Future<void> requestPermission() async {
    // Initialize FCM first if not already done
    await initializeFCM();

    // If already requesting permission, wait
    if (_isRequestingPermission) {
      print('Permission request already in progress, waiting...');
      return;
    }

    // If permission has already been requested, don't request again
    if (_hasPermissionBeenRequested) {
      print('Permission already requested, skipping...');
      return;
    }

    _isRequestingPermission = true;

    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _hasPermissionBeenRequested = true;

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error requesting permission: $e');
    } finally {
      _isRequestingPermission = false;
    }
  }
}

// Keep the old function for backward compatibility
void requestPermission() async {
  await FCMPermissionManager.requestPermission();
}

void loadFCM() async {
  await FCMPermissionManager.initializeFCM();
}

void listenFCM() async {
  try {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null && !kIsWeb) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ),
          );
        }
      } catch (e) {
        print('Error handling FCM message: $e');
      }
    });
  } catch (e) {
    print('Error setting up FCM listener: $e');
  }
}

void sendPushMessage(String token, String body, String title) async {
  try {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAA1tdzPr4:APA91bH7nF_cSwcSXDEgNqgAMyPOeXw0sWbX9P4aUWGrY8EXU07R3BUb5h6ut-97yvvATvHu8obenPtqpm-MfQRPNEr2PJ6qxMxwAzTmgnT8EysZ1J5TIYkHbKk-4zJAm-RWEf_hiEdm',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          "to": token,
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Push notification sent successfully');
    } else {
      print(
          'Failed to send push notification. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print("Error sending push notification: $e");
  }
}
