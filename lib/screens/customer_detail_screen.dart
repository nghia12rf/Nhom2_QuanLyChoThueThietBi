import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/screens/customer_form_screen.dart';
import 'package:nhom2_quanlythietbichothue/screens/payment_return_screen.dart';

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
  List<Map<String, dynamic>> _rentedContracts = [];
  bool _loadingContracts = false;

  @override
  void initState() {
    super.initState();
    _loadCustomer().then((_) {
      _loadCustomerContracts();
    });
  }

  Future<void> _loadCustomer() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final data = await ApiService().get('/KhachHang/${widget.customerId}');

      if (mounted) {
        setState(() {
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

  Future<void> _loadCustomerContracts() async {
    if (!mounted) return;
    setState(() => _loadingContracts = true);

    try {
      final response = await ApiService().get('/HopDong?trangThai=DangHieuLuc,QuaHan,GiaHan');
      
      List<Map<String, dynamic>> allContracts = [];
      if (response is List) {
        allContracts = response.cast<Map<String, dynamic>>();
      } else if (response is Map && response['data'] != null) {
        allContracts = (response['data'] as List).cast<Map<String, dynamic>>();
      }

      final int cId = int.tryParse(widget.customerId) ?? 
                      int.tryParse(customer?['maKhachHang']?.toString() ?? '') ?? 
                      int.tryParse(customer?['MaKhachHang']?.toString() ?? '') ?? 0;

      if (mounted) {
        setState(() {
          _rentedContracts = allContracts.where((contract) {
            final int contractCustomerId = int.tryParse(contract['maKhachHang']?.toString() ?? '') ?? 
                                          int.tryParse(contract['MaKhachHang']?.toString() ?? '') ?? 0;
            return contractCustomerId == cId;
          }).toList();
          _loadingContracts = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải hợp đồng khách hàng: $e');
      if (mounted) {
        setState(() => _loadingContracts = false);
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
        onRefresh: () async {
          await _loadCustomer();
          await _loadCustomerContracts();
        },
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
                    const SizedBox(height: 24),

                    // DANH SÁCH THIẾT BỊ & HỢP ĐỒNG ĐANG THUÊ
                    const Text(
                      'Danh sách thiết bị & Hợp đồng đang thuê',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRentedContractsSection(),
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

  Widget _buildRentedContractsSection() {
    if (_loadingContracts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_rentedContracts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            'Khách hàng hiện tại không có thiết bị hoặc hợp đồng nào đang thuê.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: _rentedContracts.map((contract) {
        final contractIdStr = contract['maDinhDanhHopDong'] ?? 'N/A';
        final status = contract['trangThai'] ?? '';
        final isOverdue = status == 'QuaHan';
        final isExtension = status == 'GiaHan';
        final endDate = contract['ngayKetThucDuKien'] ?? '';

        String statusLabel = 'ĐANG THUÊ';
        Color statusColor = Colors.green;
        if (isOverdue) {
          statusLabel = 'QUÁ HẠN';
          statusColor = Colors.red;
        } else if (isExtension) {
          statusLabel = 'GIA HẠN';
          statusColor = Colors.blue;
        }

        String equipmentNames = '';
        final detailsList = contract['chiTiet'] ?? 
                            contract['chiTietHopDongs'] ?? 
                            contract['ChiTiet'] ?? 
                            contract['ChiTietHopDongs'];
        if (detailsList is List) {
          equipmentNames = detailsList
              .map((c) => c['tenThietBi'] ?? 
                          (c['maThietBiNavigation'] != null 
                              ? c['maThietBiNavigation']['tenThietBi'] ?? '' 
                              : ''))
              .where((name) => name.toString().isNotEmpty)
              .join(', ');
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hợp đồng: $contractIdStr',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                if (equipmentNames.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.precision_manufacturing, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thiết bị: $equipmentNames',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (endDate.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Hạn trả: ${_formatDate(endDate)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOverdue ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentReturnScreen(contract: contract),
                        ),
                      );

                      if (result == true) {
                        _loadCustomer();
                        _loadCustomerContracts();
                      }
                    },
                    icon: const Icon(Icons.assignment_return_outlined, size: 18),
                    label: const Text('THU HỒI & QUYẾT TOÁN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
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