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
