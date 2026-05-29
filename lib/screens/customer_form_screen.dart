import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers - Nghĩa nhớ khai báo đủ như trong hình chụp nhé
  final TextEditingController _tenCongTyController = TextEditingController();
  final TextEditingController _nguoiDaiDienController = TextEditingController();
  final TextEditingController _soDienThoaiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Mới
  final TextEditingController _maSoThueController =
      TextEditingController(); // Mới
  final TextEditingController _diaChiController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final body = {
        // 1. Phải có MaDinhDanhKhachHang vì CSDL để NOT NULL
        'MaDinhDanhKhachHang':
            "KH${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",

        // 2. Tên trường phải viết hoa chữ T theo đúng lỗi Backend báo (TenKhachHang)
        'TenKhachHang': _tenCongTyController.text.trim(),

        'NguoiDaiDien': _nguoiDaiDienController.text.trim(),
        'SoDienThoai': _soDienThoaiController.text.trim(),
        'Email': _emailController.text.trim(),
        'MaSoThue': _maSoThueController.text.trim(),
        'DiaChi': _diaChiController.text.trim(),
      };

      await ApiService().post('/KhachHang', body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Tạo khách hàng thành công')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _tenCongTyController.dispose();
    _nguoiDaiDienController.dispose();
    _soDienThoaiController.dispose();
    _emailController.dispose();
    _maSoThueController.dispose();
    _diaChiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Thêm Khách Hàng Mới'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(
                controller: _tenCongTyController,
                label: 'Tên công ty / Đơn vị thuê',
                icon: Icons.business,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _nguoiDaiDienController,
                label: 'Người đại diện',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _soDienThoaiController,
                label: 'Số điện thoại',
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _emailController,
                label: 'Email liên hệ',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _maSoThueController,
                label: 'Mã số thuế (nếu có)',
                icon: Icons.fact_check_outlined,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _diaChiController,
                label: 'Địa chỉ bàn giao thiết bị',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'LƯU THÔNG TIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Không được để trống';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
