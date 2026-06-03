import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/screens/equipment_detail_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/camera_screen.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/models/equipment.dart';
import 'package:nhom2_quanlythietbichothue/screens/contract_form_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/phieu_thu_hoi_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    EquipmentListScreen(),
    RentalListScreen(),
    CustomerListScreen(),
  ];
  // Hàm xử lý kết quả quét mã (hoặc nhập ID giả lập)
  // Trong class _EmployeeDashboardScreenState của employee_dashboard_screen.dart
  Future<void> _handleScanResult(String scannedId) async {
    try {
      final equipment = await ApiService().get('/ThietBi/$scannedId');
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
            builder: (context) => PhieuThuHoiScreen(equipment: equipment),
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
      floatingActionButton: FloatingActionButton.extended(
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
            _handleScanResult(
              debugId,
            ); // Gọi hàm xử lý logic chuyển trang Nghĩa vừa viết
          }
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Quét QR'),
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
                _drawerItem(Icons.history, 'Lịch sử bàn giao', () {
                  // Chức năng phát triển sau
                  Navigator.pop(context);
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
      '/HopDong/CuaToi?trangThai=DangHieuLuc,QuaHan',
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

              return Column(
                children: data.map((c) {
                  return ListTile(
                    title: Text(c['tenKhachHang'] ?? ''),
                    subtitle: Text(c['maDinhDanhHopDong'] ?? ''),
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

class EquipmentListScreen extends StatelessWidget {
  const EquipmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiService().get('/ThietBi'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List data = snapshot.data is List
            ? snapshot.data
            : snapshot.data['data'] ?? [];

        List<Equipment> list = data
            .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final e = list[i];
            return ListTile(
              title: Text(e.tenThietBi),
              subtitle: Text('${e.giaThueNgay}đ'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EquipmentDetailScreen(
                    equipmentId: e.maThietBi.toString(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

////////////////////////////////////////////////////////
/// RENTAL LIST (API)
////////////////////////////////////////////////////////

class RentalListScreen extends StatelessWidget {
  const RentalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // future: ApiService().get('/HopDong'),
      future: ApiService().get('/HopDong/CuaToi'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List data = snapshot.data is List
            ? snapshot.data
            : snapshot.data['data'] ?? [];

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, i) {
            final c = data[i];
            return ListTile(
              title: Text(c['maDinhDanhHopDong'] ?? ''),
              subtitle: Text(c['tenKhachHang'] ?? ''),
            );
          },
        );
      },
    );
  }
}

////////////////////////////////////////////////////////
/// CUSTOMER LIST (API)
////////////////////////////////////////////////////////

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: ApiService().get('/KhachHang'),
      builder: (context, snapshot) {
        // Đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Lỗi
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        // Không có dữ liệu
        if (!snapshot.hasData) {
          return const Center(child: Text('Không có khách hàng'));
        }

        // Parse dữ liệu
        List<dynamic> customers = [];
        final data = snapshot.data;

        if (data is List) {
          customers = data;
        } else if (data is Map && data['data'] != null) {
          customers = data['data'] as List;
        }

        // Danh sách rỗng
        if (customers.isEmpty) {
          return const Center(child: Text('Danh sách trống'));
        }

        // Hiển thị danh sách
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index] as Map<String, dynamic>;

            // SỬA TẠI ĐÂY: Đổi 'tenCongTy' thành 'tenKhachHang' (hoặc 'TenKhachHang' tùy Backend)
            // Dựa vào các lỗi 400 trước đó, Backend của bạn thường dùng 'tenKhachHang'
            final name =
                customer['tenKhachHang'] ?? customer['tenCongTy'] ?? 'Chưa rõ';
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
                  child: Icon(Icons.business, color: AppTheme.successColor),
                ),
                title: Text(name),
                subtitle: Text(phone),
              ),
            );
          },
        );
      },
    );
  }
}
