import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/models/user_account.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:intl/intl.dart';

class UserAccountDetailScreen extends StatelessWidget {
  final UserAccount user;

  const UserAccountDetailScreen({super.key, required this.user});

  String _roleText(String role) {
    return role == 'Admin' ? 'Quản trị viên' : 'Nhân viên';
  }

  String _statusText(bool status) {
    return status ? 'Hoạt động' : 'Ngừng hoạt động';
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return 'Không có dữ liệu';
    }

    try {
      final dt = DateTime.parse(dateTime);

      return DateFormat('dd/MM/yyyy | HH:mm:ss').format(dt);
    } catch (_) {
      return dateTime;
    }
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(label),
        subtitle: Text(
          value.isEmpty ? 'Chưa cập nhật' : value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = user.trangThaiHoatDong;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Chi tiết tài khoản'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: isActive
                        ? AppTheme.successColor.withOpacity(0.12)
                        : AppTheme.errorColor.withOpacity(0.12),
                    child: Icon(
                      user.vaiTro == 'Admin'
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      size: 42,
                      color: user.vaiTro == 'Admin'
                          ? AppTheme.primaryColor
                          : isActive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.hoTen,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('@${user.tenDangNhap}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _infoTile('Họ tên', user.hoTen, Icons.person),
          _infoTile('Tên đăng nhập', user.tenDangNhap, Icons.account_circle),
          _infoTile('Email', user.email ?? '', Icons.email_outlined),
          _infoTile('Vai trò', _roleText(user.vaiTro), Icons.badge_outlined),
          _infoTile(
            'Trạng thái',
            _statusText(user.trangThaiHoatDong),
            Icons.verified_user_outlined,
          ),
          _infoTile(
            'Ngày tạo',
            formatDateTime(user.ngayTao),
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }
}
