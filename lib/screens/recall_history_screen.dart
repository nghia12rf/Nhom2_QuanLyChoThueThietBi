import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';

class RecallHistoryScreen extends StatefulWidget {
  const RecallHistoryScreen({super.key});

  @override
  State<RecallHistoryScreen> createState() => _RecallHistoryScreenState();
}

class _RecallHistoryScreenState extends State<RecallHistoryScreen> {
  List<Map<String, dynamic>> _recalls = [];
  List<Map<String, dynamic>> _filteredRecalls = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().get('/PhieuThuHoi');
      List<Map<String, dynamic>> data = [];
      if (response is List) {
        data = response.cast<Map<String, dynamic>>();
      } else if (response is Map && response['data'] != null) {
        data = (response['data'] as List).cast<Map<String, dynamic>>();
      }
      
      if (mounted) {
        setState(() {
          _recalls = data;
          _filterRecalls();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[RECALL HISTORY LOADING ERROR]: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải lịch sử thu hồi: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterRecalls() {
    if (_searchQuery.trim().isEmpty) {
      _filteredRecalls = List.from(_recalls);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredRecalls = _recalls.where((item) {
        final contractId = (item['maDinhDanhHopDong'] ?? '').toString().toLowerCase();
        final customer = (item['tenKhachHang'] ?? '').toString().toLowerCase();
        final receiver = (item['tenNguoiNhan'] ?? '').toString().toLowerCase();
        return contractId.contains(query) || customer.contains(query) || receiver.contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Lịch Sử Thu Hồi Thiết Bị'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Thanh Tìm Kiếm
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo mã HĐ, khách hàng, người nhận...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filterRecalls();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _filterRecalls();
                      });
                    },
                  ),
                ),
                
                // Danh sách
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadHistory,
                    child: _filteredRecalls.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text(
                                      'Không tìm thấy dữ liệu thu hồi thiết bị',
                                      style: TextStyle(color: Colors.grey, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            itemCount: _filteredRecalls.length,
                            itemBuilder: (context, index) {
                              final item = _filteredRecalls[index];
                              return _buildRecallCard(item);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRecallCard(Map<String, dynamic> item) {
    final contractId = item['maDinhDanhHopDong'] ?? 'HĐ #${item['maHopDong']}';
    final customer = item['tenKhachHang'] ?? 'Khách lẻ';
    final receiver = item['tenNguoiNhan'] ?? 'N/A';
    final returnDateStr = item['ngayTra'] ?? item['ngayTao'] ?? '';
    
    DateTime? returnDate;
    if (returnDateStr.isNotEmpty) {
      returnDate = DateTime.tryParse(returnDateStr);
    }
    
    final formattedDate = returnDate != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(returnDate)
        : returnDateStr;

    final overdueDays = item['soNgayTre'] ?? 0;
    final overdueFine = (item['tienPhatTre'] ?? 0).toDouble();
    final damageFine = (item['phiHuHong'] ?? 0).toDouble();
    final totalAmount = (item['tongTienPhaiThanhToan'] ?? 0).toDouble();
    final hasDamage = item['coHuHong'] ?? false;
    final damageNote = item['ghiChuHuHong'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mã HĐ + Badge trạng thái ngoại quan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Hợp đồng: $contractId',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasDamage ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: hasDamage ? Colors.red.shade200 : Colors.green.shade200),
                  ),
                  child: Text(
                    hasDamage ? 'CÓ HƯ HẠI' : 'HOÀN HẢO',
                    style: TextStyle(
                      color: hasDamage ? Colors.red.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Chi tiết thông tin
            _buildRowDetail(Icons.business, 'Khách hàng', customer),
            const SizedBox(height: 6),
            _buildRowDetail(Icons.person_outline, 'Người nhận máy', receiver),
            const SizedBox(height: 6),
            _buildRowDetail(Icons.calendar_today_outlined, 'Ngày thu hồi', formattedDate),
            const SizedBox(height: 12),

            // Chi phí quyết toán
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Số ngày trễ hạn:', '$overdueDays ngày', isRed: overdueDays > 0),
                  _buildPriceRow('Phạt trễ hạn:', '${NumberFormat('#,###').format(overdueFine)} đ', isRed: overdueFine > 0),
                  _buildPriceRow('Phạt đền bù hư hại:', '${NumberFormat('#,###').format(damageFine)} đ', isRed: damageFine > 0),
                  const Divider(),
                  _buildPriceRow(
                    'Tổng tiền đã quyết toán:',
                    '${NumberFormat('#,###').format(totalAmount)} đ',
                    isBold: true,
                    color: Colors.green.shade700,
                  ),
                ],
              ),
            ),

            // Ghi chú hỏng hóc nếu có
            if (hasDamage && damageNote.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.report_problem, color: Colors.red, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Mô tả hư hại thiết bị:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      damageNote,
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRowDetail(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isRed = false, bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold || isRed ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isRed ? Colors.red : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
