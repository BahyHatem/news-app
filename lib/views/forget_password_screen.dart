import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import '../utils/validation_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}
enum ResetStep {
  enterEmail,
  securityQuestion,
  resetPassword,
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final securityAnswerController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  ResetStep _step = ResetStep.enterEmail;
  String? _securityQuestion;
  String? _userEmail;

  void _checkEmail() async {
    final email = emailController.text.trim();
    final user = await LocalAuthService().getUserByEmail(email);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Email not found")),
      );
      return;
    }

    setState(() {
      _userEmail = email;
      _securityQuestion = user.securityQuestion;
      _step = ResetStep.securityQuestion;
    });
  }

  void _checkAnswer() async {
  final answer = securityAnswerController.text.trim();
  final user = await LocalAuthService().verifySecurityAnswer(
    _userEmail!,
    answer,
  );

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(" Incorrect answer")),
    );
    return;
  }

  setState(() {
    _step = ResetStep.resetPassword;
  });
}
  void _resetPassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Passwords do not match")),
      );
      return;
    }

    final success = await LocalAuthService().updatePassword(
      email: _userEmail!,
      newPassword: newPasswordController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Password reset successfully")),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(" Failed to reset password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password",
      style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blueAccent,
      centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case ResetStep.enterEmail:
        return Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter your email"),
              validator: AuthValidator.validateEmail,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) _checkEmail();
              },
              child: Text("Continue"),
            ),
          ],
        );

      case ResetStep.securityQuestion:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Security Question:"),
            Text(" $_securityQuestion", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextFormField(
              controller: securityAnswerController,
              decoration: InputDecoration(labelText: "Your Answer"),
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) _checkAnswer();
              },
              child: Text("Verify Answer"),
            ),
          ],
        );

      case ResetStep.resetPassword:
        return Column(
          children: [
            TextFormField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: "New Password"),
              obscureText: true,
              validator: AuthValidator.validatePassword,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
              validator: (val) => val != newPasswordController.text ? "Passwords do not match" : null,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) _resetPassword();
              },
              child: Text("Reset Password"),
            ),
          ],
        );
    }
  }
}
