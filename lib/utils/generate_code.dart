import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../backend/apis/db_connection.dart';

class GenerateUser {
  static Future<void> generateCodeAndNotify(
    BuildContext context,
    String docId,
    String generatedCode,
    String name,
    String msg,
    String phone,
    String ex_type,
    String createdAt,
  ) async {
    final Map<String, dynamic> requestBody = {
      'docId': docId,
      'generatedCode': generatedCode,
      'phone': phone.toString(),
      'ex_type': ex_type.toString(),
      'name': name,
      'createdAt': createdAt
    };

    final url = API.generatecode;
    final response = await http.post(
      Uri.parse(url),
      body: requestBody,
    );

    print("Response body ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //  print("Response body $data");

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
      String ex_type, String deleteApiUrl, String name, String msg) async {
    final Map<String, String> requestBody = {
      'docId': docId,
      'ex_type': ex_type.toString(),
    };

    final response = await http.post(
      Uri.parse(deleteApiUrl),
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

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
        print("Response body $data");
      }
    } else {
      // Handle HTTP request error
    }
  }

  static Future<bool> setCodeLimit(
    BuildContext context,
    String userId,
    String apiUrl,
    String updatedAt,
    String expirationTime,
    String phone,
    String ex_type,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'userId': userId,
          'updatedAt': updatedAt,
          'endedAt': expirationTime,
          'phone': phone,
          'ex_type': ex_type,
        },
      );

      if (response.statusCode == 200) {
        // Assume a successful response contains a success flag in JSON
        final responseData = json.decode(response.body);
        return responseData['success'];
      } else {
        final responseData = json.decode(response.body);
        print("Response set: " + responseData);
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  static Future<bool> setExpirationTime(
    BuildContext context,
    String userId,
    String examNumber,
    String createdAt,
    String apiUrl,
    String updatedAt,
    String expirationTime,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'userId': userId,
          'examNumber': examNumber,
          'createdAt': createdAt,
          'updatedAt': updatedAt,
          'endedAt': expirationTime,
        },
      );

      if (response.statusCode == 200) {
        // Assume a successful response contains a success flag in JSON
        final responseData = json.decode(response.body);
        return responseData['success'];
      } else {
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
