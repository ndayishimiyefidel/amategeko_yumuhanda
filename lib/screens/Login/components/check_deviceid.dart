import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdManager {
  static const String _deviceIdKey = "deviceId";
  static String? _deviceId;

  static Future<String> getDeviceId() async {
    if (_deviceId == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _deviceId = prefs.getString(_deviceIdKey);
      if (_deviceId == null) {
        _deviceId = await _generateAndStoreDeviceId();
      }
    }
    return _deviceId!;
  }

  static Future<String> _generateAndStoreDeviceId() async {
    String? uniqueId;
    if (Platform.isAndroid) {
      uniqueId = await _getAndroidDeviceId();
    } else if (Platform.isIOS) {
      uniqueId = await _getIOSDeviceId();
    }

    uniqueId ??=
        const Uuid()
            .v4();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, uniqueId);

    return uniqueId;
  }

  static Future<String?> _getAndroidDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo? androidDeviceInfo;
    try {
      androidDeviceInfo = await deviceInfo.androidInfo;
      return "${androidDeviceInfo.id}${androidDeviceInfo.manufacturer}";
    } catch (e) {
      print("Failed to get Android Device ID: $e"); // Print the error
      return null;
    }
  }

  static Future<String?> _getIOSDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosDeviceInfo;
    try {
      iosDeviceInfo = await deviceInfo.iosInfo;
      // Concatenate multiple device identifiers for uniqueness
      return "${iosDeviceInfo.identifierForVendor}${iosDeviceInfo
          .localizedModel}${iosDeviceInfo.systemVersion}";
    } catch (e) {
      print("Failed to get iOS Device ID: $e"); // Print the error
      return null;
    }
  }
}
