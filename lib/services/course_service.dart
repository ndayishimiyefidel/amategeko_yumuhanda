import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../backend/apis/db_connection.dart';
import '../enume/models/course_model.dart';
import '../enume/models/lesson_model.dart';

class CourseService {
  static const String baseUrl = API.baseUrl;

  // ========================================
  // COURSE MANAGEMENT METHODS
  // ========================================

  // Get all courses with pagination
  static Future<Map<String, dynamic>> getAllCourses({
    int from = 0,
    int to = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${API.courseList}?from=$from&to=$to'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final courses = (data['data'] as List)
              .map((course) => CourseModel.fromJson(course))
              .toList();

          return {
            'success': true,
            'courses': courses,
            'total': int.tryParse(data['total'] ?? '0') ?? 0,
          };
        }
      }
      return {'success': false, 'message': 'Failed to fetch courses'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Search courses
  static Future<Map<String, dynamic>> searchCourses({
    String searchTerm = '',
    String courseType = '',
    int from = 0,
    int to = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'from': from.toString(),
        'to': to.toString(),
      };

      if (searchTerm.isNotEmpty) {
        queryParams['search'] = searchTerm;
      }

      if (courseType.isNotEmpty) {
        queryParams['courseType'] = courseType;
      }

      final response = await http.get(
        Uri.parse(API.searchCourses).replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final courses = (data['data'] as List)
              .map((course) => CourseModel.fromJson(course))
              .toList();

          return {
            'success': true,
            'courses': courses,
            'total': int.tryParse(data['total'] ?? '0') ?? 0,
            'searchTerm': searchTerm,
            'courseType': courseType,
          };
        }
      }
      return {'success': false, 'message': 'Failed to search courses'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get course by ID
  static Future<Map<String, dynamic>> getCourseById(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('${API.getCourseById}?courseId=$courseId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final course = CourseModel.fromJson(data['data']);
          return {
            'success': true,
            'course': course,
          };
        }
      }
      return {'success': false, 'message': 'Failed to fetch course'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Create new course
  static Future<Map<String, dynamic>> createCourse(CourseModel course) async {
    try {
      final response = await http.post(
        Uri.parse(API.createCourse),
        body: course.toJson(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to create course'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Update course
  static Future<Map<String, dynamic>> updateCourse(CourseModel course) async {
    try {
      print('🔍 DEBUG: updateCourse - Sending data: ${course.toJson()}');

      final response = await http.post(
        Uri.parse(API.updateCourse),
        body: {
          'courseId': course.courseId,
          'courseTitle': course.courseTitle,
          'courseDesc': course.courseDescription,
          'courseType': course.courseType,
          'coursePrice': course.coursePrice,
        },
      );

      print('🔍 DEBUG: updateCourse - Response status: ${response.statusCode}');
      print('🔍 DEBUG: updateCourse - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to update course'};
    } catch (e) {
      print('🔍 DEBUG: updateCourse - Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Delete course
  static Future<Map<String, dynamic>> deleteCourse(String courseId) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteCourse),
        body: {'courseId': courseId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to delete course'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================================
  // LESSON MANAGEMENT METHODS
  // ========================================

  // Get course lessons
  static Future<Map<String, dynamic>> getCourseLessons({
    required String courseId,
    int from = 0,
    int to = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${API.openCourseContent}?courseId=$courseId&from=$from&to=$to'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final lessons = (data['data'] as List)
              .map((lesson) => LessonModel.fromJson(lesson))
              .toList();

          return {
            'success': true,
            'lessons': lessons,
            'total': int.tryParse(data['total'] ?? '0') ?? 0,
          };
        }
      }
      return {'success': false, 'message': 'Failed to fetch lessons'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Search lessons
  static Future<Map<String, dynamic>> searchLessons({
    String searchTerm = '',
    String courseId = '',
    int from = 0,
    int to = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'from': from.toString(),
        'to': to.toString(),
      };

      if (searchTerm.isNotEmpty) {
        queryParams['search'] = searchTerm;
      }

      if (courseId.isNotEmpty) {
        queryParams['courseId'] = courseId;
      }

      final response = await http.get(
        Uri.parse(API.searchLessons).replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final lessons = (data['data'] as List)
              .map((lesson) => LessonModel.fromJson(lesson))
              .toList();

          return {
            'success': true,
            'lessons': lessons,
            'total': int.tryParse(data['total'] ?? '0') ?? 0,
            'searchTerm': searchTerm,
            'courseId': courseId,
          };
        }
      }
      return {'success': false, 'message': 'Failed to search lessons'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get lesson by ID
  static Future<Map<String, dynamic>> getLessonById(String lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('${API.getLessonById}?id=$lessonId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final lesson = LessonModel.fromJson(data['data']);
          return {
            'success': true,
            'lesson': lesson,
          };
        }
      }
      return {'success': false, 'message': 'Failed to fetch lesson'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Upload lesson content (text, images, audio)
  static Future<Map<String, dynamic>> uploadLessonContent({
    required String courseId,
    required String title,
    required String description,
    List<File>? imageFiles,
    List<File>? audioFiles,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(API.uploadContent));

      // Add text fields
      request.fields['courseId'] = courseId;
      request.fields['title'] = title;
      request.fields['description'] = description;

      // Add image files
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (var imageFile in imageFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('image[]', imageFile.path),
          );
        }
      }

      // Add audio files
      if (audioFiles != null && audioFiles.isNotEmpty) {
        for (var audioFile in audioFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('audio[]', audioFile.path),
          );
        }
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      return jsonResponse;
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Update lesson content
  static Future<Map<String, dynamic>> updateLessonContent({
    required String lessonId,
    required String title,
    required String description,
    List<File>? imageFiles,
    List<File>? audioFiles,
  }) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(API.updateLessonContent));

      // Add text fields
      request.fields['id'] = lessonId;
      request.fields['title'] = title;
      request.fields['description'] = description;

      // Add image files
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (var imageFile in imageFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('image[]', imageFile.path),
          );
        }
      }

      // Add audio files
      if (audioFiles != null && audioFiles.isNotEmpty) {
        for (var audioFile in audioFiles) {
          request.files.add(
            await http.MultipartFile.fromPath('audio[]', audioFile.path),
          );
        }
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      return jsonResponse;
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Delete lesson content
  static Future<Map<String, dynamic>> deleteLessonContent(
      String lessonId) async {
    try {
      final response = await http.post(
        Uri.parse(API.deleteContent),
        body: {'id': lessonId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to delete lesson'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Bulk delete lessons
  static Future<Map<String, dynamic>> bulkDeleteLessons(
      List<String> lessonIds) async {
    try {
      final response = await http.post(
        Uri.parse(API.bulkDeleteLessons),
        body: {'lessonIds': lessonIds.join(',')},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to delete lessons'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================================
  // AUDIO PLAYBACK TRACKING METHODS
  // ========================================

  // Track audio play
  static Future<Map<String, dynamic>> trackAudioPlay({
    required String userId,
    required String lessonId,
    required String audioUrl,
    required int playDuration,
    required int totalDuration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(API.trackAudioPlay),
        body: {
          'userId': userId,
          'lessonId': lessonId,
          'audioUrl': audioUrl,
          'playDuration': playDuration.toString(),
          'totalDuration': totalDuration.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to track audio play'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Save audio progress
  static Future<Map<String, dynamic>> saveAudioProgress({
    required String userId,
    required String lessonId,
    required String audioUrl,
    required int currentPosition,
    required int totalDuration,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(API.saveAudioProgress),
        body: {
          'userId': userId,
          'lessonId': lessonId,
          'audioUrl': audioUrl,
          'currentPosition': currentPosition.toString(),
          'totalDuration': totalDuration.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to save audio progress'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get audio progress
  static Future<Map<String, dynamic>> getAudioProgress({
    required String userId,
    required String lessonId,
    required String audioUrl,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${API.getAudioProgress}?userId=$userId&lessonId=$lessonId&audioUrl=$audioUrl'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to get audio progress'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========================================
  // USER PROGRESS & ANALYTICS METHODS
  // ========================================

  // Get user progress
  static Future<Map<String, dynamic>> getUserProgress({
    required String userId,
    String? courseId,
  }) async {
    try {
      final queryParams = <String, String>{
        'userId': userId,
      };

      if (courseId != null && courseId.isNotEmpty) {
        queryParams['courseId'] = courseId;
      }

      final response = await http.get(
        Uri.parse(API.getUserProgress).replace(queryParameters: queryParams),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to get user progress'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Track lesson view
  static Future<Map<String, dynamic>> trackLessonView({
    required String userId,
    required String lessonId,
    required String courseId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(API.trackLessonView),
        body: {
          'userId': userId,
          'lessonId': lessonId,
          'courseId': courseId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {'success': false, 'message': 'Failed to track lesson view'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
