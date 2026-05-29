import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/screens/admin_dashboard_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/employee_dashboard_screen.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/services/auth_service.dart';
import 'package:nhom2_quanlythietbichothue/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _fadeAnimationController.forward();
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Kiểm tra đầu vào
    if (username.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Vui lòng nhập tên đăng nhập và mật khẩu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Gọi AuthService - Trả về LoginResponse định dạng "phẳng"
      final response = await AuthService().login(username, password);

      if (!mounted) return;

      if (response != null) {
        final storage = StorageService();
        await storage.init();

        // 3. Lưu Token
        await storage.saveToken(response.token);

        // 4. Lưu thông tin người dùng (Lấy trực tiếp từ response)
        final userData = {
          'tenDangNhap': response.tenDangNhap,
          'hoTen': response.hoTen,
          'vaiTro': response.vaiTro,
        };
        await storage.saveUser(userData);

        // 5. Điều hướng dựa trên vaiTro (Admin hoặc Employee)
        if (response.vaiTro == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EmployeeDashboardScreen()),
          );
        }
      } else {
        _showErrorSnackbar('Tên đăng nhập hoặc mật khẩu không đúng');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Lỗi kết nối Server: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [AppTheme.shadowLarge],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Quản Lý Thiết Bị',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cho Thuê',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFFB8E0F3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Form Fields
                  Text(
                    'Đăng nhập',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),

                  // Username Field
                  TextField(
                    enabled: !_isLoading,
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Tên đăng nhập',
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: 'Nhập tên đăng nhập',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    enabled: !_isLoading,
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _isObscure = !_isObscure),
                      ),
                      hintText: 'Nhập mật khẩu',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _login,
                    icon: _isLoading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.8),
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.login),
                    label: Text(
                      _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Demo Credentials
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tài khoản Demo',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCredentialRow('Admin:', 'admin / admin'),
                        const SizedBox(height: 8),
                        _buildCredentialRow(
                          'Nhân viên:',
                          'employee / employee',
                        ),
                      ],
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

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
