import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/models/user_account.dart';
import 'package:nhom2_quanlythietbichothue/services/user_account_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';

class UserAccountFormScreen extends StatefulWidget {
  final UserAccount? user;

  const UserAccountFormScreen({
    super.key,
    this.user,
  });

  bool get isEdit => user != null;

  @override
  State<UserAccountFormScreen> createState() => _UserAccountFormScreenState();
}

class _UserAccountFormScreenState extends State<UserAccountFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _hoTenController = TextEditingController();
  final _tenDangNhapController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _emailController = TextEditingController();

  String _vaiTro = 'Employee';
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      final user = widget.user!;
      _hoTenController.text = user.hoTen;
      _tenDangNhapController.text = user.tenDangNhap;
      _emailController.text = user.email ?? '';
      _vaiTro = user.vaiTro;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.isEdit) {
        await UserAccountService().updateUser(
          maNguoiDung: widget.user!.maNguoiDung,
          hoTen: _hoTenController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          vaiTro: _vaiTro,
        );
      } else {
        await UserAccountService().createUser(
          tenDangNhap: _tenDangNhapController.text.trim(),
          matKhau: _matKhauController.text.trim(),
          hoTen: _hoTenController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          vaiTro: _vaiTro,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Cập nhật tài khoản thành công'
                : 'Tạo tài khoản thành công',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _tenDangNhapController.dispose();
    _matKhauController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa tài khoản' : 'Thêm tài khoản'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(
                    isEdit ? Icons.edit : Icons.person_add_alt_1,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hoTenController,
                    decoration: _inputDecoration('Họ tên', Icons.person),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tenDangNhapController,
                    enabled: !isEdit,
                    decoration: _inputDecoration(
                      'Tên đăng nhập',
                      Icons.account_circle,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      if (value.trim().length < 3) {
                        return 'Tên đăng nhập ít nhất 3 ký tự';
                      }
                      return null;
                    },
                  ),
                  if (!isEdit) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _matKhauController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('Mật khẩu', Icons.lock)
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      'Email',
                      Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _vaiTro,
                    decoration: _inputDecoration(
                      'Vai trò',
                      Icons.admin_panel_settings,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Employee',
                        child: Text('Nhân viên'),
                      ),
                      DropdownMenuItem(
                        value: 'Admin',
                        child: Text('Quản trị viên'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _vaiTro = value ?? 'Employee';
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(isEdit ? Icons.save : Icons.person_add),
                    label: Text(
                      _isSaving
                          ? 'Đang lưu...'
                          : isEdit
                              ? 'Lưu thay đổi'
                              : 'Tạo tài khoản',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}