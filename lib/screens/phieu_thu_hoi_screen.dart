import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/widgets/vietnamese_text_field.dart';
import 'package:nhom2_quanlythietbichothue/models/damage_report.dart';
import 'package:nhom2_quanlythietbichothue/models/maintenance_task.dart';
import 'package:nhom2_quanlythietbichothue/services/operations_service.dart';

class PhieuThuHoiScreen extends StatefulWidget {
  final Map<String, dynamic> equipment;
  const PhieuThuHoiScreen({super.key, required this.equipment});

  @override
  State<PhieuThuHoiScreen> createState() => _PhieuThuHoiScreenState();
}

class _PhieuThuHoiScreenState extends State<PhieuThuHoiScreen> {
  bool isDamaged = false;
  bool isSubmitting = false;
  Map<String, dynamic>? contractInfo;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _feeController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _loadContractInfo();
  }

  // Lấy thông tin hợp đồng đang chứa thiết bị này
  Future<void> _loadContractInfo() async {
    try {
      // API tìm hợp đồng theo MaThietBi
      final data = await ApiService().get(
        '/HopDong/ByEquipment/${widget.equipment['maThietBi']}',
      );
      setState(() => contractInfo = data);
    } catch (e) {
      debugPrint("Lỗi tải hợp đồng: $e");
    }
  }

  Future<void> _submitReturn() async {
    if (contractInfo == null) return;
    setState(() => isSubmitting = true);

    try {
      final body = {
        "maHopDong": contractInfo!['maHopDong'],
        "ngayTra": DateTime.now().toIso8601String(),
        "coHuHong": isDamaged,
        "phiHuHong": double.tryParse(_feeController.text) ?? 0,
        "ghiChuHuHong": _noteController.text,
      };

      await ApiService().post('/PhieuThuHoi', body);

      // Ghi nhận báo cáo hỏng hóc cục bộ nếu có hư hỏng
      if (isDamaged) {
        try {
          final int eqId = int.tryParse(widget.equipment['maThietBi']?.toString() ?? '') ?? 0;
          if (eqId != 0) {
            final String eqName = widget.equipment['tenThietBi']?.toString() ?? 'Thiết bị #$eqId';

            final report = DamageReport(
              id: '${DateTime.now().microsecondsSinceEpoch}_$eqId',
              equipmentId: eqId,
              equipmentName: eqName,
              reporterName: 'Nhân viên thu hồi (QR)',
              severity: 'Trung bình',
              description: _noteController.text.trim().isNotEmpty
                  ? _noteController.text.trim()
                  : 'Phát hiện hỏng hóc khi quét QR thu hồi.',
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
              estimatedCost: double.tryParse(_feeController.text) ?? 0,
            );
            await OperationsService().saveMaintenanceTask(task);
          }
        } catch (e) {
          debugPrint('[LOCAL DAMAGE REPORT LOG ERROR]: ${e.toString()}');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Thu hồi thành công!')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thu Hồi Thiết Bị')),
      body: contractInfo == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard(),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Thiết bị có hư hỏng?'),
                  subtitle: const Text(
                    'Nếu có, máy sẽ tự chuyển sang trạng thái Bảo trì',
                  ),
                  value: isDamaged,
                  onChanged: (val) => setState(() => isDamaged = val),
                ),
                if (isDamaged) ...[
                  TextField(
                    controller: _feeController,
                    decoration: const InputDecoration(
                      labelText: 'Phí hư hỏng (VNĐ)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  VietnameseTextField(
                    controller: _noteController,
                    labelText: 'Mô tả hư hỏng',
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isSubmitting ? null : _submitReturn,
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('XÁC NHẬN THU HỒI'),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Máy: ${widget.equipment['tenThietBi']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            Text('Khách thuê: ${contractInfo!['tenKhachHang']}'),
            Text('Mã HĐ: ${contractInfo!['maDinhDanhHopDong']}'),
            Text(
              'Hạn trả: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(contractInfo!['ngayKetThucDuKien']))}',
            ),
          ],
        ),
      ),
    );
  }
}
