import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';

class PaymentReturnScreen extends StatefulWidget {
  final Map<String, dynamic> contract;

  const PaymentReturnScreen({super.key, required this.contract});

  @override
  State<PaymentReturnScreen> createState() => _PaymentReturnScreenState();
}

class _PaymentReturnScreenState extends State<PaymentReturnScreen> {
  bool _coHuHong = false;
  final TextEditingController _phiHuHongController = TextEditingController(text: '0');
  final TextEditingController _ghiChuController = TextEditingController();
  bool _isSubmitting = false;

  int get _calculatedOverdueDays {
    final dueDateStr = widget.contract['ngayKetThucDuKien'];
    if (dueDateStr == null) return 0;
    final dueDate = DateTime.parse(dueDateStr);
    final days = DateTime.now().difference(dueDate).inDays;
    return days > 0 ? days : 0;
  }

  double get _estimatedOverdueFine => _calculatedOverdueDays * 100000.0;

  double get _totalEstimate {
    double basePrice = (widget.contract['tongTien'] ?? 0).toDouble();
    double deposit = (widget.contract['tienCoc'] ?? 0).toDouble();
    double damageFine = double.tryParse(_phiHuHongController.text) ?? 0;
    double total = basePrice + _estimatedOverdueFine + damageFine - deposit;
    return total > 0 ? total : 0;
  }

  Future<void> _submitPayment() async {
    setState(() => _isSubmitting = true);

    // Ép kiểu an toàn để lấy mã hợp đồng gốc
    final int rawContractId = int.tryParse(widget.contract['maHopDong']?.toString() ?? '') ?? 
                              int.tryParse(widget.contract['MaHopDong']?.toString() ?? '') ?? 0;

    if (rawContractId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy mã hợp đồng hợp lệ!'), backgroundColor: Colors.red),
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
      'danhSachAnhHuHong': ''
    };

    try {
      // Thực hiện gọi API POST sang C#
      final res = await ApiService().post('/PhieuThuHoi', body);
      
      if (!mounted) return;

      // Hiển thị Dialog khi Quyết toán Thành công
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Quyết Toán Thành Công', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã phiếu thu: ${res['maPhieuThuHoi'] ?? res['MaPhieuThuHoi'] ?? ''}'),
              Text('Số ngày trễ hạn: ${res['soNgayTre'] ?? res['SoNgayTre'] ?? 0} ngày'),
              Text('Tiền phạt trễ hạn: ${res['tienPhatTre'] ?? res['TienPhatTre'] ?? 0} đ'),
              Text('Phí đền bù hư hại: ${res['phiHuHong'] ?? res['PhiHuHong'] ?? 0} đ'),
              const Divider(height: 20),
              Text(
                'TỔNG TIỀN ĐÃ THU: ${res['tongTienPhaiThanhToan'] ?? res['TongTienPhaiThanhToan'] ?? 0} đ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Đóng Dialog
                Navigator.pop(context, true); // Trả về màn hình danh sách và load lại dữ liệu
              },
              child: const Text('XÁC NHẬN ĐÓNG HỢP ĐỒNG'),
            )
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
            content: Text('Lỗi quyết toán: ${e.toString().replaceAll('Exception:', '').trim()}'), 
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 8), // Tăng thời gian hiển thị để kịp đọc lỗi
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hợp đồng số: ${c['maDinhDanhHopDong']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    _buildRowInfo('Tiền thuê tạm tính ban đầu:', '${c['tongTien']} đ'),
                    _buildRowInfo('Tiền đặt cọc (Khấu trừ):', '- ${c['tienCoc'] ?? 0} đ'),
                    _buildRowInfo('Số ngày quá hạn:', '$_calculatedOverdueDays ngày', color: _calculatedOverdueDays > 0 ? Colors.red : null),
                    _buildRowInfo('Tiền phạt trễ hạn dự tính:', '$_estimatedOverdueFine đ', color: _estimatedOverdueFine > 0 ? Colors.red : null),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kiểm tra hư hại thiết bị ngoại quan', style: TextStyle(fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text('Có thiết bị hỏng hóc cần đền bù?'),
                      value: _coHuHong,
                      activeColor: Colors.red,
                      onChanged: (val) => setState(() => _coHuHong = val),
                    ),
                    if (_coHuHong) ...[
                      TextField(
                        controller: _phiHuHongController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Số tiền đền bù hư hại (đ)', border: OutlineInputBorder()),
                        onChanged: (val) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ghiChuController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Mô tả chi tiết lỗi thiết bị', border: OutlineInputBorder()),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TỔNG SỐ TIỀN THU THỰC TẾ:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('$_totalEstimate đ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isSubmitting ? null : _submitPayment,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('XÁC NHẬN ĐÃ THU TIỀN & NHẬN MÁY', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
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
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}