// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:nhom2_quanlythietbichothue/models/user.dart';
import 'package:nhom2_quanlythietbichothue/utils/constants.dart';

class AuthService {
  Future<LoginResponse?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tenDangNhap': username, 'matKhau': password}),
      );

      debugPrint('Login status: ${response.statusCode}');
      debugPrint('Login body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else {
        String errorMessage = 'Đăng nhập thất bại';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        debugPrint(errorMessage);
        return null;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }
}
