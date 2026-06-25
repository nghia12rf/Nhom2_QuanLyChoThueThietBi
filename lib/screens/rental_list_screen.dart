import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/screens/payment_return_screen.dart';

class RentalListScreen extends StatefulWidget {
  const RentalListScreen({super.key});

  @override
  State<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends State<RentalListScreen> {
  List<Map<String, dynamic>> _contracts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Lấy danh sách hợp đồng cần quyết toán
      final response = await ApiService().get('/HopDong?trangThai=DangHieuLuc,QuaHan,GiaHan');
      
      List<Map<String, dynamic>> loadedData = [];
      if (response is List) {
        loadedData = response.cast<Map<String, dynamic>>();
      } else if (response is Map && response['data'] != null) {
        loadedData = (response['data'] as List).cast<Map<String, dynamic>>();
      }

      if (!mounted) return;
      setState(() {
        _contracts = loadedData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Lỗi tải danh sách hợp đồng: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadContracts, child: const Text('Thử lại'))
          ],
        ),
      );
    }

    if (_contracts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadContracts,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(child: Text('Không có hợp đồng nào đang chờ xử lý')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContracts,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _contracts.length,
        itemBuilder: (context, index) {
          final contract = _contracts[index];
          final contractId = contract['maDinhDanhHopDong'] ?? 'N/A';
          
          final customer = contract['tenKhachHang'] ?? 
                           (contract['maKhachHangNavigation'] != null 
                               ? contract['maKhachHangNavigation']['tenCongTy'] 
                               : 'Khách lẻ');
                               
          final status = contract['trangThai'] ?? '';
          final isOverdue = status == 'QuaHan';
          final endDate = contract['ngayKetThucDuKien'] ?? '';

          String equipmentNames = '';
          if (contract['chiTietHopDongs'] != null) {
            final chiTiet = contract['chiTietHopDongs'] as List;
            equipmentNames = chiTiet
                .map((c) => c['maThietBiNavigation'] != null 
                    ? c['maThietBiNavigation']['tenThietBi'] ?? '' 
                    : '')
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
                        contractId,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
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
                  if (equipmentNames.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Thiết bị: $equipmentNames', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  if (endDate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Hạn trả: ${_formatDate(endDate)}'),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOverdue ? Colors.red : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentReturnScreen(contract: contract),
                          ),
                        );

                        // Nếu quyết toán thành công (trả về true), tải lại danh sách
                        if (result == true) {
                          _loadContracts();
                        }
                      },
                      icon: const Icon(Icons.monetization_on_outlined),
                      label: const Text('THANH TOÁN & THU HỒI', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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