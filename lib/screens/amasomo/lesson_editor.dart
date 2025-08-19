import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';
import '../../components/text_field_container.dart';
import '../../services/course_service.dart';
import '../../enume/models/lesson_model.dart';

class LessonEditor extends StatefulWidget {
  final String courseId;
  final LessonModel? lesson;

  const LessonEditor({
    Key? key,
    required this.courseId,
    this.lesson,
  }) : super(key: key);

  @override
  State<LessonEditor> createState() => _LessonEditorState();
}

class _LessonEditorState extends State<LessonEditor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<File> _selectedImageFiles = [];
  List<File> _selectedAudioFiles = [];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.lesson != null;
    if (_isEditing && widget.lesson != null) {
      _titleController.text = widget.lesson!.title;
      _descriptionController.text = widget.lesson!.description;

      print('🔍 DEBUG: Editing lesson - ID: ${widget.lesson!.id}');
      print('🔍 DEBUG: Existing images: ${widget.lesson!.images}');
      print('🔍 DEBUG: Existing audios: ${widget.lesson!.audios}');
    } else {
      print('🔍 DEBUG: Creating new lesson');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImageFiles.addAll(
          result.files.map((file) => File(file.path!)).toList(),
        );
      });
    }
  }

  Future<void> _pickAudioFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedAudioFiles.addAll(
          result.files.map((file) => File(file.path!)).toList(),
        );
      });
    }
  }

  void _removeImageFile(int index) {
    setState(() {
      _selectedImageFiles.removeAt(index);
    });
  }

  void _removeAudioFile(int index) {
    setState(() {
      _selectedAudioFiles.removeAt(index);
    });
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    print('🔍 DEBUG: Saving lesson - isEditing: $_isEditing');
    print('🔍 DEBUG: Course ID: ${widget.courseId}');
    print('🔍 DEBUG: Lesson ID: ${widget.lesson?.id}');
    print('🔍 DEBUG: Title: ${_titleController.text.trim()}');
    print('🔍 DEBUG: Description: ${_descriptionController.text.trim()}');
    print('🔍 DEBUG: Image files count: ${_selectedImageFiles.length}');
    print('🔍 DEBUG: Audio files count: ${_selectedAudioFiles.length}');

    Map<String, dynamic> result;

    if (_isEditing && widget.lesson != null) {
      print('🔍 DEBUG: Calling updateLessonContent API');
      result = await CourseService.updateLessonContent(
        lessonId: widget.lesson!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageFiles: _selectedImageFiles.isNotEmpty ? _selectedImageFiles : null,
        audioFiles: _selectedAudioFiles.isNotEmpty ? _selectedAudioFiles : null,
      );
    } else {
      print('🔍 DEBUG: Calling uploadLessonContent API');
      result = await CourseService.uploadLessonContent(
        courseId: widget.courseId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageFiles: _selectedImageFiles.isNotEmpty ? _selectedImageFiles : null,
        audioFiles: _selectedAudioFiles.isNotEmpty ? _selectedAudioFiles : null,
      );
    }

    print('🔍 DEBUG: Lesson save API Response: $result');

    setState(() {
      _isLoading = false;
    });

    // Check if the operation was successful
    final bool isSuccess =
        result['success'] == true || result['created'] == true;

    if (isSuccess) {
      Fluttertoast.showToast(
        msg: _isEditing
            ? 'Lesson updated successfully'
            : 'Lesson created successfully',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: result['message'] ?? 'Failed to save lesson',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: _isEditing ? 'Edit Lesson' : 'Create Lesson',
        subtitle: 'Lesson Content',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveLesson,
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
                        _isEditing ? Icons.edit_rounded : Icons.article_rounded,
                        size: 40,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isEditing ? 'Edit Lesson' : 'Create New Lesson',
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
                          ? 'Update lesson content and media'
                          : 'Add a new lesson with text, images, and audio',
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

              // Lesson Title
              Text(
                'Lesson Title *',
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
                    hintText: "Enter lesson title",
                    border: InputBorder.none,
                    icon: Icon(Icons.title, color: kPrimaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a lesson title';
                    }
                    if (value.trim().length < 3) {
                      return 'Lesson title must be at least 3 characters';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Lesson Description
              Text(
                'Lesson Description *',
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
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: "Enter lesson description and content",
                    border: InputBorder.none,
                    icon: Icon(Icons.description, color: kPrimaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a lesson description';
                    }
                    if (value.trim().length < 10) {
                      return 'Lesson description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Existing Media Section (when editing)
              if (_isEditing && widget.lesson != null) ...[
                Text(
                  'Existing Media',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Existing Images
                if (widget.lesson!.images.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Existing Images (${widget.lesson!.images.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...widget.lesson!.images
                            .map((imageUrl) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          imageUrl.split('/').last,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Existing Audio
                if (widget.lesson!.audios.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.audiotrack,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Existing Audio (${widget.lesson!.audios.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...widget.lesson!.audios
                            .map((audioUrl) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.audiotrack,
                                        color: Colors.blue,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          audioUrl.split('/').last,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],

              // Media Section
              Text(
                'Media Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Images Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Images',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                'Add multiple images to your lesson',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickImageFiles,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Images'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Selected Images Grid
                    if (_selectedImageFiles.isNotEmpty) ...[
                      Text(
                        'Selected Images (${_selectedImageFiles.length}):',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _selectedImageFiles.length,
                        itemBuilder: (context, index) {
                          final file = _selectedImageFiles[index];
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImageFile(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Audio Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.audiotrack,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Audio Files',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                'Add multiple audio files to your lesson',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickAudioFiles,
                          icon: const Icon(Icons.audio_file),
                          label: const Text('Add Audio'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Selected Audio Files
                    if (_selectedAudioFiles.isNotEmpty) ...[
                      Text(
                        'Selected Audio Files (${_selectedAudioFiles.length}):',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._selectedAudioFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.audiotrack,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.path.split('/').last,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Audio File',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeAudioFile(index),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[400],
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLesson,
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
                          _isEditing ? 'Update Lesson' : 'Create Lesson',
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
