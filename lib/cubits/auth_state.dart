

import '../models/user_model.dart';
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthFormValid extends AuthState {}

class AuthFormInvalid extends AuthState {
  final String message;

  AuthFormInvalid(this.message);
}

class AuthPasswordChanged extends AuthState {}
