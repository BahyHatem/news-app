import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditableProfileScreen extends StatefulWidget {
  const EditableProfileScreen({super.key});

  @override
  State<EditableProfileScreen> createState() => _EditableProfileScreenState();
}

class _EditableProfileScreenState extends State<EditableProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController(text: "Bahy");
  final _lastNameController = TextEditingController(text: "Hatem");
  final _phoneController = TextEditingController(text: "01234567890");
  final _emailController = TextEditingController(text: "bahy@example.com");

  DateTime? _selectedDate;
  File? _image;
  final picker = ImagePicker();

  final Set<String> _usedEmails = {"test@example.com", "bahy@example.com"}; // fake check

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final fileSize = await file.length();

      if (fileSize > 2 * 1024 * 1024) {
        // أكبر من 2MB
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image must be under 2MB")),
        );
        return;
      }

      setState(() => _image = file);
    }
  }

  void _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  bool _isValidPhone(String phone) {
    final pattern = RegExp(r'^01[0-2,5][0-9]{8}$'); // مصري
    return pattern.hasMatch(phone);
  }

  bool _isEmailUnique(String email) {
    return !_usedEmails.contains(email.toLowerCase());
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : "Select Date";

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : const AssetImage("assets/default_avatar.png") as ImageProvider,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: _pickImage,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(labelText: "First Name"),
                          validator: (value) => value!.isEmpty ? "Enter first name" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(labelText: "Last Name"),
                          validator: (value) => value!.isEmpty ? "Enter last name" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains("@")) {
                        return "Enter a valid email";
                      }
                      if (!_isEmailUnique(value)) {
                        return "Email already in use";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: "Phone Number"),
                    keyboardType: TextInputType.phone,
                    validator: (value) => _isValidPhone(value ?? "") ? null : "Invalid phone format",
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: "Date of Birth"),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formattedDate),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text("Save"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
