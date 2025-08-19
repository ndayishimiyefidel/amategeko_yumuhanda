import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';

class AddQuestion extends StatefulWidget {
  final String quizId, quizTitle;
  final bool isNew;

  const AddQuestion({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.isNew,
  });

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  final _formkey = GlobalKey<FormState>();
  String question = "", option1 = "", option2 = "";
  String option3 = "", option4 = "";
  String questionUrl = "";

  final TextEditingController questionController = TextEditingController();
  final TextEditingController option1Controller = TextEditingController();
  final TextEditingController option2Controller = TextEditingController();
  final TextEditingController option3Controller = TextEditingController();
  final TextEditingController option4Controller = TextEditingController();

  bool _isLoading = false;
  final picker = ImagePicker();
  File? pickedFile;

  Future<void> selectFile() async {
    final pickedFiles = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFiles != null) {
        pickedFile = File(pickedFiles.path);
        _isLoading = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Add',
        subtitle: 'Question',
        onMenuPressed: () {
          Navigator.pop(context);
        },
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                      Icon(
                        Icons.quiz_rounded,
                        size: 48,
                        color: kPrimaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Add New Question",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Quiz: ${widget.quizTitle}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Question Field
                _buildFormField(
                  controller: questionController,
                  label: "Question",
                  icon: Icons.question_answer_outlined,
                  validator: (input) =>
                      input!.isEmpty ? 'Enter question' : null,
                  onChanged: (val) => question = val,
                ),
                const SizedBox(height: 20),

                // Image Picker Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.image_rounded,
                            color: kPrimaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              "Question Image (Optional)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (pickedFile != null) ...[
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: kPrimaryColor.withValues(alpha: 0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              pickedFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: selectFile,
                        icon: Icon(pickedFile == null
                            ? Icons.add_photo_alternate
                            : Icons.edit),
                        label: Text(
                            pickedFile == null ? "Add Image" : "Change Image"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Options Fields
                Text(
                  "Answer Options",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  controller: option1Controller,
                  label: "Option 1 (Correct Answer)",
                  icon: Icons.check_circle_outline,
                  validator: (input) =>
                      input!.isEmpty ? 'Enter option 1' : null,
                  onChanged: (val) => option1 = val,
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  controller: option2Controller,
                  label: "Option 2",
                  icon: Icons.radio_button_unchecked,
                  validator: (input) =>
                      input!.isEmpty ? 'Enter option 2' : null,
                  onChanged: (val) => option2 = val,
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  controller: option3Controller,
                  label: "Option 3",
                  icon: Icons.radio_button_unchecked,
                  validator: (input) =>
                      input!.isEmpty ? 'Enter option 3' : null,
                  onChanged: (val) => option3 = val,
                ),
                const SizedBox(height: 16),

                _buildFormField(
                  controller: option4Controller,
                  label: "Option 4",
                  icon: Icons.radio_button_unchecked,
                  validator: (input) =>
                      input!.isEmpty ? 'Enter option 4' : null,
                  onChanged: (val) => option4 = val,
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                // Add your save question logic here
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: kPrimaryColor),
              hintText: "Enter $label",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
