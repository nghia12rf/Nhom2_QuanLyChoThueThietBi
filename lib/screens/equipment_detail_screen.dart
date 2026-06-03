import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/screens/equipment_form_screen.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final String equipmentId;

  const EquipmentDetailScreen({super.key, required this.equipmentId});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  Map<String, dynamic>? equipment;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => loading = true);
    try {
      final data = await ApiService().get('/ThietBi/${widget.equipmentId}');
      if (mounted) {
        setState(() {
          equipment = data is Map<String, dynamic> ? data : data?['data'];
          loading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải chi tiết thiết bị: $e');
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết thiết bị')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (equipment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy thông tin thiết bị')),
      );
    }

    final eq = equipment!;

    // Xử lý mô tả: Ưu tiên moTa → thongSoKyThuat → thông báo không có
    final String moTaHienThi = (eq['moTa']?.toString().trim() ?? '').isNotEmpty
        ? eq['moTa']
        : (eq['thongSoKyThuat']?.toString().trim() ?? '').isNotEmpty
        ? eq['thongSoKyThuat']
        : 'Không có mô tả chi tiết cho thiết bị này.';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(eq['tenThietBi'] ?? 'Chi tiết thiết bị'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ảnh + Trạng thái
              Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.blueGrey[100],
                    child: const Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.white70,
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Chip(
                      label: Text(
                        _getStatusLabel(eq['trangThai']).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _getStatusColor(eq['trangThai']),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Tên thiết bị + Mã định danh
                    Text(
                      eq['tenThietBi'] ?? '',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã định danh: ${eq['maDinhDanhThietBi'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(height: 32),

                    // 3. MÔ TẢ CHI TIẾT (Cải tiến)
                    const Text(
                      'Mô tả chi tiết',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          moTaHienThi,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 4. THÔNG TIN CƠ BẢN (Thêm Danh mục)
                    _buildInfoSection('Thông tin cơ bản', {
                      'Danh mục': eq['tenDanhMuc'] ?? 'Chưa phân loại',
                      'Số Seri': eq['soSeri'] ?? 'N/A',
                      'Giá thuê/ngày': '${eq['giaThueNgay'] ?? 0} VNĐ',
                      'Giá trị tài sản': '${eq['giaTriTaiSan'] ?? 0} VNĐ',
                      'Trạng thái': _getStatusLabel(eq['trangThai']),
                    }),

                    const SizedBox(height: 16),

                    // 5. THÔNG SỐ KỸ THUẬT
                    _buildInfoSection('Thông số kỹ thuật', {
                      'Công suất':
                          eq['congSuat']?.toString() ?? 'Chưa cập nhật',
                      'Trọng lượng':
                          eq['trongLuong']?.toString() ?? 'Chưa cập nhật',
                      'Điện áp': eq['dienAp']?.toString() ?? 'Chưa cập nhật',
                    }),

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

  // ================= HELPERS =================

  Widget _buildInfoSection(String title, Map<String, String> details) {
    return Card(
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
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(color: Colors.black54)),
                    Flexible(
                      child: Text(
                        e.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600),
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

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'SanSang':
        return 'Sẵn sàng';
      case 'DangChoThue':
        return 'Đang thuê';
      case 'BaoTri':
        return 'Bảo trì';
      case 'NgungSuDung':
        return 'Ngừng sử dụng';
      default:
        return status ?? 'N/A';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'SanSang':
        return Colors.green;
      case 'DangChoThue':
        return Colors.orange;
      case 'BaoTri':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EquipmentFormScreen(
          isEdit: true,
          equipmentId: widget.equipmentId,
          initialData: equipment,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadDetail(); // Refresh sau khi chỉnh sửa
      }
    });
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá?'),
        content: const Text(
          'Thiết bị sẽ bị xoá vĩnh viễn khỏi hệ thống. Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEquipment(context);
            },
            child: const Text('XOÁ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Tìm đến hàm _deleteEquipment trong equipment_detail_screen.dart
  Future<void> _deleteEquipment(BuildContext context) async {
    try {
      await ApiService().delete('/ThietBi/${widget.equipmentId}');

      // 🔥 DÒNG QUAN TRỌNG NHẤT: Kiểm tra xem màn hình còn tồn tại không
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xoá thiết bị thành công')),
      );

      // Quay lại màn hình danh sách
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xoá: $e')));
    }
  }
}
