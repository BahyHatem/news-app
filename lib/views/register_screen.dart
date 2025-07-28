import 'package:flutter/material.dart';
import '../utils/validation_utils.dart';
import '../models/user_model.dart';
import '../services/local_auth_service.dart';

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

  bool isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final birthError = AuthValidator.validateAge(birthDate);
    if (birthError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(birthError)),
      );
      return;
    }

    setState(() => isLoading = true);

    final newUser = UserModel(
      id: '', 
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      passwordHash: passwordController.text.trim(), 
      phoneNumber: phoneController.text.trim(),
      dateOfBirth: birthDate  ?? DateTime(1900),
      salt: '', 
      createdAt: DateTime.now(), 
    );

    final success = await LocalAuthService().register(newUser);

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful ")),
      );
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email already exists")),
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
      setState(() => birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register"),
      centerTitle: true,
      backgroundColor: Colors.amber[100]),
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
                    : "DOB: ${birthDate!.toLocal().toString().split(' ')[0]}"),
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
