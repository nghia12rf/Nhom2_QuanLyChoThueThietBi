// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import './storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final StorageService _storage = StorageService();

  factory ApiService() => _instance;

  ApiService._internal();

  /// HÀM QUAN TRỌNG: Lấy Header kèm Token một cách bất đồng bộ
  Future<Map<String, String>> _getHeaders() async {
    // Đảm bảo StorageService đã được khởi tạo để đọc file từ bộ nhớ máy
    await _storage.init();
    final token = _storage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Phải có chữ 'Bearer ' phía trước token để tránh lỗi 401
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Lấy Header cho việc upload file (Multipart)
  Future<Map<String, String>> _getMultipartHeaders() async {
    await _storage.init();
    final token = _storage.getToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ================= GET =================
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối (GET): $e');
    }
  }

  // ================= POST =================
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối (POST): $e');
    }
  }

  // ================= PUT =================
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối (PUT): $e');
    }
  }

  // ================= DELETE =================
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi kết nối (DELETE): $e');
    }
  }

  // ================= UPLOAD IMAGE =================
  Future<String> uploadImage(String filePath) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/Upload/image');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(await _getMultipartHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = _handleResponse(response);
      return data['imageUrl'] ?? data['url'] ?? '';
    } catch (e) {
      throw Exception('Lỗi tải ảnh: $e');
    }
  }

  /// Hàm xử lý tập trung tất cả các Status Code từ Server
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 204:
        return null;
      case 400:
        // Lỗi dữ liệu không hợp lệ (Key mismatch Nghĩa gặp lúc nãy)
        throw Exception('Dữ liệu gửi lên không hợp lệ (400): ${response.body}');
      case 401:
        // Lỗi chưa đăng nhập hoặc token sai
        throw Exception(
          'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại (401)',
        );
      case 403:
        throw Exception('Bạn không có quyền thực hiện chức năng này (403)');
      case 500:
        throw Exception(
          'Lỗi hệ thống Backend (500). Nghĩa hãy kiểm tra Visual Studio Output!',
        );
      default:
        throw Exception('Lỗi không xác định: ${response.statusCode}');
    }
  }
}
