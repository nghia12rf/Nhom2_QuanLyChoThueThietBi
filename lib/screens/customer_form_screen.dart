import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';

class CustomerFormScreen extends StatefulWidget {
  final bool isEdit;
  final String? customerId;
  final Map<String, dynamic>? initialData;

  const CustomerFormScreen({
    super.key,
    this.isEdit = false,
    this.customerId,
    this.initialData,
  });

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Đổi tên controller để phản ánh đúng cả hai trường hợp cá nhân / công ty
  final TextEditingController _tenKhachHangController = TextEditingController();
  final TextEditingController _nguoiDaiDienController = TextEditingController();
  final TextEditingController _soDienThoaiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _maSoThueController = TextEditingController();
  final TextEditingController _diaChiController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.initialData != null) {
      final data = widget.initialData!;

      // ĐÃ SỬA: Map linh hoạt cả 'tenKhachHang' và 'tenCongTy' từ API tránh mất dữ liệu trên Form
      _tenKhachHangController.text = data['tenKhachHang'] ?? data['tenCongTy'] ?? '';
      _nguoiDaiDienController.text = data['nguoiDaiDien'] ?? '';
      _soDienThoaiController.text = data['soDienThoai'] ?? '';
      _emailController.text = data['email'] ?? '';
      _maSoThueController.text = data['maSoThue'] ?? '';
      _diaChiController.text = data['diaChi'] ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final body = {
        'MaDinhDanhKhachHang': widget.isEdit
            ? (widget.initialData?['maDinhDanhKhachHang'] ?? '')
            : "KH${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        'TenKhachHang': _tenKhachHangController.text.trim(),
        'NguoiDaiDien': _nguoiDaiDienController.text.trim(),
        'SoDienThoai': _soDienThoaiController.text.trim(),
        'Email': _emailController.text.trim(),
        // Nếu mã số thuế trống thì gửi null để Backend lưu dạng dữ liệu khách hàng cá nhân
        'MaSoThue': _maSoThueController.text.trim().isEmpty ? null : _maSoThueController.text.trim(),
        'DiaChi': _diaChiController.text.trim(),
      };

      if (widget.isEdit) {
        // ĐÃ SỬA (QUAN TRỌNG): Ép kiểu customerId từ String sang số int 
        // và đính kèm vào body với khóa 'MaKhachHang' để vượt qua bộ lọc kiểm tra của Backend
        final intId = int.tryParse(widget.customerId ?? '') ?? 0;
        body['MaKhachHang'] = intId;

        await ApiService().put(
          '/KhachHang/${widget.customerId}',
          body,
        );
      } else {
        await ApiService().post(
          '/KhachHang',
          body,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Cập nhật khách hàng thành công'
                : 'Tạo khách hàng thành công',
          ),
        ),
      );

      Navigator.pop(context, true);
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _tenKhachHangController.dispose();
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
        title: Text(
          widget.isEdit ? 'Chỉnh sửa khách hàng' : 'Thêm khách hàng mới',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(
                controller: _tenKhachHangController,
                label: 'Tên khách hàng / Tên công ty',
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _nguoiDaiDienController,
                label: 'Người đại diện',
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _soDienThoaiController,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _maSoThueController,
                label: 'Mã số thuế',
                isRequired: false, // Để trống nếu là khách hàng cá nhân tự do
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: _diaChiController,
                label: 'Địa chỉ',
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          widget.isEdit ? 'CẬP NHẬT' : 'LƯU THÔNG TIN',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Không được để trống';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
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