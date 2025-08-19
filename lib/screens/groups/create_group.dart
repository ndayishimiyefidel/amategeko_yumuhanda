import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/ModernAppBar.dart';
import '../homepages/notificationtab.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  _CreateGroupState() {
    _selectedType = _groupType[0];
  }

  final _formkey = GlobalKey<FormState>();
  String linkUrl = "", groupName = "", quizDesc = "";
  String _selectedType = "";

  final _groupType = ["WhatsApp", "Facebook"];

  final TextEditingController groupUrlController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupPriceController = TextEditingController();
  String groupPrice = "";

  bool _isLoading = false;
  final bool isNew = true;

  @override
  Widget build(BuildContext context) {
    final groupLinkField = Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        autofocus: false,
        controller: groupUrlController,
        onSaved: (value) {
          groupUrlController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.link_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Group URL",
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (val) {
          linkUrl = val;
        },
      ),
    );

    final groupPriceField = Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        autofocus: false,
        controller: groupPriceController,
        onSaved: (value) {
          groupPriceController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        enabled: _selectedType == "WhatsApp",
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.price_change_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Group Price",
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (val) {
          groupPrice = val;
        },
      ),
    );

    final groupTitleField = Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        autofocus: false,
        controller: groupNameController,
        onSaved: (value) {
          groupNameController.text = value!;
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.group_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Group Name",
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (val) {
          groupName = val;
        },
      ),
    );

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Create',
        subtitle: 'Group',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Section
                Container(
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
                        Icons.group_add_rounded,
                        size: 48,
                        color: kPrimaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Create New Group",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add a new WhatsApp or Facebook group",
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

                // Form Fields
                groupTitleField,
                groupLinkField,
                _buildGroupTypeField(),
                groupPriceField,
                const SizedBox(height: 24),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Add your create group logic here
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
                            "Create Group",
                            style: TextStyle(
                              fontSize: 16,
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
    );
  }

  Widget _buildGroupTypeField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        value: _selectedType,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.category_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Select Group Type",
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: _groupType.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedType = newValue!;
          });
        },
      ),
    );
  }
}
