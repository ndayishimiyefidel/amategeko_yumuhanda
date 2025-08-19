import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';
import '../homepages/notificationtab.dart';

class EditQuiz extends StatefulWidget {
  final String quizId, quizTitle, quizType, quizImage, quizDesc, quizPrice;

  const EditQuiz({
    Key? key,
    required this.quizId,
    required this.quizTitle,
    required this.quizType,
    required this.quizImage,
    required this.quizDesc,
    required this.quizPrice,
  }) : super(key: key);

  @override
  State<EditQuiz> createState() => _EditQuizState();
}

class _EditQuizState extends State<EditQuiz> {
  _EditQuizState() {
    _selectedtype = _quizType[0];
  }

  final _formkey = GlobalKey<FormState>();
  String quizUrl = "", quizTitle = "", quizDesc = "";
  String quizId = "";
  String _selectedtype = "";

  final picker = ImagePicker();
  File? pickedFile;

  Future selectsFile() async {
    final pickedFiles = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFiles != null) {
        pickedFile = File(pickedFiles.path);
        _isLoading = true;
      }
    });
  }

  final _quizType = ["Free", "Paid"];

  //adding controller
  final TextEditingController quizurlController = TextEditingController();
  final TextEditingController quiztitleController = TextEditingController();
  final TextEditingController quizdescController = TextEditingController();
  final TextEditingController quizPriceController = TextEditingController();
  String quizPrice = "";

  @override
  void initState() {
    super.initState();

    ///initialize data
    quizurlController.text = widget.quizImage;
    quiztitleController.text = widget.quizTitle;
    quizdescController.text = widget.quizDesc;
    quizPriceController.text = widget.quizPrice;
  }

  bool _isLoading = false;
  final bool isNew = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Edit',
        subtitle: 'Quiz',
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Notifications(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPrimaryColor.withValues(alpha: 0.05),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                children: <Widget>[
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
                          Icons.edit_rounded,
                          size: 48,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Edit Quiz",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Update quiz information and settings",
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

                  // Quiz Image Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
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
                            Text(
                              "Quiz Image",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Image Display
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: (pickedFile == null)
                                ? CachedNetworkImage(
                                    imageUrl: widget.quizImage,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported_rounded,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Image.file(
                                    pickedFile!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Change Image Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: selectsFile,
                            icon: const Icon(Icons.camera_alt_rounded),
                            label: const Text(
                              "Change Image",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimaryColor,
                              side: BorderSide(color: kPrimaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quiz Type Field
                  _buildDropdownField(
                    value: widget.quizType.isEmpty
                        ? _selectedtype
                        : widget.quizType,
                    label: "Quiz Type",
                    icon: Icons.quiz_rounded,
                    items: _quizType
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedtype = val as String;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Quiz Title Field
                  _buildFormField(
                    controller: quiztitleController,
                    label: "Quiz Title",
                    icon: Icons.title_rounded,
                    validator: (input) => input != null && input.length < 5
                        ? 'Enter quiz title'
                        : null,
                    onChanged: (val) => quizTitle = val,
                  ),

                  const SizedBox(height: 20),

                  // Quiz Description Field
                  _buildDescriptionField(
                    controller: quizdescController,
                    label: "Description",
                    icon: Icons.description_rounded,
                    onChanged: (val) => quizDesc = val,
                  ),

                  const SizedBox(height: 20),

                  // Quiz Price Field
                  _buildFormField(
                    controller: quizPriceController,
                    label: "Quiz Price",
                    icon: Icons.price_change_rounded,
                    keyboardType: TextInputType.number,
                    onChanged: (val) => quizPrice = val,
                  ),

                  const SizedBox(height: 32),

                  // Update Quiz Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle quiz update
                      },
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
                          : const Text(
                              "Update Quiz",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: kPrimaryColor,
                size: 20,
              ),
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

  Widget _buildDescriptionField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(
                  icon,
                  color: kPrimaryColor,
                  size: 20,
                ),
              ),
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

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem> items,
    required Function(String?) onChanged,
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
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: kPrimaryColor,
                size: 20,
              ),
              hintText: "Select $label",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items as List<DropdownMenuItem<String>>,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
