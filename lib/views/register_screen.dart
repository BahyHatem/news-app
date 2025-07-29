import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';
import '../models/user_model.dart';
import '../services/local_auth_service.dart';
import '../views/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final securityAnswerController = TextEditingController();
  DateTime? birthDate;

  String? selectedSecurityQuestion;
  bool isLoading = false;

  final List<String> securityQuestions = [
    "What's your mother's maiden name?",
    "What was your first pet's name?",
    "What city were you born in?",
  ];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _focusFirstInvalidField();
      return;
    }

    final birthError = AuthValidator.validateAge(birthDate);
    if (birthError != null) {
      _showSnackBar(birthError, isError: true);
      return;
    }

    if (selectedSecurityQuestion == null) {
      _showSnackBar("Please select a security question", isError: true);
      return;
    }

    if (securityAnswerController.text.trim().isEmpty) {
      _showSnackBar("Please provide an answer to your security question", isError: true);
      return;
    }

    setState(() => isLoading = true);

    // 🔐 Generate salt and hash password
    final authService = LocalAuthService();
final salt = authService.generateSalt();
final hashedPassword = authService.hashPassword(passwordController.text.trim(), salt);

    final newUser = UserModel(
      id: '',
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      passwordHash: hashedPassword,
      phoneNumber: phoneController.text.trim(),
      dateOfBirth: birthDate ?? DateTime(1900),
      salt: salt,
      createdAt: DateTime.now(),
      securityQuestion: selectedSecurityQuestion!,
      securityAnswer: securityAnswerController.text.trim(),
    );

    final success = await LocalAuthService().register(newUser);

    setState(() => isLoading = false);

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Success"),
          content: Text("Registration completed successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      _showSnackBar("Email already exists", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _focusFirstInvalidField() {
    final fields = [
      firstNameController,
      lastNameController,
      emailController,
      passwordController,
      confirmPasswordController,
    ];
    for (final controller in fields) {
      if (controller.text.trim().isEmpty) {
        FocusScope.of(context).requestFocus(FocusNode());
        break;
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: "First Name"),
                validator: AuthValidator.validateName,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
                validator: AuthValidator.validateName,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidator.validateEmail,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: AuthValidator.validatePassword,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
                validator: (value) {
                  if (value != passwordController.text) {
                    return "Passwords do not match.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone (optional)"),
                keyboardType: TextInputType.phone,
                validator: AuthValidator.validatePhone,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(birthDate == null
                    ? "Select Date of Birth"
                    : "DOB: ${birthDate!.toLocal().toString().split(' ')[0]}"),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickBirthDate,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSecurityQuestion,
                decoration: InputDecoration(labelText: "Security Question"),
                items: securityQuestions
                    .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                    .toList(),
                onChanged: (value) => setState(() => selectedSecurityQuestion = value),
                validator: (value) =>
                    value == null ? "Please select a question" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: securityAnswerController,
                decoration: InputDecoration(labelText: "Answer"),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Enter your answer" : null,
              ),
              SizedBox(height: 24),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text("Register"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
