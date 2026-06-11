import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/screens/equipment_detail_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/camera_screen.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/models/equipment.dart';
import 'package:nhom2_quanlythietbichothue/screens/contract_form_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/phieu_thu_hoi_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/damage_report_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/contract_extension_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/customer_form_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/customer_detail_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/recall_history_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/payment_return_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/rental_list_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const EquipmentListScreen(),
    const RentalListScreen(),
    const CustomerListScreen(),
  ];
  // Hàm xử lý kết quả quét mã (hoặc nhập ID giả lập)
  // Trong class _EmployeeDashboardScreenState của employee_dashboard_screen.dart
  Future<void> _handleScanResult(String scannedId) async {
    try {
      Map<String, dynamic>? equipment;
      // 1. Tìm theo mã định danh/serial trước qua ByCode
      try {
        final data = await ApiService().get(
          '/ThietBi/ByCode/${scannedId.trim()}',
        );
        if (data is Map<String, dynamic>) {
          equipment = data;
        }
      } catch (e) {
        // Nếu không tìm thấy, và scannedId là số thì tìm theo ID gốc (maThietBi)
        if (RegExp(r'^\d+$').hasMatch(scannedId.trim())) {
          final data = await ApiService().get('/ThietBi/${scannedId.trim()}');
          if (data is Map<String, dynamic>) {
            equipment = data;
          }
        }
      }

      if (equipment == null) {
        _showWarning('Không tìm thấy thiết bị mã $scannedId');
        return;
      }

      if (!mounted) return;

      final String status = equipment['trangThai'] ?? '';

      if (status == 'SanSang') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ContractFormScreen(preSelectedEquipment: equipment),
          ),
        );
      }
      // 🔥 CẬP NHẬT: Nếu máy đang thuê, nhảy sang màn hình thu hồi
      else if (status == 'DangChoThue') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhieuThuHoiScreen(equipment: equipment!),
          ),
        );
      } else if (status == 'BaoTri') {
        _showWarning('⚠️ Thiết bị đang bảo trì!');
      }
    } catch (e) {
      _showWarning('Không tìm thấy thiết bị mã $scannedId');
    }
  }

  // Hàm hỗ trợ hiện thông báo nhanh
  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hiện Trường'),
        centerTitle: true,
        // Drawer sẽ tự động thêm icon menu (ba gạch) ở góc trái AppBar
      ),
      // 1. BỔ SUNG DRAWER TẠI ĐÂY
      drawer: _buildEmployeeDrawer(context),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 3
          ? null // Ẩn nút Quét QR trên tab Khách hàng để tránh hiển thị 2 nút (Nút thêm khách và quét QR)
          : FloatingActionButton(
              onPressed: () async {
                // 1. Thay vì mở Camera, mình hiện một cái Dialog nhập ID máy
                String? debugId = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    TextEditingController dbgCtrl = TextEditingController();
                    return AlertDialog(
                      title: const Text('Giả lập Quét QR (Debug Mode)'),
                      content: TextField(
                        controller: dbgCtrl,
                        decoration: const InputDecoration(
                          hintText: "Nhập ID thiết bị (VD: 14, 15...)",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, dbgCtrl.text),
                          child: const Text('Xong'),
                        ),
                      ],
                    );
                  },
                );

                // 2. Sau khi nhập ID, chạy logic kiểm tra trạng thái y hệt như đã quét thật
                if (debugId != null && debugId.isNotEmpty) {
                  _handleScanResult(debugId);
                }
              },
              child: const Icon(Icons.qr_code_scanner),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        // Giữ màu sắc đồng nhất với theme
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Thiết bị',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Hợp đồng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Khách hàng',
          ),
        ],
      ),
    );
  }

  /// 2. HÀM XÂY DỰNG DRAWER CHO NHÂN VIÊN
  Widget _buildEmployeeDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header hiển thị thông tin nhân viên
          Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
            child: DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 45, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'NHÂN VIÊN HIỆN TRƯỜNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Các mục điều hướng nhanh
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.qr_code_scanner, 'Quét mã thiết bị', () {
                  Navigator.pop(context); // Đóng drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  );
                }),
                _drawerItem(Icons.history, 'Lịch sử thu hồi', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecallHistoryScreen(),
                    ),
                  );
                }),
                _drawerItem(
                  Icons.report_problem_outlined,
                  'Báo cáo hỏng hóc',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DamageReportScreen(),
                      ),
                    );
                  },
                ),
                _drawerItem(Icons.event_repeat_outlined, 'Yêu cầu gia hạn', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContractExtensionScreen(),
                    ),
                  );
                }),
                _drawerItem(Icons.help_outline, 'Hướng dẫn sử dụng', () {
                  Navigator.pop(context);
                }),
                const Divider(),
                _drawerItem(Icons.settings_outlined, 'Cài đặt', () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
          // Nút Đăng xuất nằm ở cuối
          const Divider(),
          _drawerItem(
            Icons.logout,
            'Đăng xuất',
            () => Navigator.pushReplacementNamed(context, '/login'),
            isLogout: true,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Widget con cho từng mục trong Drawer
  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    final color = isLogout ? AppTheme.errorColor : Colors.black87;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

////////////////////////////////////////////////////////
/// DASHBOARD VIEW
////////////////////////////////////////////////////////

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Future<dynamic> _futureContracts;
  late Future<dynamic> _futureTonKho;

  @override
  void initState() {
    super.initState();
    _futureContracts = ApiService().get(
      '/HopDong?trangThai=DangHieuLuc,QuaHan',
    );
    _futureTonKho = ApiService().get('/ThongKe/TonKho');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xin chào!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// 🔥 STATS
          FutureBuilder(
            future: _futureTonKho,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              int ready = 0, rented = 0, maintenance = 0;

              final data = snapshot.data;
              if (data is List) {
                for (var item in data) {
                  final status = item['trangThai'] ?? '';
                  final count = (item['soLuong'] as num?)?.toInt() ?? 0;

                  if (status == 'SanSang') {
                    ready = count;
                  } else if (status == 'DangChoThue')
                    rented = count;
                  else if (status == 'BaoTri')
                    maintenance = count;
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat('Sẵn sàng', ready, Colors.green),
                  _stat('Đang thuê', rented, Colors.orange),
                  _stat('Bảo trì', maintenance, Colors.red),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'Công việc',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          /// 🔥 CONTRACT LIST
          FutureBuilder(
            future: _futureContracts,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List data = snapshot.data is List
                  ? snapshot.data
                  : snapshot.data['data'] ?? [];

              if (data.isEmpty) {
                return const Card(
                  margin: EdgeInsets.only(top: 8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Không có hợp đồng nào đang hiệu lực hoặc quá hạn.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: data.map<Widget>((c) {
                  final String status = c['trangThai'] ?? '';
                  final isOverdue = status == 'QuaHan';

                  return Card(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isOverdue ? Colors.red : Colors.blue)
                            .withOpacity(0.1),
                        child: Icon(
                          isOverdue
                              ? Icons.warning_amber_rounded
                              : Icons.description_outlined,
                          color: isOverdue ? Colors.red : Colors.blue,
                        ),
                      ),
                      title: Text(
                        c['tenKhachHang'] ?? 'Khách lẻ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số HĐ: ${c['maDinhDanhHopDong'] ?? ''}'),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (isOverdue ? Colors.red : Colors.green)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isOverdue ? 'Quá Hạn' : 'Đang thuê',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isOverdue
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaymentReturnScreen(contract: c),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _futureContracts = ApiService().get(
                              '/HopDong?trangThai=DangHieuLuc,QuaHan',
                            );
                            _futureTonKho = ApiService().get('/ThongKe/TonKho');
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// EQUIPMENT LIST (GIỮ NGUYÊN API)
////////////////////////////////////////////////////////

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  List<dynamic> _allEquipments = [];
  List<dynamic> _filteredEquipments = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  int? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService().get('/ThietBi'),
        ApiService().get('/DanhMucThietBi'),
      ]);

      final equipData = results[0];
      final catData = results[1];

      if (!mounted) return;
      setState(() {
        _allEquipments = (equipData is List)
            ? equipData
            : (equipData['data'] ?? []);
        _categories = (catData is List) ? catData : (catData['data'] ?? []);
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching equipment list: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEquipments = _allEquipments.where((e) {
        final matchCategory =
            _selectedCategoryId == null ||
            e['maDanhMuc'] == _selectedCategoryId;
        final matchQuery =
            _searchQuery.isEmpty ||
            (e['tenThietBi']?.toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false) ||
            (e['maDinhDanhThietBi']?.toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false) ||
            (e['soSeri']?.toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false);
        return matchCategory && matchQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên, mã hoặc số Seri...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textSecondaryColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppTheme.textSecondaryColor,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length + 1,
                    itemBuilder: (context, i) {
                      final isAll = i == 0;
                      final cat = isAll ? null : _categories[i - 1];
                      final catId = isAll ? null : cat['maDanhMuc'] as int;
                      final catName = isAll
                          ? 'Tất cả'
                          : cat['tenDanhMuc'] as String;
                      final isSelected = _selectedCategoryId == catId;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            catName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimaryColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = selected ? catId : null;
                              _applyFilters();
                            });
                          },
                          selectedColor: AppTheme.primaryColor,
                          backgroundColor: AppTheme.backgroundColor,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppTheme.dividerColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredEquipments.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppTheme.textSecondaryColor,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Không tìm thấy thiết bị nào',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredEquipments.length,
                      itemBuilder: (context, i) {
                        final eMap = _filteredEquipments[i];
                        final e = Equipment.fromJson(
                          eMap as Map<String, dynamic>,
                        );

                        Color statusColor;
                        String statusText;
                        switch (e.trangThai) {
                          case 'SanSang':
                            statusColor = AppTheme.successColor;
                            statusText = 'Sẵn sàng';
                            break;
                          case 'DangChoThue':
                            statusColor = AppTheme.warningColor;
                            statusText = 'Đang thuê';
                            break;
                          case 'BaoTri':
                            statusColor = AppTheme.errorColor;
                            statusText = 'Bảo trì';
                            break;
                          case 'NgungSuDung':
                            statusColor = AppTheme.textSecondaryColor;
                            statusText = 'Ngừng dùng';
                            break;
                          default:
                            statusColor = AppTheme.primaryColor;
                            statusText = e.trangThai;
                        }

                        final code = eMap['maDinhDanhThietBi'] ?? 'Chưa có mã';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppTheme.radiusMedium,
                            boxShadow: const [AppTheme.shadowSmall],
                            border: Border.all(
                              color: AppTheme.dividerColor,
                              width: 0.5,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  (e.imageUrl != null && e.imageUrl!.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        e.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, _, _) =>
                                            const Icon(
                                              Icons.image,
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppTheme.primaryColor,
                                    ),
                            ),
                            title: Text(
                              e.tenThietBi,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Mã: $code',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${e.giaThueNgay.toStringAsFixed(0)}đ/ngày',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EquipmentDetailScreen(
                                    equipmentId: e.maThietBi.toString(),
                                  ),
                                ),
                              );
                              _fetchData();
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////
/// CUSTOMER LIST (API)
////////////////////////////////////////////////////////

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<dynamic> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().get('/KhachHang');
      if (!mounted) return;
      setState(() {
        _customers = (data is List) ? data : (data['data'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
          );
          if (result == true) _fetchCustomers();
        },
        child: const Icon(Icons.add),
      ),
      body: _customers.isEmpty
          ? const Center(child: Text('Danh sách trống'))
          : RefreshIndicator(
              onRefresh: _fetchCustomers,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index] as Map<String, dynamic>;
                  final name =
                      customer['tenKhachHang'] ??
                      customer['tenCongTy'] ??
                      'Chưa rõ';
                  final phone = customer['soDienThoai'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusMedium,
                      boxShadow: [AppTheme.shadowSmall],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.successColor.withOpacity(0.2),
                        child: Icon(
                          Icons.business,
                          color: AppTheme.successColor,
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(phone),
                      onTap: () async {
                        final intId = customer['maKhachHang'];

                        if (intId != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailScreen(
                                customerId: intId.toString(),
                              ),
                            ),
                          );
                          if (result == true) _fetchCustomers();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Không tìm thấy mã ID số của khách hàng này',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
