import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class LocalAuthService {
  static const usersKey = 'users_list';
  static const currentUserIdKey = 'current_user_id';
  static const rememberMeKey = 'remember_me';
  static const sessionKey = 'user_session';
  final Map<String, UserModel> _users = {}; 
  UserModel? _currentUser;


  final _uuid = const Uuid();

  String generateSalt([int length = 16]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  Future<List<UserModel>> _getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(usersKey) ?? [];
    return jsonList.map((jsonUser) => UserModel.fromJson(json.decode(jsonUser))).toList();
  }

  Future<void> _saveAllUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = users.map((user) => json.encode(user.toJson())).toList();
    await prefs.setStringList(usersKey, jsonList);
  }

  Future<bool> register(UserModel user) async {
    final users = await _getAllUsers();
    if (users.any((u) => u.email == user.email)) return false;

    final salt = generateSalt();
    final hashedPassword = hashPassword(user.passwordHash, salt);

    final newUser = user.copyWith(
      id: _uuid.v4(),
      salt: salt,
      passwordHash: hashedPassword,
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    await _saveAllUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currentUserIdKey, newUser.id);
    await prefs.setString(sessionKey, DateTime.now().toIso8601String());

    return true;
  }

  Future<UserModel?> login(String email, String password, {bool rememberMe = false}) async {
    final users = await _getAllUsers();
    final user = users.where((u) => u.email == email).isNotEmpty
        ? users.firstWhere((u) => u.email == email)
        : null;

    if (user == null) return null;

    final hashedInput = hashPassword(password, user.salt);
    if (hashedInput != user.passwordHash) return null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currentUserIdKey, user.id);
    await prefs.setBool(rememberMeKey, rememberMe);
    await prefs.setString(sessionKey, DateTime.now().toIso8601String());

    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentUserIdKey);
    await prefs.remove(sessionKey);
    await prefs.setBool(rememberMeKey, false);
  }

  Future<bool> isUserExists(String email) async {
    final users = await _getAllUsers();
    return users.any((u) => u.email == email);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final users = await _getAllUsers();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }
  Future<String?> getSecurityQuestion(String email) async {
    final user = await getUserByEmail(email);
  return user?.securityQuestion;
  }
  Future<UserModel?> verifySecurityAnswer(String email, String answer) async {
  final user = await getUserByEmail(email);
  if (user == null) return null;

  if (user.securityAnswer.toLowerCase().trim() == answer.toLowerCase().trim()) {
    return user;
  }
  return null;
}

  Future<bool> updatePassword({
  required String email,
  required String newPassword,
}) async {
  final users = await _getAllUsers();
  final index = users.indexWhere((u) => u.email == email);
  if (index == -1) return false;

  final updatedUser = users[index].copyWith(
    passwordHash: hashPassword(newPassword, users[index].salt),
  );
  users[index] = updatedUser;
  await _saveAllUsers(users);
  return true;
}
  

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(currentUserIdKey);
    if (userId == null) return null;

    final users = await _getAllUsers();
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    final users = await _getAllUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index == -1) return false;

    users[index] = updatedUser;
    await _saveAllUsers(users);
    return true;
  }

  Future<bool> changePassword(String userId, String oldPass, String newPass) async {
    final users = await _getAllUsers();
    final index = users.indexWhere((u) => u.id == userId);
    if (index == -1) return false;

    final user = users[index];
    final oldHash = hashPassword(oldPass, user.salt);

    if (user.passwordHash != oldHash) return false;

    final newSalt = generateSalt();
    final newHash = hashPassword(newPass, newSalt);

    users[index] = user.copyWith(
      passwordHash: newHash,
      salt: newSalt,
    );

    await _saveAllUsers(users);
    return true;
  }

  Future<bool> resetPasswordWithSecurityAnswer({
    required String email,
    required String answer,
    required String newPassword,
  }) async {
    final users = await _getAllUsers();
    final index = users.indexWhere((u) => u.email == email);
    if (index == -1) return false;

    final user = users[index];
    if (user.securityAnswer.trim().toLowerCase() != answer.trim().toLowerCase()) {
      return false;
    }

    final newSalt = generateSalt();
    final newHash = hashPassword(newPassword, newSalt);

    users[index] = user.copyWith(
      salt: newSalt,
      passwordHash: newHash,
    );

    await _saveAllUsers(users);
    return true;
  }

  Future<bool> isRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(rememberMeKey) ?? false;
  }

  Future<bool> isSessionActive({Duration timeout = const Duration(hours: 1)}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginStr = prefs.getString(sessionKey);
    if (lastLoginStr == null) return false;

    final lastLogin = DateTime.parse(lastLoginStr);
    return DateTime.now().difference(lastLogin) < timeout;
  }
}
