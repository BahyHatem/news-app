import '../models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {

  final UserModel user;

  AuthAuthenticated(this.user);
}

class AuthRegistered extends AuthState {}

class AuthPasswordChanged extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

}
