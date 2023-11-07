// utils.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../backend/apis/db_connection.dart';

class GenerateUser {
  static Future<void> generateCodeAndNotify(BuildContext context, String docId,
      String generatedCode, String name, String msg, int isOpen) async {
    final Map<String, dynamic> requestBody = {
      'docId': docId,
      'generatedCode': generatedCode,
      'isOpen': isOpen.toString(),
    };
    final url = API.generatecode;
    final response = await http.post(
      Uri.parse(url),
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Response body $data");

      if (data['success']) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(content: Text("$msg" + " " + "$name"), actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              )
            ]);
          },
        );
      } else {
        // Handle the case where the update failed
        print("Error happened");
      }
    } else {
      // Handle HTTP request error
    }
  }

  // You can add more reusable functions and classes here

  static Future<void> deleteUserCode(BuildContext context, String docId,
      String deleteApiUrl, String name, String msg) async {
    final Map<String, String> requestBody = {
      'docId': docId,
    };

    final response = await http.post(
      Uri.parse(deleteApiUrl),
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Response body $data");

      if (data['success']) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(content: Text("$name $msg"), actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              )
            ]);
          },
        );
      } else {
        // Handle the case where the update failed
      }
    } else {
      // Handle HTTP request error
    }
  }

  ///addedToClass
  ///

  static Future<void> addedRemoveToClass(BuildContext context, String docId,
      String limitApiUrl, String msg, String addedToClass) async {
    final Map<String, String> requestBody = {
      'docId': docId,
      'addedToClass': addedToClass,
    };

    final response = await http.post(
      Uri.parse(limitApiUrl),
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Response body $data");

      if (data['success']) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(content: Text("$msg"), actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              )
            ]);
          },
        );
      } else {
        // Handle the case where the update failed
      }
    } else {
      // Handle HTTP request error
    }
  }

  static Future<void> setCodeLimit(BuildContext context, String docId,
      String limitApiUrl, String msg, String endTime) async {
    final Map<String, String> requestBody = {
      'docId': docId,
      'endTime': endTime,
    };

    final response = await http.post(
      Uri.parse(limitApiUrl),
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Response body $data");

      if (data['success']) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(content: Text("$msg"), actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              )
            ]);
          },
        );
      } else {
        // Handle the case where the update failed
      }
    } else {
      // Handle HTTP request error
    }
  }
}
