import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/models/equipment.dart';

class ContractFormScreen extends StatefulWidget {
  // THÊM: Biến nhận dữ liệu thiết bị từ Dashboard truyền sang
  final Map<String, dynamic>? preSelectedEquipment;

  // THÊM: Cập nhật Constructor để chấp nhận tham số này
  const ContractFormScreen({super.key, this.preSelectedEquipment});

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  String? selectedCustomerId;
  List<int> selectedEquipmentIds = [];

  List<Equipment> availableEquipments = [];
  List<Map<String, dynamic>> customers = [];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  bool isLoading = true;
  bool isSubmitting = false;

  final TextEditingController _depositController = TextEditingController(text: '0');

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 🔥 LOGIC: Tự động chọn máy nếu có dữ liệu truyền sang từ quét QR
    if (widget.preSelectedEquipment != null) {
      final id = widget.preSelectedEquipment!['maThietBi'];
      if (id != null) {
        selectedEquipmentIds.add(id is int ? id : int.parse(id.toString()));
        debugPrint("Đã tự động thêm thiết bị ID: $id vào hợp đồng");
      }
    }

    _loadData();
  }

  /// 1. TẢI DỮ LIỆU
  Future<void> _loadData() async {
    try {
      final customerData = await ApiService().get('/KhachHang');
      final equipData = await ApiService().get('/ThietBi');

      if (mounted) {
        setState(() {
          if (customerData is List) {
            customers = customerData.cast<Map<String, dynamic>>();
          }
          if (equipData is List) {
            availableEquipments = equipData
                .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
                .where(
                  (e) =>
                      e.trangThai == 'SanSang' ||
                      selectedEquipmentIds.contains(e.maThietBi),
                )
                .toList();
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// 2. HÀM CHỌN NGÀY
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  /// 3. TÍNH TỔNG TIỀN DỰ KIẾN
  double _calculateTotal() {
    double totalPerDay = 0;
    for (var id in selectedEquipmentIds) {
      // Tìm thiết bị trong cả danh sách availableEquipments
      final equip = availableEquipments.firstWhere(
        (e) => e.maThietBi == id,
        orElse: () => Equipment(
          maThietBi: 0,
          tenThietBi: '',
          giaThueNgay: 0,
          trangThai: '',
        ),
      );
      totalPerDay += equip.giaThueNgay;
    }
    int days = _endDate.difference(_startDate).inDays;
    if (days <= 0) days = 1;
    return totalPerDay * days;
  }

  /// 4. GỬI HỢP ĐỒNG
  Future<void> _submit() async {
    if (selectedCustomerId == null || selectedEquipmentIds.isEmpty) return;
    setState(() => isSubmitting = true);

    try {
      final body = {
        "maDinhDanhHopDong":
            "HD${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        "maKhachHang": int.parse(selectedCustomerId!),
        "ngayBatDau": _startDate.toIso8601String(),
        "ngayKetThucDuKien": _endDate.toIso8601String(),
        "tienCoc": double.tryParse(_depositController.text) ?? 0.0,
        "ghiChu": "Tạo từ App Nhân viên",
        // 🔥 Backend của Nghĩa dùng tên "chiTiet" (C# DTO)
        "chiTiet": selectedEquipmentIds.map((id) => {"maThietBi": id}).toList(),
        "tongTien": _calculateTotal(),
        "trangThai": "DangHieuLuc",
      };

      await ApiService().post('/HopDong', body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Tạo hợp đồng thành công!')),
      );
      Navigator.pop(context, true); // Trả về true để Dashboard load lại stats
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Hợp Đồng Thuê'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '1. Chọn khách hàng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedCustomerId,
                  hint: const Text('Chọn khách hàng thuê'),
                  decoration: _inputDecoration(Icons.business),
                  items: customers.map((c) {
                    return DropdownMenuItem<String>(
                      value: c['maKhachHang'].toString(),
                      child: Text(c['tenKhachHang'] ?? 'Khách hàng không tên'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedCustomerId = val),
                ),

                const SizedBox(height: 24),

                const Text(
                  '2. Thời hạn thuê',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateTile(
                        'Ngày bắt đầu',
                        _startDate,
                        () => _selectDate(context, true),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.grey,
                      size: 20,
                    ),
                    Expanded(
                      child: _buildDateTile(
                        'Ngày kết thúc',
                        _endDate,
                        () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  '3. Số tiền đặt cọc (VNĐ)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _depositController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(Icons.monetization_on_outlined).copyWith(
                    hintText: 'Nhập số tiền đặt cọc',
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  '4. Chọn thiết bị (Máy đang rảnh)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (availableEquipments.isEmpty)
                  const Text('Không có thiết bị rảnh'),
                ...availableEquipments.map((e) {
                  final isSelected = selectedEquipmentIds.contains(e.maThietBi);
                  return CheckboxListTile(
                    title: Text(
                      e.tenThietBi,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Giá: ${currencyFormat.format(e.giaThueNgay)} / ngày',
                    ),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedEquipmentIds.add(e.maThietBi);
                        } else {
                          selectedEquipmentIds.remove(e.maThietBi);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }),

                const Divider(height: 40),

                if (selectedEquipmentIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền dự kiến:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currencyFormat.format(_calculateTotal()),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      (selectedCustomerId != null &&
                          selectedEquipmentIds.isNotEmpty &&
                          !isSubmitting)
                      ? _submit
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('HOÀN TẤT & LƯU HỢP ĐỒNG'),
                ),
              ],
            ),
    );
  }

  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
