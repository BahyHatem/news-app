import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';

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
  DateTime? birthDate;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful ✅")),
      );
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
      setState(() {
        birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
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
              SizedBox(height: 10),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "Last Name"),
                validator: AuthValidator.validateName,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidator.validateEmail,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: AuthValidator.validatePassword,
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone (optional)"),
                keyboardType: TextInputType.phone,
                validator: AuthValidator.validatePhone,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(birthDate == null
                    ? "Select Date of Birth"
                    : "DB: ${birthDate!.toLocal().toString().split(' ')[0]}"),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickBirthDate,
              ),
              if (birthDate != null)
                Builder(
                  builder: (context) {
                    final result = AuthValidator.validateAge(birthDate);
                    return result != null
                        ? Text(result,
                            style: TextStyle(color: Colors.red, fontSize: 12))
                        : SizedBox.shrink();
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final birthError = AuthValidator.validateAge(birthDate);
                  if (birthError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(birthError)),
                    );
                    return;
                  }
                  _submitForm();
                },
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
