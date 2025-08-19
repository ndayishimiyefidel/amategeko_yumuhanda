class User {
  String uid;
  String createdAt;
  String password;
  String role;
  String phone;
  String? referralCode;
  String name;
  int state;
  String deviceId;
  String fcmToken;
  bool canAccessOnlineSchool;

  User({
    required this.uid,
    required this.createdAt,
    required this.password,
    required this.role,
    required this.phone,
    this.referralCode,
    required this.name,
    required this.state,
    required this.deviceId,
    required this.fcmToken,
    this.canAccessOnlineSchool = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print("🔍 DEBUG: Parsing User from JSON: $json");

      // Handle state field with extra care
      int stateValue = 1; // default value
      if (json['state'] != null) {
        if (json['state'] is String) {
          stateValue = int.tryParse(json['state']) ?? 1;
        } else if (json['state'] is int) {
          stateValue = json['state'];
        } else if (json['state'] is double) {
          stateValue = json['state'].toInt();
        } else {
          print("🔍 DEBUG: Unknown state type: ${json['state'].runtimeType}");
          stateValue = 1;
        }
      }

      print("🔍 DEBUG: Parsed state value: $stateValue");

      return User(
        uid: json['uid']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        referralCode: json['referralCode']?.toString(),
        name: json['name']?.toString() ?? '',
        state: stateValue,
        deviceId: json['deviceId']?.toString() ?? '',
        fcmToken: json['fcmToken']?.toString() ?? '',
        canAccessOnlineSchool: json['can_access_online_school'] == 1 ||
            json['can_access_online_school'] == true,
      );
    } catch (e, stackTrace) {
      print("🔍 DEBUG: Error in User.fromJson: $e");
      print("🔍 DEBUG: Stack trace: $stackTrace");
      print("🔍 DEBUG: JSON data: $json");

      // Return a default user object to prevent crashes
      return User(
        uid: json['uid']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        referralCode: json['referralCode']?.toString(),
        name: json['name']?.toString() ?? '',
        state: 1,
        deviceId: json['deviceId']?.toString() ?? '',
        fcmToken: json['fcmToken']?.toString() ?? '',
        canAccessOnlineSchool: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid.toString(),
      'createdAt': createdAt.toString(),
      'password': password.toString(),
      'role': role.toString(),
      'phone': phone.toString(),
      'referralCode': referralCode?.toString() ?? '',
      'name': name.toString(),
      'state': state.toString(),
      'deviceId': deviceId.toString(),
      'fcmToken': fcmToken.toString(),
      'can_access_online_school': canAccessOnlineSchool ? '1' : '0',
    };
  }
}

class IremboModel {
  String uid;
  String createdAt;
  String phone;
  String name;
  String address;
  String identity, type;
  String? code, category;

  IremboModel({
    required this.uid,
    required this.phone,
    required this.identity,
    required this.name,
    required this.type,
    required this.address,
    required this.createdAt,
    this.category,
    this.code,
  });

  factory IremboModel.fromJson(Map<String, dynamic> json) {
    return IremboModel(
      uid: json['uid'],
      createdAt: json['createdAt'],
      phone: json['phone'],
      address: json['address'],
      name: json['name'],
      identity: json['identity'],
      code: json['code'],
      category: json['category'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'createdAt': createdAt,
      'phone': phone,
      'address': address,
      'name': name,
      'identity': identity,
      'code': code,
      'category': category,
      'type': type,
    };
  }
}
