import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/models/damage_report.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/services/operations_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/widgets/common_widgets.dart';
import 'package:nhom2_quanlythietbichothue/widgets/vietnamese_text_field.dart';

class DamageReportScreen extends StatefulWidget {
  const DamageReportScreen({super.key});

  @override
  State<DamageReportScreen> createState() => _DamageReportScreenState();
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  final OperationsService _operationsService = OperationsService();
  final TextEditingController _reporterController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _resolutionController = TextEditingController();

  List<DamageReport> _reports = [];
  List<Map<String, dynamic>> _equipments = [];
  bool _isLoading = true;
  int? _selectedEquipmentId;
  String _selectedSeverity = 'Trung bình';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reporterController.dispose();
    _descriptionController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final reports = await _operationsService.getDamageReports();
    List<Map<String, dynamic>> equipments = [];

    try {
      final response = await ApiService().get('/ThietBi');
      final rawList = response is List ? response : response['data'] ?? [];
      equipments = rawList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Khong the tai thiet bi cho bao cao hong: $e');
    }

    if (!mounted) return;
    setState(() {
      _reports = reports;
      _equipments = equipments;
      _isLoading = false;
    });
  }

  Future<void> _saveReport() async {
    if (_selectedEquipmentId == null ||
        _reporterController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      _showMessage('Vui lòng nhập đủ thông tin báo hỏng');
      return;
    }

    final equipment = _equipments.firstWhere(
      (item) => _readInt(item['maThietBi']) == _selectedEquipmentId,
      orElse: () => {'tenThietBi': 'Thiết bị #$_selectedEquipmentId'},
    );

    final report = DamageReport(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      equipmentId: _selectedEquipmentId!,
      equipmentName: equipment['tenThietBi']?.toString() ?? '',
      reporterName: _reporterController.text.trim(),
      severity: _selectedSeverity,
      description: _descriptionController.text.trim(),
      status: 'Mới',
      reportedAt: DateTime.now(),
    );

    await _operationsService.saveDamageReport(report);
    _reporterController.clear();
    _descriptionController.clear();
    _selectedEquipmentId = null;
    _selectedSeverity = 'Trung bình';

    if (!mounted) return;
    Navigator.pop(context);
    _showMessage('Đã ghi nhận báo cáo hỏng hóc');
    await _loadData();
  }

  Future<void> _updateStatus(
    DamageReport report,
    String status, {
    String? note,
  }) async {
    final updated = report.copyWith(
      status: status,
      resolvedAt: status == 'Đã xử lý' ? DateTime.now() : null,
      resolutionNote: note,
    );
    await _operationsService.updateDamageReport(updated);
    await _loadData();
  }

  void _openReportForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Báo cáo hỏng hóc',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedEquipmentId,
                      decoration: const InputDecoration(
                        labelText: 'Thiết bị hỏng',
                        prefixIcon: Icon(Icons.precision_manufacturing),
                      ),
                      items: _equipments.map((item) {
                        final id = _readInt(item['maThietBi']);
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(item['tenThietBi']?.toString() ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setSheetState(() => _selectedEquipmentId = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSeverity,
                      decoration: const InputDecoration(
                        labelText: 'Mức độ',
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: const ['Nhẹ', 'Trung bình', 'Nặng', 'Khẩn cấp']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(
                          () => _selectedSeverity = value ?? 'Trung bình',
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reporterController,
                      decoration: const InputDecoration(
                        labelText: 'Người báo cáo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    VietnameseTextField(
                      controller: _descriptionController,
                      labelText: 'Mô tả sự cố',
                      prefixIcon: Icons.report_problem_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveReport,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Lưu báo cáo'),
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

  void _openResolveDialog(DamageReport report) {
    _resolutionController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn tất xử lý'),
        content: VietnameseTextField(
          controller: _resolutionController,
          labelText: 'Ghi chú xử lý',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateStatus(
                report,
                'Đã xử lý',
                note: _resolutionController.text.trim(),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo hỏng hóc')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _equipments.isEmpty ? null : _openReportForm,
        icon: const Icon(Icons.add),
        label: const Text('Báo hỏng'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _reports.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyStateWidget(
                          icon: Icons.build_circle_outlined,
                          title: 'Chưa có báo cáo hỏng hóc',
                          subtitle:
                              'Bấm nút Báo hỏng để ghi nhận sự cố thiết bị.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        return _ReportCard(
                          report: _reports[index],
                          onStart: () =>
                              _updateStatus(_reports[index], 'Đang xử lý'),
                          onResolve: () => _openResolveDialog(_reports[index]),
                        );
                      },
                    ),
            ),
    );
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReportCard extends StatelessWidget {
  final DamageReport report;
  final VoidCallback onStart;
  final VoidCallback onResolve;

  const _ReportCard({
    required this.report,
    required this.onStart,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(report.status);

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
                    report.equipmentName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusBadge(label: report.status, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text('Mức độ: ${report.severity}'),
            Text('Người báo: ${report.reporterName}'),
            Text('Ngày báo: ${_formatDate(report.reportedAt)}'),
            const SizedBox(height: 8),
            Text(report.description),
            if ((report.resolutionNote ?? '').isNotEmpty) ...[
              const Divider(height: 24),
              Text('Ghi chú xử lý: ${report.resolutionNote}'),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (report.status == 'Mới')
                  OutlinedButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Xử lý'),
                  ),
                const SizedBox(width: 8),
                if (report.status != 'Đã xử lý')
                  ElevatedButton.icon(
                    onPressed: onResolve,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Hoàn tất'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã xử lý':
        return AppTheme.successColor;
      case 'Đang xử lý':
        return AppTheme.warningColor;
      default:
        return AppTheme.errorColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
