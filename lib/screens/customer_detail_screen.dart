import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/screens/customer_form_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Map<String, dynamic>? customer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final data = await ApiService().get('/KhachHang/${widget.customerId}');

      if (mounted) {
        setState(() {
          // Kiểm tra và gán dữ liệu linh hoạt tuỳ thuộc vào cấu trúc bọc của ApiService
          customer = data is Map<String, dynamic> ? data : data?['data'];
          loading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải khách hàng: $e');
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết khách hàng'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ĐÃ SỬA: Sửa điều kiện check lỗi logic, tránh nhận diện nhầm object rỗng
    if (customer == null || (customer!['tenKhachHang'] == null && customer!['tenCongTy'] == null)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lỗi'),
        ),
        body: const Center(
          child: Text('Không tìm thấy thông tin khách hàng'),
        ),
      );
    }

    final kh = customer!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // ĐÃ SỬA: Lấy đúng trường 'tenKhachHang' từ API thay vì 'tenCongTy'
        title: Text(
          kh['tenKhachHang'] ?? kh['tenCongTy'] ?? 'Chi tiết khách hàng',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEdit(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCustomer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                height: 220,
                width: double.infinity,
                color: Colors.blueGrey[100],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.business,
                        size: 50,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Thông tin khách hàng',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÊN KHÁCH HÀNG
                    // ĐÃ SỬA: Ưu tiên lấy 'tenKhachHang'
                    Text(
                      kh['tenKhachHang'] ?? kh['tenCongTy'] ?? 'Chưa rõ tên',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mã định danh: ${kh['maDinhDanhKhachHang'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 32),

                    // THÔNG TIN ĐẠI DIỆN
                    _buildInfoSection(
                      'Thông tin đại diện',
                      {
                        'Người đại diện': kh['nguoiDaiDien'] ?? 'Chưa cập nhật',
                        'Số điện thoại': kh['soDienThoai'] ?? 'Chưa cập nhật',
                        'Email': kh['email'] ?? 'Chưa cập nhật',
                        'Địa chỉ': kh['diaChi'] ?? 'Chưa cập nhật',
                      },
                    ),
                    const SizedBox(height: 16),

                    // THÔNG TIN DOANH NGHIỆP
                    _buildInfoSection(
                      'Thông tin doanh nghiệp',
                      {
                        'Mã số thuế': kh['maSoThue'] ?? 'Chưa cập nhật',
                        'Ngày tạo': kh['ngayTao']?.toString().split(' ')[0] ?? 'Chưa cập nhật',
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _buildInfoSection(
    String title,
    Map<String, String> details,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            ...details.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTIONS =================

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormScreen(
          isEdit: true,
          customerId: widget.customerId,
          initialData: customer,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadCustomer();
      }
    });
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Xác nhận xoá?',
        ),
        content: const Text(
          'Khách hàng sẽ bị xoá vĩnh viễn khỏi hệ thống.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCustomer(context);
            },
            child: const Text(
              'XOÁ',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context) async {
    try {
      await ApiService().delete(
        '/KhachHang/${widget.customerId}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã xoá khách hàng thành công',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xoá: $e'),
        ),
      );
    }
  }
}