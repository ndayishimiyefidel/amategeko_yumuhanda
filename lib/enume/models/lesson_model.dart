import 'dart:convert';

class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final List<String> images;
  final List<String> audios;
  final String createdAt;
  final int orderIndex;
  final bool isActive;

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    this.images = const [],
    this.audios = const [],
    required this.createdAt,
    this.orderIndex = 0,
    this.isActive = true,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    print(
        '🔍 DEBUG: LessonModel.fromJson - Raw images data: ${json['images']}');
    print(
        '🔍 DEBUG: LessonModel.fromJson - Raw audios data: ${json['audios']}');

    final parsedImages = _parseStringList(json['images']);
    final parsedAudios = _parseStringList(json['audios']);

    print('🔍 DEBUG: LessonModel.fromJson - Parsed images: $parsedImages');
    print('🔍 DEBUG: LessonModel.fromJson - Parsed audios: $parsedAudios');

    return LessonModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: parsedImages,
      audios: parsedAudios,
      createdAt: json['createdAt']?.toString() ?? '',
      orderIndex: int.tryParse(json['orderIndex']?.toString() ?? '0') ?? 0,
      isActive: _parseIsActive(json['isActive']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];

    // Handle string that might be JSON
    if (value is String) {
      try {
        // Try to parse as JSON first
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return _flattenList(decoded);
        }
      } catch (e) {
        // If not JSON, treat as comma-separated string
        return value.split(',').where((e) => e.trim().isNotEmpty).toList();
      }
    }

    // Handle List
    if (value is List) {
      return _flattenList(value);
    }

    return [];
  }

  static List<String> _flattenList(List list) {
    List<String> result = [];
    for (var item in list) {
      if (item is String) {
        if (item.trim().isNotEmpty) {
          result.add(item.trim());
        }
      } else if (item is List) {
        result.addAll(_flattenList(item));
      } else {
        final str = item.toString().trim();
        if (str.isNotEmpty) {
          result.add(str);
        }
      }
    }
    return result;
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
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'images': images.join(','),
      'audios': audios.join(','),
      'createdAt': createdAt,
      'orderIndex': orderIndex.toString(),
      'isActive': isActive ? '1' : '0',
    };
  }
}
