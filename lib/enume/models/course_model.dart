class CourseModel {
  final String courseId;
  final String courseTitle;
  final String courseDescription;
  final String courseType; // Free or Paid
  final String coursePrice;
  final String createdAt;
  final int totalLessons;
  final bool isActive;

  CourseModel({
    required this.courseId,
    required this.courseTitle,
    required this.courseDescription,
    required this.courseType,
    required this.coursePrice,
    required this.createdAt,
    this.totalLessons = 0,
    this.isActive = true,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json['courseId'] ?? '',
      courseTitle: json['courseTitle'] ?? '',
      courseDescription: json['courseDesc'] ?? '',
      courseType: json['courseType'] ?? 'Free',
      coursePrice: json['coursePrice'] ?? '0',
      createdAt: json['createdAt'] ?? '',
      totalLessons: int.tryParse(json['totalLessons']?.toString() ?? '0') ?? 0,
      isActive: _parseIsActive(json['isActive']),
    );
  }

  static bool _parseIsActive(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value == 1;
    }
    return true; // Default to true if parsing fails
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseTitle': courseTitle,
      'courseDesc': courseDescription,
      'courseType': courseType,
      'coursePrice': coursePrice,
      'createdAt': createdAt,
      'totalLessons': totalLessons.toString(),
      'isActive': isActive ? '1' : '0',
    };
  }
}
