import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';

class EquipmentFormScreen extends StatefulWidget {
  final bool isEdit;
  final String? equipmentId;
  final Map<String, dynamic>? initialData;

  const EquipmentFormScreen({
    super.key,
    this.isEdit = false,
    this.equipmentId,
    this.initialData,
  });

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isCategoriesLoaded = false;

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _assetValueController = TextEditingController();
  final _powerController = TextEditingController();
  final _weightController = TextEditingController();
  final _voltageController = TextEditingController();

  String? _selectedCategoryId;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.isEdit && widget.initialData != null) {
      final data = widget.initialData!;
      _nameController.text = data['tenThietBi'] ?? '';
      _priceController.text = (data['giaThueNgay'] ?? 0).toString();
      _descriptionController.text = data['moTa'] ?? '';
      _brandController.text = data['hangSanXuat'] ?? '';
      _modelController.text = data['model'] ?? '';
      _assetValueController.text = (data['giaTriTaiSan'] ?? 0).toString();
      _powerController.text = data['congSuat']?.toString() ?? '';
      _weightController.text = data['trongLuong']?.toString() ?? '';
      _voltageController.text = data['dienAp']?.toString() ?? '';
      _selectedCategoryId = data['maDanhMuc']?.toString();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService().get('/DanhMucThietBi');
      if (mounted) {
        setState(() {
          _categories = data is List ? data : [];
          _isCategoriesLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải danh mục: $e");
      if (mounted) {
        setState(() => _isCategoriesLoaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Chỉnh sửa thiết bị' : 'Thêm thiết bị mới'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thông tin chung'),
              _buildInput(
                _nameController,
                'Tên thiết bị',
                Icons.inventory,
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // === DANH MỤC THIẾT BỊ ===
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: _inputDecoration(
                  'Danh mục thiết bị',
                  Icons.category,
                ),
                hint: const Text('Chọn danh mục thiết bị'),
                isExpanded: true,
                items: _categories.map((c) {
                  final id = c['maDanhMuc']?.toString();
                  final name = c['tenDanhMuc']?.toString() ?? 'Không có tên';
                  return DropdownMenuItem<String>(value: id, child: Text(name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn danh mục thiết bị' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      _brandController,
                      'Hãng sản xuất',
                      Icons.business,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInput(
                      _modelController,
                      'Model',
                      Icons.label_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      _priceController,
                      'Giá thuê/ngày',
                      Icons.money,
                      isNumber: true,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInput(
                      _assetValueController,
                      'Giá trị tài sản',
                      Icons.account_balance_wallet,
                      isNumber: true,
                    ),
                  ),
                ],
              ),

              const Divider(height: 40),
              _buildSectionTitle('Thông số kỹ thuật & Mô tả'),

              _buildInput(_powerController, 'Công suất', Icons.flash_on),
              const SizedBox(height: 16),
              _buildInput(
                _weightController,
                'Trọng lượng',
                Icons.monitor_weight,
              ),
              const SizedBox(height: 16),
              _buildInput(
                _voltageController,
                'Điện áp',
                Icons.electrical_services,
              ),
              const SizedBox(height: 16),
              _buildInput(
                _descriptionController,
                'Mô tả chi tiết',
                Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveEquipment,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.isEdit ? 'LƯU THAY ĐỔI' : 'THÊM THIẾT BỊ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveEquipment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final body = {
        if (widget.isEdit && widget.equipmentId != null)
          'maThietBi': int.tryParse(widget.equipmentId!),

        'maDinhDanhThietBi': widget.isEdit
            ? (widget.initialData?['maDinhDanhThietBi'] ?? "")
            : "TB${DateTime.now().millisecondsSinceEpoch}",

        'soSeri': widget.isEdit
            ? (widget.initialData?['soSeri'] ?? "")
            : "SN-${DateTime.now().millisecondsSinceEpoch}",

        'tenThietBi': _nameController.text.trim(),
        'maDanhMuc': _selectedCategoryId != null
            ? int.tryParse(_selectedCategoryId!)
            : null,
        'hangSanXuat': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'giaThueNgay': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'giaTriTaiSan': double.tryParse(_assetValueController.text.trim()),
        'moTa': _descriptionController.text.trim(),
        'congSuat': _powerController.text.trim(),
        'trongLuong': _weightController.text.trim(),
        'dienAp': _voltageController.text.trim(),
        'trangThai': widget.isEdit
            ? (widget.initialData?['trangThai'] ?? 'SanSang')
            : 'SanSang',
      };

      if (widget.isEdit && widget.equipmentId != null) {
        await ApiService().put('/ThietBi/${widget.equipmentId}', body);
      } else {
        await ApiService().post('/ThietBi', body);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Thao tác thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Lỗi lưu thiết bị: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ==================== UI HELPERS ====================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      validator: (val) => (isRequired && (val == null || val.trim().isEmpty))
          ? 'Không được để trống'
          : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _assetValueController.dispose();
    _powerController.dispose();
    _weightController.dispose();
    _voltageController.dispose();
    super.dispose();
  }
}
