import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/screens/return_equipment_screen.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  late Future<List<Map<String, dynamic>>> _contractsFuture;

  @override
  void initState() {
    super.initState();
    _contractsFuture = _fetchContracts();
  }

  Future<List<Map<String, dynamic>>> _fetchContracts() async {
    try {
      final response = await ApiService().get('/HopDong');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      } else if (response is Map && response['data'] != null) {
        return (response['data'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi tải hợp đồng: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _contractsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có hợp đồng nào'));
        }

        final contracts = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: contracts.length,
          itemBuilder: (context, index) {
            final contract = contracts[index];
            final contractId = contract['maDinhDanhHopDong'] ?? 'N/A';
            final customer = contract['tenKhachHang'] ?? 'Chưa rõ';
            final status = contract['trangThai'] ?? '';
            final isOverdue = status == 'QuaHan';
            final endDate = contract['ngayKetThucDuKien'] ?? '';

            String equipmentNames = '';
            if (contract['chiTiet'] != null) {
              final chiTiet = contract['chiTiet'] as List;
              equipmentNames = chiTiet
                  .map((c) => c['tenThietBi'] ?? '')
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
                          contractId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOverdue ? 'QUÁ HẠN' : 'ĐANG THUÊ',
                            style: TextStyle(
                              color: isOverdue ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Khách hàng: $customer'),
                    if (equipmentNames.isNotEmpty)
                      Text('Thiết bị: $equipmentNames'),
                    if (endDate.isNotEmpty)
                      Text('Hạn trả: ${_formatDate(endDate)}'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReturnEquipmentScreen(
                                contractId: contract['maHopDong'].toString(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.assignment_return_outlined),
                        label: const Text('THỰC HIỆN THU HỒI'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
}
