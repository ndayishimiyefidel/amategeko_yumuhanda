import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdManager {
  static const String _deviceIdKey = "deviceId";
  static String? _deviceId;

  static Future<String> getDeviceId() async {
    if (_deviceId == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _deviceId = prefs.getString(_deviceIdKey);
      _deviceId ??= await _generateAndStoreDeviceId();
    }
    return _deviceId!;
  }

  static Future<String> _generateAndStoreDeviceId() async {
    String? uniqueId;
    if (Platform.isAndroid) {
      uniqueId = await _getAndroidDeviceId();
    } else if (Platform.isIOS) {
      uniqueId = await _getIOSDeviceId();
    } else if (Platform.isLinux ||
        Platform.isWindows ||
        Platform.isMacOS ||
        kIsWeb) {
      uniqueId = await _generateWebDeviceId();
    }

    uniqueId ??= const Uuid().v4();

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
      // Print the error
      return null;
    }
  }

  static Future<String?> _getIOSDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosDeviceInfo;
    try {
      iosDeviceInfo = await deviceInfo.iosInfo;
      // Concatenate multiple device identifiers for uniqueness
      return "${iosDeviceInfo.identifierForVendor}${iosDeviceInfo.localizedModel}${iosDeviceInfo.systemVersion}";
    } catch (e) {
      // Print the error
      return null;
    }
  }

  static Future<String> _generateWebDeviceId() async {
    // Simple UUID-based device ID for the web platform
    return Uuid().v4();
  }
}
