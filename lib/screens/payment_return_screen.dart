import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/models/damage_report.dart';
import 'package:nhom2_quanlythietbichothue/models/maintenance_task.dart';
import 'package:nhom2_quanlythietbichothue/services/operations_service.dart';

class PaymentReturnScreen extends StatefulWidget {
  final Map<String, dynamic> contract;

  const PaymentReturnScreen({super.key, required this.contract});

  @override
  State<PaymentReturnScreen> createState() => _PaymentReturnScreenState();
}

class _PaymentReturnScreenState extends State<PaymentReturnScreen> {
  bool _coHuHong = false;
  final TextEditingController _phiHuHongController = TextEditingController(
    text: '0',
  );
  final TextEditingController _ghiChuController = TextEditingController();
  bool _isSubmitting = false;
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _phiHuHongController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _captureAndUpload() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image == null) return;

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

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String _formatMoney(double value) {
    if (value % 1 == 0) {
      return '${value.toInt()} đ';
    }
    return '${value.toStringAsFixed(0)} đ';
  }

  int get _calculatedOverdueDays {
    final dueDateStr = widget.contract['ngayKetThucDuKien'] ?? widget.contract['NgayKetThucDuKien'];
    if (dueDateStr == null) return 0;
    final dueDate = DateTime.tryParse(dueDateStr.toString());
    if (dueDate == null) return 0;

    // Đưa cả 2 ngày về dạng chỉ có Ngày/Tháng/Năm (không có giờ phút giây) để tính số ngày lịch chính xác
    final nowOnlyDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final dueOnlyDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final days = nowOnlyDate.difference(dueOnlyDate).inDays;
    return days > 0 ? days : 0;
  }

  double get _estimatedOverdueFine => _calculatedOverdueDays * 100000.0;

  double get _totalEstimate {
    double basePrice = _parseToDouble(widget.contract['tongTien'] ?? widget.contract['TongTien']);
    double deposit = _parseToDouble(widget.contract['tienCoc'] ?? widget.contract['TienCoc']);
    double damageFine = double.tryParse(_phiHuHongController.text) ?? 0;
    return basePrice + _estimatedOverdueFine + damageFine - deposit;
  }

  Future<void> _submitPayment() async {
    setState(() => _isSubmitting = true);

    // Ép kiểu an toàn để lấy mã hợp đồng gốc
    final int rawContractId =
        int.tryParse(widget.contract['maHopDong']?.toString() ?? '') ??
        int.tryParse(widget.contract['MaHopDong']?.toString() ?? '') ??
        0;

    if (rawContractId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Không tìm thấy mã hợp đồng hợp lệ!'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final body = {
      'maHopDong': rawContractId,
      'ngayTra': DateTime.now().toIso8601String(),
      'coHuHong': _coHuHong,
      'phiHuHong': double.tryParse(_phiHuHongController.text) ?? 0.0,
      'ghiChuHuHong': _coHuHong ? _ghiChuController.text.trim() : '',
      'danhSachAnhHuHong': _imageUrls.join(';'),
    };

    try {
      // Thực hiện gọi API POST sang C#
      final res = await ApiService().post('/PhieuThuHoi', body);

      // Ghi nhận báo cáo hỏng hóc cục bộ nếu có hư hỏng
      if (_coHuHong) {
        try {
          final detailsList =
              widget.contract['chiTiet'] ??
              widget.contract['chiTietHopDongs'] ??
              widget.contract['ChiTiet'] ??
              widget.contract['ChiTietHopDongs'];
          if (detailsList is List) {
            for (var item in detailsList) {
              final int eqId =
                  int.tryParse(item['maThietBi']?.toString() ?? '') ??
                  int.tryParse(item['MaThietBi']?.toString() ?? '') ??
                  0;
              if (eqId == 0) continue;

              final String eqName =
                  item['tenThietBi']?.toString() ??
                  item['TenThietBi']?.toString() ??
                  item['maThietBiNavigation']?['tenThietBi']?.toString() ??
                  item['MaThietBiNavigation']?['TenThietBi']?.toString() ??
                  'Thiết bị #$eqId';

              final report = DamageReport(
                id: '${DateTime.now().microsecondsSinceEpoch}_$eqId',
                equipmentId: eqId,
                equipmentName: eqName,
                reporterName: 'Nhân viên thu hồi',
                severity: 'Trung bình',
                description: _ghiChuController.text.trim().isNotEmpty
                    ? _ghiChuController.text.trim()
                    : 'Phát hiện hỏng hóc khi thu hồi hợp đồng.',
                status: 'Mới',
                reportedAt: DateTime.now(),
              );

              await OperationsService().saveDamageReport(report);

              // Tự động chuyển qua Quản lý bảo trì bằng cách tạo Phiếu bảo trì chờ xử lý
              final task = MaintenanceTask(
                id: '${DateTime.now().microsecondsSinceEpoch}_task_$eqId',
                equipmentId: eqId,
                equipmentName: eqName,
                damageReportId: report.id,
                technicianName: 'Chưa phân công',
                scheduledAt: DateTime.now(),
                status: 'Chờ xử lý',
                note: report.description,
                estimatedCost: double.tryParse(_phiHuHongController.text) ?? 0,
              );

              await OperationsService().saveMaintenanceTask(task);
            }
          }
        } catch (e) {
          debugPrint('[LOCAL DAMAGE REPORT LOG ERROR]: ${e.toString()}');
        }
      }

      if (!mounted) return;

      // Hiển thị Dialog khi Quyết toán Thành công
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text(
                'Quyết Toán Thành Công',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mã phiếu thu: ${res['maPhieuThuHoi'] ?? res['MaPhieuThuHoi'] ?? ''}',
              ),
              Text(
                'Số ngày trễ hạn: ${res['soNgayTre'] ?? res['SoNgayTre'] ?? 0} ngày',
              ),
              Text(
                'Tiền phạt trễ hạn: ${res['tienPhatTre'] ?? res['TienPhatTre'] ?? 0} đ',
              ),
              Text(
                'Phí đền bù hư hại: ${res['phiHuHong'] ?? res['PhiHuHong'] ?? 0} đ',
              ),
              const Divider(height: 20),
              Text(
                'TỔNG TIỀN ĐÃ THU: ${res['tongTienPhaiThanhToan'] ?? res['TongTienPhaiThanhToan'] ?? 0} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Đóng Dialog
                Navigator.pop(
                  context,
                  true,
                ); // Trả về màn hình danh sách và load lại dữ liệu
              },
              child: const Text('XÁC NHẬN ĐÓNG HỢP ĐỒNG'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        // Log chi tiết object lỗi ra tab Run/Console của IDE để theo dõi
        debugPrint("[FLUTTER CRITICAL ERROR]: ${e.toString()}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Hiển thị trực tiếp nội dung lỗi chi tiết để biết DB lỗi ở bảng nào
            content: Text(
              'Lỗi quyết toán: ${e.toString().replaceAll('Exception:', '').trim()}',
            ),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(
              seconds: 8,
            ), // Tăng thời gian hiển thị để kịp đọc lỗi
            action: SnackBarAction(
              label: 'ĐÓNG',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contract;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Hóa Đơn Quyết Toán & Thu Hồi Máy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hợp đồng số: ${c['maDinhDanhHopDong'] ?? c['MaDinhDanhHopDong'] ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    _buildRowInfo(
                      'Tiền thuê tạm tính ban đầu:',
                      _formatMoney(_parseToDouble(c['tongTien'] ?? c['TongTien'])),
                    ),
                    _buildRowInfo(
                      'Tiền đặt cọc (Khấu trừ):',
                      '- ${_formatMoney(_parseToDouble(c['tienCoc'] ?? c['TienCoc']))}',
                    ),
                    _buildRowInfo(
                      'Số ngày quá hạn:',
                      '$_calculatedOverdueDays ngày',
                      color: _calculatedOverdueDays > 0 ? Colors.red : null,
                    ),
                    _buildRowInfo(
                      'Tiền phạt trễ hạn dự tính:',
                      _formatMoney(_estimatedOverdueFine),
                      color: _estimatedOverdueFine > 0 ? Colors.red : null,
                    ),
                    Builder(
                      builder: (context) {
                        final detailsList = c['chiTiet'] ??
                            c['chiTietHopDongs'] ??
                            c['ChiTiet'] ??
                            c['ChiTietHopDongs'];
                        if (detailsList != null && detailsList is List && detailsList.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 24),
                              const Text(
                                'Danh sách thiết bị thuê:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              ...detailsList.map<Widget>((item) {
                                final int eqId = int.tryParse(item['maThietBi']?.toString() ?? '') ??
                                    int.tryParse(item['MaThietBi']?.toString() ?? '') ?? 0;
                                final String eqName = item['tenThietBi']?.toString() ??
                                    item['TenThietBi']?.toString() ??
                                    item['maThietBiNavigation']?['tenThietBi']?.toString() ??
                                    item['MaThietBiNavigation']?['TenThietBi']?.toString() ??
                                    'Thiết bị #$eqId';
                                final double price = _parseToDouble(item['giaThueThoiDiem'] ?? item['GiaThueThoiDiem']);
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          eqName,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      if (price > 0)
                                        Text(
                                          _formatMoney(price),
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kiểm tra hư hại thiết bị ngoại quan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SwitchListTile(
                      title: const Text('Có thiết bị hỏng hóc cần đền bù?'),
                      value: _coHuHong,
                      activeThumbColor: Colors.red,
                      onChanged: (val) => setState(() => _coHuHong = val),
                    ),
                    if (_coHuHong) ...[
                      TextField(
                        controller: _phiHuHongController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền đền bù hư hại (đ)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ghiChuController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả chi tiết lỗi thiết bị',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _captureAndUpload,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Chụp ảnh minh chứng hư hỏng'),
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) {
                final total = _totalEstimate;
                final isRefund = total < 0;
                final displayAmount = _formatMoney(total.abs());
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRefund 
                        ? Colors.blue.shade50 
                        : (total > 0 ? Colors.red.shade50 : Colors.green.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRefund 
                          ? Colors.blue.shade200 
                          : (total > 0 ? Colors.red.shade200 : Colors.green.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isRefund 
                            ? 'TIỀN HOÀN TRẢ LẠI KHÁCH:' 
                            : (total > 0 ? 'KHÁCH CẦN ĐÓNG THÊM:' : 'QUYẾT TOÁN HÒA VỐN:'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isRefund 
                            ? '- $displayAmount' 
                            : (total > 0 ? '+ $displayAmount' : '0 đ'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isRefund 
                              ? Colors.blue.shade800 
                              : (total > 0 ? Colors.red.shade800 : Colors.green.shade800),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitPayment,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'XÁC NHẬN ĐÃ THU TIỀN & NHẬN MÁY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowInfo(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
