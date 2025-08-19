import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';
import '../../widgets/audio_player_widget.dart';
import '../../services/course_service.dart';
import '../../services/audio_manager.dart';
import '../../enume/models/course_model.dart';
import '../../enume/models/lesson_model.dart';
import '../../ads/ad_manager.dart'; // Import ad manager
import 'lesson_editor.dart';
import 'course_editor.dart';

class CourseManagement extends StatefulWidget {
  const CourseManagement({Key? key}) : super(key: key);

  @override
  State<CourseManagement> createState() => _CourseManagementState();
}

class _CourseManagementState extends State<CourseManagement> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<CourseModel> courses = [];
  List<LessonModel> lessons = [];
  bool isLoading = false;
  String? userRole;
  String? currentUserId;
  String? currentUserName;
  int from = 0;
  int to = 10;
  int totalRows = 0;
  bool canAccessOnlineSchool = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _fetchCourses();
  }

  Future<void> _getUserData() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      userRole = preferences.getString("role");
      currentUserId = preferences.getString("uid");
      currentUserName = preferences.getString("name");
      canAccessOnlineSchool =
          preferences.getBool("canAccessOnlineSchool") ?? false;
    });
    print(
        "🔍 DEBUG FROM GET CURRENT USER DATA: Can access online school: $canAccessOnlineSchool");
    print("🔍 DEBUG FROM GET CURRENT USER DATA: User role: $userRole");
  }

  Future<void> _fetchCourses() async {
    setState(() {
      isLoading = true;
    });

    final result = await CourseService.getAllCourses(from: from, to: to);

    if (result['success']) {
      setState(() {
        if (from == 0) {
          courses.clear();
        }
        courses.addAll(result['courses']);
        totalRows = result['total'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Failed to fetch courses',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _createCourse() async {
    // Show interstitial ad for content creation
    AdPlacement.onContentCreation();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CourseEditor(),
      ),
    );

    if (result == true) {
      _fetchCourses();
    }
  }

  Future<void> _deleteCourse(CourseModel course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete "${course.courseTitle}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await CourseService.deleteCourse(course.courseId);

      if (result['success']) {
        Fluttertoast.showToast(
          msg: 'Course deleted successfully',
          backgroundColor: Colors.green,
        );
        _fetchCourses();
      } else {
        Fluttertoast.showToast(
          msg: result['message'] ?? 'Failed to delete course',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: ModernAppBar(
        title: 'Course Management',
        subtitle: 'Manage Courses & Lessons',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          if (userRole == 'Admin')
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _createCourse,
              tooltip: 'Add New Course',
            ),
        ],
      ),
      body: isLoading && courses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withValues(alpha: 0.1),
                        kPrimaryColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              color: kPrimaryColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Online School",
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Manage your educational content",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${courses.length} courses available",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Courses List
                Expanded(
                  child: courses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No courses available",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Create your first course to get started",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (userRole == 'Admin')
                                ElevatedButton.icon(
                                  onPressed: _createCourse,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create Course'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return _buildCourseCard(course);
                          },
                        ),
                ),

                // Load More Button
                if (to <= totalRows)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                from = to;
                                to += 10;
                                _fetchCourses();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Load More Courses",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    print('🔍 DEBUG: course type: ${course.courseType}');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openCourseDetails(course),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.book_rounded,
                        color: kPrimaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.courseTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            course.courseDescription,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (userRole == 'Admin') ...[
                      IconButton(
                        onPressed: () => _editCourse(course),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                        tooltip: 'Edit Course',
                      ),
                      IconButton(
                        onPressed: () => _deleteCourse(course),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Delete Course',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (userRole == 'User' && course.courseType == 'Free')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: course.courseType == 'Free'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course.courseType,
                          style: TextStyle(
                            color: course.courseType == 'Free'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else if (userRole == 'Admin')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: course.courseType == 'Free'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course.courseType,
                          style: TextStyle(
                            color: course.courseType == 'Free'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    if (course.courseType == 'Paid' && userRole == 'Admin')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${course.coursePrice} RWF',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.article_rounded,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.totalLessons} lessons',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCourseDetails(CourseModel course) {
    // Show interstitial ad for course viewing
    AdPlacement.onCourseView();
    if (canAccessOnlineSchool ||
        userRole == 'Admin' ||
        course.courseType == 'Free') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailsScreen(course: course),
        ),
      );
    } else {
      //Fluttertoast.showToast(
      //   msg: "You don't have access to this course",
      //   backgroundColor: Colors.red,
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Access denied. Please contact admin on +250788659575 to grant access to this course.',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _editCourse(CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseEditor(course: course),
      ),
    ).then((result) {
      if (result == true) {
        _fetchCourses();
      }
    });
  }
}

class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  List<LessonModel> lessons = [];
  bool isLoading = false;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _fetchLessons();
  }

  Future<void> _getUserRole() async {
    final preferences = await SharedPreferences.getInstance();
    setState(() {
      userRole = preferences.getString("role");
    });
  }

  Future<void> _fetchLessons() async {
    setState(() {
      isLoading = true;
    });

    print('🔍 DEBUG: Fetching lessons for course: ${widget.course.courseId}');
    // print('🔍 DEBUG: course type: ${widget.course.courseType}');

    final result = await CourseService.getCourseLessons(
      courseId: widget.course.courseId,
    );

    print('🔍 DEBUG: Lessons API Response: $result');

    if (result['success']) {
      setState(() {
        lessons = result['lessons'];
        isLoading = false;
      });

      // Debug: Print lesson details
      for (int i = 0; i < lessons.length; i++) {
        final lesson = lessons[i];
        print('🔍 DEBUG: Lesson ${i + 1}: ${lesson.title}');
        print('🔍 DEBUG: - Images: ${lesson.images}');
        print('🔍 DEBUG: - Audios: ${lesson.audios}');
        print('🔍 DEBUG: - Images count: ${lesson.images.length}');
        print('🔍 DEBUG: - Audios count: ${lesson.audios.length}');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Failed to fetch lessons',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: widget.course.courseTitle,
        subtitle: 'Course Details',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          if (userRole == 'Admin')
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _addLesson(),
              tooltip: 'Add Lesson',
            ),
        ],
      ),
      body: Column(
        children: [
          // Course Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withValues(alpha: 0.1),
                  kPrimaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.courseDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.course.courseType == 'Free' &&
                                userRole == 'Admin'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.course.courseType,
                        style: TextStyle(
                          color: widget.course.courseType == 'Free' &&
                                  userRole == 'Admin'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.course.courseType == 'Paid' &&
                        userRole == 'Admin')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.course.coursePrice} RWF',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Lessons List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : lessons.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No lessons available",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add lessons to start teaching",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (userRole == 'Admin')
                              ElevatedButton.icon(
                                onPressed: _addLesson,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Lesson'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          return _buildLessonCard(lesson);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(LessonModel lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLesson(lesson),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.article_rounded,
                        color: kPrimaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (userRole == 'Admin') ...[
                      IconButton(
                        onPressed: () => _editLesson(lesson),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                        tooltip: 'Edit Lesson',
                      ),
                      IconButton(
                        onPressed: () => _deleteLesson(lesson),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Delete Lesson',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (lesson.images.isNotEmpty) ...[
                      Icon(
                        Icons.image,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.images.length} images',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (lesson.audios.isNotEmpty) ...[
                      Icon(
                        Icons.audiotrack,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.audios.length} audio',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addLesson() {
    // Show interstitial ad for content creation
    AdPlacement.onContentCreation();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonEditor(courseId: widget.course.courseId),
      ),
    ).then((result) {
      if (result == true) {
        _fetchLessons();
      }
    });
  }

  void _editLesson(LessonModel lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonEditor(
          courseId: widget.course.courseId,
          lesson: lesson,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _fetchLessons();
      }
    });
  }

  void _deleteLesson(LessonModel lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${lesson.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await CourseService.deleteLessonContent(lesson.id);

      if (result['success']) {
        Fluttertoast.showToast(
          msg: 'Lesson deleted successfully',
          backgroundColor: Colors.green,
        );
        _fetchLessons();
      } else {
        Fluttertoast.showToast(
          msg: result['message'] ?? 'Failed to delete lesson',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _openLesson(LessonModel lesson) {
    // Show interstitial ad for course viewing
    AdPlacement.onCourseView();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonViewer(lesson: lesson),
      ),
    );
  }
}

class LessonViewer extends StatefulWidget {
  final LessonModel lesson;

  const LessonViewer({Key? key, required this.lesson}) : super(key: key);

  @override
  State<LessonViewer> createState() => _LessonViewerState();
}

class _LessonViewerState extends State<LessonViewer> {
  String? currentUserId;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  @override
  void dispose() {
    // Stop any playing audio when leaving this screen
    _audioManager.stopCurrentAudio();
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentUserId = preferences.getString("uid");
      });
    }
  }

  void _onAudioStarted() {
    // This will be called when any audio starts playing
    // We can use this to stop other audios if needed
  }

  void _onAudioStopped() {
    if (mounted) {
      setState(() {
        // _currentlyPlayingAudioIndex = null; // This line is removed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: widget.lesson.title,
        subtitle: 'Lesson Content',
        onMenuPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson Title
            Text(
              widget.lesson.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Lesson Description
            Text(
              widget.lesson.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Images
            if (widget.lesson.images.isNotEmpty) ...[
              Text(
                'Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.lesson.images
                  .map((imageUrl) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://rwandatraffic.rw/user/$imageUrl',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                  '🔍 DEBUG: Image error for $imageUrl: $error');
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ))
                  .toList(),
              const SizedBox(height: 24),
            ],

            // Audio Files
            if (widget.lesson.audios.isNotEmpty) ...[
              Text(
                'Audio Files',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.lesson.audios.asMap().entries.map((entry) {
                final audioUrl = entry.value;
                return ModernAudioPlayer(
                  audioUrl: 'https://rwandatraffic.rw/user/$audioUrl',
                  audioTitle: audioUrl.split('/').last,
                  lessonId: widget.lesson.id,
                  userId: currentUserId ?? '',
                  onAudioStarted: () {
                    setState(() {
                      // _currentlyPlayingAudioIndex = index; // This line is removed
                    });
                    _onAudioStarted();
                  },
                  onAudioStopped: _onAudioStopped,
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
