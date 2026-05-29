import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/widgets/common_widgets.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';

// Import các màn hình cần thiết
import 'package:nhom2_quanlythietbichothue/screens/employee_dashboard_screen.dart'
    hide
        RentalListScreen; // EquipmentListScreen, CustomerListScreen được dùng lại
import 'package:nhom2_quanlythietbichothue/screens/rental_list_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/equipment_form_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/customer_form_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/contract_form_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/statistics_report_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/damage_report_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/maintenance_management_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/contract_extension_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, int>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _fetchSummaryData();
  }

  /// Lấy dữ liệu tổng quan từ API
  Future<Map<String, int>> _fetchSummaryData() async {
    try {
      final equipments = await ApiService().get('/ThietBi');
      final contracts = await ApiService().get('/HopDong');
      final customers = await ApiService().get('/KhachHang');

      int totalEquip = (equipments is List) ? equipments.length : 0;
      int totalContracts = (contracts is List) ? contracts.length : 0;
      int totalCustomers = (customers is List) ? customers.length : 0;

      int maintenanceCount = 0;
      if (equipments is List) {
        maintenanceCount = equipments
            .where((e) => e['trangThai'] == 'BaoTri')
            .length;
      }

      return {
        'equipments': totalEquip,
        'contracts': totalContracts,
        'maintenance': maintenanceCount,
        'customers': totalCustomers,
      };
    } catch (e) {
      return {
        'equipments': 0,
        'contracts': 0,
        'maintenance': 0,
        'customers': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Quản Trị Hệ Thống'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Badge(
                label: const Text('3'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications_none),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildAdminDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 1200
              ? 4
              : (constraints.maxWidth > 800 ? 3 : 2);
          double horizontalPadding = constraints.maxWidth > 1000
              ? (constraints.maxWidth - 1000) / 2
              : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng quan dữ liệu',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, int>>(
                  future: _summaryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data =
                        snapshot.data ??
                        {
                          'equipments': 0,
                          'contracts': 0,
                          'maintenance': 0,
                          'customers': 0,
                        };

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        InfoCard(
                          label: 'Tổng thiết bị',
                          value: data['equipments'].toString(),
                          icon: Icons.inventory_2_outlined,
                          backgroundColor: AppTheme.accentColor,
                        ),
                        InfoCard(
                          label: 'Hợp đồng',
                          value: data['contracts'].toString(),
                          icon: Icons.assignment_turned_in_outlined,
                          backgroundColor: AppTheme.warningColor,
                        ),
                        InfoCard(
                          label: 'Đang bảo trì',
                          value: data['maintenance'].toString(),
                          icon: Icons.warning_amber_rounded,
                          backgroundColor: AppTheme.errorColor,
                        ),
                        InfoCard(
                          label: 'Khách hàng',
                          value: data['customers'].toString(),
                          icon: Icons.business_outlined,
                          backgroundColor: AppTheme.successColor,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Tác vụ quản lý nhanh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActionsGrid(context, constraints),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Lưới các nút chức năng
  Widget _buildQuickActionsGrid(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildQuickActionButton(
          context,
          'Tạo hợp đồng',
          Icons.description_outlined,
          AppTheme.infoColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContractFormScreen()),
          ),
        ),
        _buildQuickActionButton(
          context,
          'Thêm thiết bị',
          Icons.add_box_outlined,
          AppTheme.accentColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EquipmentFormScreen(isEdit: false),
            ),
          ),
        ),
        _buildQuickActionButton(
          context,
          'Thêm khách hàng',
          Icons.person_add_outlined,
          AppTheme.successColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CustomerFormScreen()),
          ),
        ),
        _buildQuickActionButton(
          context,
          'Báo cáo',
          Icons.bar_chart_outlined,
          AppTheme.warningColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StatisticsReportScreen(),
            ),
          ),
        ),
        _buildQuickActionButton(
          context,
          'Báo hỏng',
          Icons.report_problem_outlined,
          AppTheme.errorColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DamageReportScreen()),
          ),
        ),
        _buildQuickActionButton(
          context,
          'Bảo trì',
          Icons.home_repair_service_outlined,
          AppTheme.infoColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MaintenanceManagementScreen(),
            ),
          ),
        ),
        _buildQuickActionButton(
          context,
          'Gia hạn HĐ',
          Icons.event_repeat_outlined,
          AppTheme.successColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ContractExtensionScreen(canApprove: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radiusMedium,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.radiusMedium,
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [AppTheme.shadowSmall],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  /// Drawer điều hướng của Admin
  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
            child: DrawerHeader(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'QUẢN TRỊ VIÊN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  Icons.inventory_2_outlined,
                  'Quản lý thiết bị',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Danh sách thiết bị')),
                        body: const EquipmentListScreen(),
                      ),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  Icons.people_alt_outlined,
                  'Quản lý khách hàng',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Danh sách khách hàng'),
                        ),
                        body: const CustomerListScreen(),
                      ),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  Icons.assignment_outlined,
                  'Quản lý hợp đồng',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('Danh sách hợp đồng')),
                        body: const RentalListScreen(),
                      ),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  Icons.report_problem_outlined,
                  'Báo cáo hỏng hóc',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DamageReportScreen(),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  Icons.home_repair_service_outlined,
                  'Quản lý bảo trì',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MaintenanceManagementScreen(),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  Icons.event_repeat_outlined,
                  'Gia hạn hợp đồng',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ContractExtensionScreen(canApprove: true),
                    ),
                  ),
                ),
                const Divider(height: 16, indent: 16, endIndent: 16),
                _buildDrawerItem(
                  context,
                  Icons.analytics_outlined,
                  'Báo cáo thống kê',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsReportScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            Icons.logout,
            'Đăng xuất',
            () => Navigator.pushReplacementNamed(context, '/login'),
            isLogout: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    final color = isLogout ? AppTheme.errorColor : AppTheme.primaryColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
