import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';
import '../models/user_model.dart';
import '../views/login_screen.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final _authService = LocalAuthService();
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    setState(() => _user = user);
  }

  bool _isStrongPassword(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await _authService.changePassword(
      _user!.id,
      _oldPassCtrl.text.trim(),
      _newPassCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      await _authService.logout(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully. Please log in again.")),
        );
        Navigator.of(context).pop(); 
      }
    } else {
      setState(() {
        _error = "Current password is incorrect.";
      });
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action is irreversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true || _user == null) return;

    final passOk = await _showPasswordCheckDialog();
    if (!passOk) return;

    final deleted = await _authService.deleteAccount(_user!.id);
    if (deleted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );
       if (deleted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Account deleted successfully.")),
  );

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

      }
    }
  }

  Future<bool> _showPasswordCheckDialog() async {
    final passCtrl = TextEditingController();
    bool isVerified = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter your password to continue."),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final ok = _authService.verifyPassword(
                passCtrl.text,
                _user!.passwordHash,
                _user!.salt,
              );
              if (ok) {
                isVerified = true;
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect password.")),
                );
              }
            },
            child: const Text("Verify"),
          )
        ],
      ),
    );

    return isVerified;
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Security Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _user == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                      TextFormField(
                        controller: _oldPassCtrl,
                        decoration: const InputDecoration(labelText: "Current Password"),
                        obscureText: true,
                        validator: (val) => val!.isEmpty ? "Enter current password" : null,
                      ),
                      TextFormField(
                        controller: _newPassCtrl,
                        decoration: const InputDecoration(labelText: "New Password"),
                        obscureText: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Enter new password";
                          if (!_isStrongPassword(val)) return "Password must be strong (8+ chars, upper/lower/digit/symbol)";
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _confirmPassCtrl,
                        decoration: const InputDecoration(labelText: "Confirm New Password"),
                        obscureText: true,
                        validator: (val) =>
                            val != _newPassCtrl.text ? "Passwords do not match" : null,
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _handleChangePassword,
                              child: const Text("Change Password"),
                            ),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _handleDeleteAccount,
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete Account"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
