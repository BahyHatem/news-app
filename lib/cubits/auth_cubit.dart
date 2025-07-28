import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(String email, String password, bool rememberMe) async {
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 1));
    if (email == "bahy@example.com" && password == "12345678") {
      final user = UserModel(
        id: '1',
        firstName: 'bahy',
        lastName: 'hatem',
        email: email,
        passwordHash: 'hashed_password',
        createdAt: DateTime.now(),
      );

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', user.email);
      }

      emit(AuthAuthenticated(user));
    } else {
      emit(AuthError("Invalid email or password."));
    }
  }

  Future<void> register(UserModel newUser) async {
    emit(AuthLoading());

    await Future.delayed(Duration(seconds: 1));
    emit(AuthAuthenticated(newUser));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');

    if (savedEmail != null) {
      final user = UserModel(
        id: '1',
        firstName: 'bahy',
        lastName: 'hatem',
        email: savedEmail,
        passwordHash: 'hashed_password',
        createdAt: DateTime.now(),
      );
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthInitial());
    }
  }

  void validateForm(Map<String, String> formData) {
    if (formData['email'] == null || !formData['email']!.contains('@')) {
      emit(AuthFormInvalid("Invalid email format"));
      return;
    }
    if (formData['password'] == null || formData['password']!.length < 8) {
      emit(AuthFormInvalid("Password too short"));
      return;
    }
    emit(AuthFormValid());
  }

  void updateProfile(UserModel updatedUser) {
    emit(AuthAuthenticated(updatedUser)); 
  }

  void changePassword(String oldPass, String newPass) {
    if (oldPass == newPass) {
      emit(AuthError("New password must be different"));
    } else if (newPass.length < 6) {
      emit(AuthError("New password too short"));
    } else {
      emit(AuthPasswordChanged());
    }
  }
}
