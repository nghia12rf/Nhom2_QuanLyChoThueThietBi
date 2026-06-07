import 'package:nhom2_quanlythietbichothue/services/api_service.dart';

class ThongKeService {
  final ApiService _apiService = ApiService();

  Future<dynamic> getTonKho() async {
    try {
      return await _apiService.get('/ThongKe/TonKho');
    } catch (e) {
      throw Exception('Error getting ton kho: $e');
    }
  }

  Future<dynamic> getHieuSuat() async {
    try {
      return await _apiService.get('/ThongKe/HieuSuat');
    } catch (e) {
      throw Exception('Error getting hieu suat: $e');
    }
  }

  Future<dynamic> getSuCo() async {
    try {
      return await _apiService.get('/ThongKe/SuCo');
    } catch (e) {
      throw Exception('Error getting su co: $e');
    }
  }
}
