import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/screens/login_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/employee_dashboard_screen.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  runApp(const RentalApp());
}

class RentalApp extends StatelessWidget {
  const RentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Thiết Bị Cho Thuê',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const EmployeeDashboardScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
