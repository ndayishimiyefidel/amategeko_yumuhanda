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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      createdAt: json['createdAt'],
      password: json['password'],
      role: json['role'],
      phone: json['phone'],
      referralCode: json['referralCode'],
      name: json['name'],
      state: json['state'],
      deviceId: json['deviceId'],
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'createdAt': createdAt,
      'password': password,
      'role': role,
      'phone': phone,
      'referralCode': referralCode,
      'name': name,
      'state': state.toString(),
      'deviceId': deviceId,
      'fcmToken': fcmToken,
    };
  }
}
class IremboModel {
  String uid;
  String createdAt;
  String phone;
  String name;
  String address;
  String identity,type;
  String? code,category;

  IremboModel({
    required this.uid,
    required this.phone,
    required this.identity,
    required this.name,
    required this.type,
    required this.address,
    required this.createdAt,
  this.category, this.code,
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
      type:json['type'],
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