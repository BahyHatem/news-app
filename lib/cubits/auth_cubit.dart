import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';
import '../services/local_auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalAuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  
  Future<void> login(String email, String password, bool rememberMe) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError("Invalid email or password"));
      }
    } catch (e) {
      emit(AuthError("Login failed: ${e.toString()}"));
    }
  }

  Future<void> register(UserModel user) async {
    emit(AuthLoading());
    try {
      final result = await _authService.register(user);
      if (result) {
        emit(AuthRegistered());
      } else {
        emit(AuthError("User already exists"));
      }
    } catch (e) {
      emit(AuthError("Registration failed: ${e.toString()}"));
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      final result = await _authService.updateProfile(updatedUser);
      if (result) {
        emit(AuthAuthenticated(updatedUser));
      } else {
        emit(AuthError("Failed to update profile"));
      }
    } catch (e) {
      emit(AuthError("Profile update failed: ${e.toString()}"));
    }
  }

  Future<void> loadSecurityQuestion(String email) async {
    emit(AuthLoading());
    try {
      final question = await _authService.getSecurityQuestion(email);
      if (question != null) {
        emit(AuthSecurityQuestionLoaded(question, email));
      } else {
        emit(AuthError("Email not found"));
      }
    } catch (e) {
      emit(AuthError("Failed to load security question: ${e.toString()}"));
    }
  }

  Future<void> verifySecurityAnswer(String email, String answer) async {
    emit(AuthLoading());
    try {
      final user = await _authService.verifySecurityAnswer(email, answer);
      if (user != null) {
        emit(AuthSecurityQuestionVerified(user));
      } else {
        emit(AuthError("Incorrect answer"));
      }
    } catch (e) {
      emit(AuthError("Verification failed: ${e.toString()}"));
    }
  } 
  }
