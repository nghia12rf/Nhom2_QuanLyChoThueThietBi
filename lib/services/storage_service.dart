// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final userJson = jsonEncode(user);
    await _prefs.setString(_userKey, userJson);
  }

  Map<String, dynamic>? getUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  bool isLoggedIn() {
    return _prefs.getString(_tokenKey) != null;
  }
}
