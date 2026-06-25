import 'package:nhom2_quanlythietbichothue/models/user_account.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';

class UserAccountService {
  final ApiService _api = ApiService();

  Future<List<UserAccount>> getUsers() async {
    final data = await _api.get('/NguoiDung');

    final List list = data is List ? data : data['data'] ?? [];

    return list
        .map((e) => UserAccount.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createUser({
    required String tenDangNhap,
    required String matKhau,
    required String hoTen,
    String? email,
    required String vaiTro,
  }) async {
    await _api.post('/NguoiDung', {
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
      'hoTen': hoTen,
      'email': email,
      'vaiTro': vaiTro,
    });
  }

  Future<void> updateStatus({
    required int maNguoiDung,
    required bool trangThaiHoatDong,
  }) async {
    await _api.put('/NguoiDung/$maNguoiDung/TrangThai', {
      'trangThaiHoatDong': trangThaiHoatDong,
    });
  }

  Future<void> updateUser({
    required int maNguoiDung,
    required String hoTen,
    String? email,
    required String vaiTro,
  }) async {
    await _api.put('/NguoiDung/$maNguoiDung', {
      'hoTen': hoTen,
      'email': email,
      'vaiTro': vaiTro,
    });
  }

  Future<void> resetPassword({
    required int maNguoiDung,
    required String matKhauMoi,
  }) async {
    await _api.put('/NguoiDung/$maNguoiDung/ResetMatKhau', {
      'matKhauMoi': matKhauMoi,
    });
  }
}
