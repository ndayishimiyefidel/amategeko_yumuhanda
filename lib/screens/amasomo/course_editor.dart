import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';
import '../../components/text_field_container.dart';
import '../../services/course_service.dart';
import '../../enume/models/course_model.dart';

class CourseEditor extends StatefulWidget {
  final CourseModel? course;

  const CourseEditor({Key? key, this.course}) : super(key: key);

  @override
  State<CourseEditor> createState() => _CourseEditorState();
}

class _CourseEditorState extends State<CourseEditor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCourseType = "Free";
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.course != null;
    if (_isEditing && widget.course != null) {
      _titleController.text = widget.course!.courseTitle;
      _descriptionController.text = widget.course!.courseDescription;
      _priceController.text = widget.course!.coursePrice;
      _selectedCourseType = widget.course!.courseType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final course = CourseModel(
      courseId: widget.course?.courseId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      courseTitle: _titleController.text.trim(),
      courseDescription: _descriptionController.text.trim(),
      courseType: _selectedCourseType,
      coursePrice: _priceController.text.trim(),
      createdAt: widget.course?.createdAt ??
          DateTime.now().millisecondsSinceEpoch.toString(),
    );

    print('🔍 DEBUG: Saving course - isEditing: $_isEditing');
    print('🔍 DEBUG: Course data: ${course.toJson()}');
    print('🔍 DEBUG: Original course ID: ${widget.course?.courseId}');
    print('🔍 DEBUG: New course ID: ${course.courseId}');

    Map<String, dynamic> result;
    if (_isEditing) {
      print('🔍 DEBUG: Calling updateCourse API');
      result = await CourseService.updateCourse(course);
    } else {
      print('🔍 DEBUG: Calling createCourse API');
      result = await CourseService.createCourse(course);
    }

    print('🔍 DEBUG: API Response: $result');

    setState(() {
      _isLoading = false;
    });

    // Check if the operation was successful
    final bool isSuccess =
        result['success'] == true || result['created'] == true;

    if (isSuccess) {
      Fluttertoast.showToast(
        msg: _isEditing
            ? 'Course updated successfully'
            : 'Course created successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Failed to save course',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: _isEditing ? 'Edit Course' : 'Create Course',
        subtitle: 'Course Information',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveCourse,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEditing
                            ? Icons.edit_rounded
                            : Icons.add_circle_rounded,
                        size: 40,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isEditing ? 'Edit Course' : 'Create New Course',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditing
                          ? 'Update course information and settings'
                          : 'Add a new course to your online school',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Course Title
              Text(
                'Course Title *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextFieldContainer(
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter course title",
                    border: InputBorder.none,
                    icon: Icon(Icons.title, color: kPrimaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a course title';
                    }
                    if (value.trim().length < 3) {
                      return 'Course title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Course Description
              Text(
                'Course Description *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextFieldContainer(
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Enter course description",
                    border: InputBorder.none,
                    icon: Icon(Icons.description, color: kPrimaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a course description';
                    }
                    if (value.trim().length < 10) {
                      return 'Course description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Course Type
              Text(
                'Course Type *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              TextFieldContainer(
                child: DropdownButtonFormField<String>(
                  value: _selectedCourseType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.category, color: kPrimaryColor),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Free",
                      child: Text("Free Course"),
                    ),
                    DropdownMenuItem(
                      value: "Paid",
                      child: Text("Paid Course"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseType = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Course Price (only for paid courses)
              if (_selectedCourseType == "Paid") ...[
                Text(
                  'Course Price (RWF) *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextFieldContainer(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter course price in RWF",
                      border: InputBorder.none,
                      icon: Icon(Icons.price_change, color: kPrimaryColor),
                    ),
                    validator: (value) {
                      if (_selectedCourseType == "Paid") {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a course price';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Please enter a valid price';
                        }
                        if (int.parse(value.trim()) <= 0) {
                          return 'Price must be greater than 0';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditing ? 'Update Course' : 'Create Course',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
