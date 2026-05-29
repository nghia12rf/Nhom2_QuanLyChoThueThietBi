import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/models/contract_extension.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/services/operations_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/widgets/common_widgets.dart';
import 'package:nhom2_quanlythietbichothue/widgets/vietnamese_text_field.dart';

class ContractExtensionScreen extends StatefulWidget {
  final bool canApprove;

  const ContractExtensionScreen({super.key, this.canApprove = false});

  @override
  State<ContractExtensionScreen> createState() =>
      _ContractExtensionScreenState();
}

class _ContractExtensionScreenState extends State<ContractExtensionScreen> {
  final OperationsService _operationsService = OperationsService();
  final TextEditingController _reasonController = TextEditingController();

  List<Map<String, dynamic>> _contracts = [];
  List<ContractExtension> _extensions = [];
  bool _isLoading = true;
  DateTime _newEndDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final extensions = await _operationsService.getContractExtensions();
    List<Map<String, dynamic>> contracts = [];

    try {
      final response = await ApiService().get('/HopDong');
      final rawList = response is List ? response : response['data'] ?? [];
      contracts = rawList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Khong the tai hop dong de gia han: $e');
    }

    if (!mounted) return;
    setState(() {
      _contracts = contracts;
      _extensions = extensions;
      _isLoading = false;
    });
  }

  Future<void> _saveExtension(Map<String, dynamic> contract) async {
    if (_reasonController.text.trim().isEmpty) {
      _showMessage('Vui lòng nhập lý do gia hạn');
      return;
    }

    final oldEndDate = _readDate(contract['ngayKetThucDuKien']);
    final extension = ContractExtension(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      contractId: _readInt(contract['maHopDong']),
      contractCode: contract['maDinhDanhHopDong']?.toString() ?? '',
      customerName: contract['tenKhachHang']?.toString() ?? 'Chưa rõ',
      oldEndDate: oldEndDate,
      newEndDate: _newEndDate,
      reason: _reasonController.text.trim(),
      status: 'Chờ duyệt',
      createdAt: DateTime.now(),
    );

    await _operationsService.saveContractExtension(extension);
    _reasonController.clear();

    if (!mounted) return;
    Navigator.pop(context);
    _showMessage('Đã gửi yêu cầu gia hạn hợp đồng');
    await _loadData();
  }

  Future<void> _updateExtension(
    ContractExtension extension,
    String status,
  ) async {
    await _operationsService.updateContractExtension(
      extension.copyWith(status: status),
    );
    await _loadData();
  }

  void _openExtensionDialog(Map<String, dynamic> contract) {
    final oldEndDate = _readDate(contract['ngayKetThucDuKien']);
    _newEndDate = (oldEndDate ?? DateTime.now()).add(const Duration(days: 7));
    _reasonController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Gia hạn ${contract['maDinhDanhHopDong'] ?? 'hợp đồng'}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khách hàng: ${contract['tenKhachHang'] ?? 'Chưa rõ'}',
                    ),
                    Text(
                      'Hạn hiện tại: ${oldEndDate == null ? 'Chưa có' : _formatDate(oldEndDate)}',
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_repeat_outlined),
                      title: const Text('Hạn mới'),
                      subtitle: Text(_formatDate(_newEndDate)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _newEndDate,
                          firstDate: oldEndDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 730),
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => _newEndDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    VietnameseTextField(
                      controller: _reasonController,
                      labelText: 'Lý do gia hạn',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => _saveExtension(contract),
                  child: const Text('Ghi nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gia hạn hợp đồng'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Hợp đồng'),
              Tab(
                text: widget.canApprove ? 'Lịch sử gia hạn' : 'Yêu cầu đã gửi',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: TabBarView(
                  children: [_buildContractList(), _buildExtensionHistory()],
                ),
              ),
      ),
    );
  }

  Widget _buildContractList() {
    if (_contracts.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyStateWidget(
            icon: Icons.assignment_outlined,
            title: 'Chưa có hợp đồng',
            subtitle: 'Không tải được danh sách hợp đồng từ API.',
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _contracts.length,
      itemBuilder: (context, index) {
        final contract = _contracts[index];
        final endDate = _readDate(contract['ngayKetThucDuKien']);
        final status = contract['trangThai']?.toString() ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contract['maDinhDanhHopDong']?.toString() ?? 'N/A',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    StatusBadge(
                      label: status.isEmpty ? 'Không rõ' : status,
                      color: status == 'QuaHan'
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Khách hàng: ${contract['tenKhachHang'] ?? 'Chưa rõ'}'),
                Text(
                  'Hạn trả: ${endDate == null ? 'Chưa có' : _formatDate(endDate)}',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openExtensionDialog(contract),
                    icon: const Icon(Icons.event_repeat_outlined),
                    label: const Text('Gia hạn hợp đồng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExtensionHistory() {
    if (_extensions.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyStateWidget(
            icon: Icons.history_outlined,
            title: 'Chưa có lịch sử gia hạn',
            subtitle: 'Các lần gia hạn sẽ hiển thị tại đây.',
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _extensions.length,
      itemBuilder: (context, index) {
        final extension = _extensions[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        extension.contractCode,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    StatusBadge(
                      label: extension.status,
                      color: _extensionStatusColor(extension.status),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Khách hàng: ${extension.customerName}'),
                Text(
                  'Hạn cũ: ${extension.oldEndDate == null ? 'Chưa có' : _formatDate(extension.oldEndDate!)}',
                ),
                Text('Hạn mới: ${_formatDate(extension.newEndDate)}'),
                Text('Lý do: ${extension.reason}'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (widget.canApprove && _isPending(extension.status))
                      ElevatedButton.icon(
                        onPressed: () =>
                            _updateExtension(extension, 'Đã duyệt'),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Duyệt'),
                      ),
                    const SizedBox(width: 8),
                    if (widget.canApprove && _isPending(extension.status))
                      OutlinedButton.icon(
                        onPressed: () => _updateExtension(extension, 'Từ chối'),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Từ chối'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _readDate(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }

  bool _isPending(String status) {
    return status == 'Chờ duyệt' || status == 'Đã ghi nhận';
  }

  Color _extensionStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
        return AppTheme.successColor;
      case 'Từ chối':
      case 'Đã hủy':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
