import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/widgets/vietnamese_text_field.dart';
// cho File (mobile) – web sẽ không dùng File

class ReturnEquipmentScreen extends StatefulWidget {
  final String contractId;
  const ReturnEquipmentScreen({super.key, required this.contractId});
  @override
  State<ReturnEquipmentScreen> createState() => _ReturnEquipmentScreenState();
}

class _ReturnEquipmentScreenState extends State<ReturnEquipmentScreen> {
  final _damageNoteController = TextEditingController();
  bool _isDamaged = false;
  bool _isSubmitting = false;
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _damageNoteController.dispose();
    super.dispose();
  }

  /// Chụp ảnh và upload lên server
  Future<void> _captureAndUpload() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image == null) return;

      // Gọi hàm upload trong ApiService (truyền đường dẫn file)
      final imageUrl = await ApiService().uploadImage(image.path);
      if (imageUrl.isNotEmpty) {
        setState(() {
          _imageUrls.add(imageUrl);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chụp ảnh: $e')));
      }
    }
  }

  Future<void> _submitReturn() async {
    setState(() => _isSubmitting = true);
    try {
      final body = {
        'maHopDong': int.tryParse(widget.contractId) ?? 0,
        'ngayTra': DateTime.now().toIso8601String().split('T')[0],
        'coHuHong': _isDamaged,
        'ghiChuHuHong': _damageNoteController.text,
        'danhSachAnhHuHong': _imageUrls.join(';'),
        'phiHuHong': 0,
      };
      await ApiService().post('/PhieuThuHoi', body);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thu hồi thành công')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nghiệm thu & Thu hồi ${widget.contractId}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Thông tin thiết bị',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchContractDetails(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('Đang tải...');
                final contract = snapshot.data!;
                final equipmentNames =
                    (contract['chiTiet'] as List?)
                        ?.map((e) => e['tenThietBi'] ?? '')
                        .join(', ') ??
                    'Không rõ';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Khách hàng: ${contract['tenKhachHang'] ?? "..."}'),
                    Text('Thiết bị: $equipmentNames'),
                    Text('Ngày thuê: ${contract['ngayBatDau'] ?? "..."}'),
                    Text('Hạn trả: ${contract['ngayKetThucDuKien'] ?? "..."}'),
                  ],
                );
              },
            ),
            const Divider(height: 24),
            const Text(
              '2. Đánh giá hiện trạng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SwitchListTile(
              title: const Text('Có hỏng hóc/trầy xước?'),
              value: _isDamaged,
              onChanged: (val) => setState(() => _isDamaged = val),
            ),
            if (_isDamaged) ...[
              VietnameseTextField(
                controller: _damageNoteController,
                labelText: 'Mô tả tình trạng hỏng hóc',
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _captureAndUpload,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh minh chứng'),
              ),
              if (_imageUrls.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _imageUrls
                      .map(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
            const SizedBox(height: 24),
            const Text(
              '3. Phí phạt trễ hạn (tự động)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Hệ thống sẽ tự động tính phí khi nộp phiếu.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReturn,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text(
                      'HOÀN TẤT THU HỒI',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchContractDetails() async {
    try {
      final response = await ApiService().get('/HopDong/${widget.contractId}');
      if (response is Map<String, dynamic>) return response;
      return {};
    } catch (e) {
      return {};
    }
  }
}
