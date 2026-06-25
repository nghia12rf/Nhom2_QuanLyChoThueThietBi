import 'package:flutter/material.dart';
import 'package:nhom2_quanlythietbichothue/models/damage_report.dart';
import 'package:nhom2_quanlythietbichothue/models/maintenance_task.dart';
import 'package:nhom2_quanlythietbichothue/services/api_service.dart';
import 'package:nhom2_quanlythietbichothue/services/operations_service.dart';
import 'package:nhom2_quanlythietbichothue/theme/app_theme.dart';
import 'package:nhom2_quanlythietbichothue/widgets/common_widgets.dart';
import 'package:nhom2_quanlythietbichothue/widgets/vietnamese_text_field.dart';

class MaintenanceManagementScreen extends StatefulWidget {
  const MaintenanceManagementScreen({super.key});

  @override
  State<MaintenanceManagementScreen> createState() =>
      _MaintenanceManagementScreenState();
}

class _MaintenanceManagementScreenState
    extends State<MaintenanceManagementScreen> {
  final OperationsService _operationsService = OperationsService();
  final TextEditingController _technicianController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _estimatedCostController = TextEditingController(
    text: '0',
  );
  final TextEditingController _actualCostController = TextEditingController(
    text: '0',
  );

  List<MaintenanceTask> _tasks = [];
  List<DamageReport> _openReports = [];
  List<Map<String, dynamic>> _equipments = [];
  bool _isLoading = true;
  int? _selectedEquipmentId;
  String? _selectedReportId;
  DateTime _scheduledAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _technicianController.dispose();
    _noteController.dispose();
    _estimatedCostController.dispose();
    _actualCostController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final tasks = await _operationsService.getMaintenanceTasks();
    final reports = await _operationsService.getDamageReports();
    List<Map<String, dynamic>> equipments = [];

    try {
      final response = await ApiService().get('/ThietBi');
      final rawList = response is List ? response : response['data'] ?? [];
      equipments = rawList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Khong the tai thiet bi cho bao tri: $e');
    }

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _openReports = reports
          .where((report) => report.status != 'Đã xử lý')
          .toList();
      _equipments = equipments;
      _isLoading = false;
    });
  }

  Future<void> _saveTask() async {
    if (_selectedEquipmentId == null || _technicianController.text.isEmpty) {
      _showMessage('Vui lòng chọn thiết bị và nhập kỹ thuật viên');
      return;
    }

    final equipment = _equipments.firstWhere(
      (item) => _readInt(item['maThietBi']) == _selectedEquipmentId,
      orElse: () => {'tenThietBi': 'Thiết bị #$_selectedEquipmentId'},
    );

    final task = MaintenanceTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      equipmentId: _selectedEquipmentId!,
      equipmentName: equipment['tenThietBi']?.toString() ?? '',
      damageReportId: _selectedReportId,
      technicianName: _technicianController.text.trim(),
      scheduledAt: _scheduledAt,
      status: 'Chờ xử lý',
      note: _noteController.text.trim(),
      estimatedCost: double.tryParse(_estimatedCostController.text) ?? 0,
    );

    await _operationsService.saveMaintenanceTask(task);

    if (_selectedReportId != null) {
      final report = _openReports.firstWhere(
        (item) => item.id == _selectedReportId,
      );
      await _operationsService.updateDamageReport(
        report.copyWith(status: 'Đang xử lý'),
      );
    }

    _clearForm();
    if (!mounted) return;
    Navigator.pop(context);
    _showMessage('Đã tạo phiếu bảo trì');
    await _loadData();
  }

  Future<void> _updateTask(MaintenanceTask task, String status) async {
    await _operationsService.updateMaintenanceTask(
      task.copyWith(status: status),
    );
    await _loadData();
  }

  Future<void> _completeTask(MaintenanceTask task) async {
    final cost = double.tryParse(_actualCostController.text) ?? 0;
    
    // Gọi API cập nhật trạng thái thiết bị thành Sẵn sàng trên backend SQL Server
    try {
      await ApiService().put(
        '/ThietBi/${task.equipmentId}/TrangThai',
        {'trangThai': 'SanSang'},
      );
    } catch (e) {
      debugPrint('[API ERROR updating status to SanSang]: ${e.toString()}');
      _showMessage('Lỗi đồng bộ trạng thái thiết bị lên máy chủ: $e');
    }

    await _operationsService.updateMaintenanceTask(
      task.copyWith(
        status: 'Hoàn thành',
        actualCost: cost,
        completedAt: DateTime.now(),
      ),
    );

    if (task.damageReportId != null) {
      final reports = await _operationsService.getDamageReports();
      final index = reports.indexWhere(
        (item) => item.id == task.damageReportId,
      );
      if (index != -1) {
        await _operationsService.updateDamageReport(
          reports[index].copyWith(
            status: 'Đã xử lý',
            resolvedAt: DateTime.now(),
            resolutionNote: 'Đã hoàn thành phiếu bảo trì ${task.id}',
          ),
        );
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
    _showMessage('Đã hoàn tất bảo trì thiết bị');
    await _loadData();
  }

  void _openTaskForm() {
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
                      'Tạo phiếu bảo trì',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedReportId,
                      decoration: const InputDecoration(
                        labelText: 'Báo cáo hỏng liên quan',
                        prefixIcon: Icon(Icons.report_problem_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Không liên kết báo cáo'),
                        ),
                        ..._openReports.map(
                          (report) => DropdownMenuItem<String>(
                            value: report.id,
                            child: Text(report.equipmentName),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setSheetState(() {
                          _selectedReportId = value;
                          final matches = _openReports.where(
                            (item) => item.id == value,
                          );
                          if (matches.isNotEmpty) {
                            _selectedEquipmentId = matches.first.equipmentId;
                            _noteController.text = matches.first.description;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedEquipmentId,
                      decoration: const InputDecoration(
                        labelText: 'Thiết bị bảo trì',
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
                    TextField(
                      controller: _technicianController,
                      decoration: const InputDecoration(
                        labelText: 'Kỹ thuật viên phụ trách',
                        prefixIcon: Icon(Icons.engineering_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Ngày bảo trì dự kiến'),
                      subtitle: Text(_formatDate(_scheduledAt)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _scheduledAt,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setSheetState(() => _scheduledAt = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _estimatedCostController,
                      decoration: const InputDecoration(
                        labelText: 'Chi phí dự kiến',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    VietnameseTextField(
                      controller: _noteController,
                      labelText: 'Nội dung bảo trì',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveTask,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Lưu phiếu bảo trì'),
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

  void _openCompleteDialog(MaintenanceTask task) {
    _actualCostController.text = task.estimatedCost.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoàn tất bảo trì'),
        content: TextField(
          controller: _actualCostController,
          decoration: const InputDecoration(labelText: 'Chi phí thực tế'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => _completeTask(task),
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý bảo trì')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _equipments.isEmpty ? null : _openTaskForm,
        icon: const Icon(Icons.add),
        label: const Text('Tạo phiếu'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _tasks.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyStateWidget(
                          icon: Icons.home_repair_service_outlined,
                          title: 'Chưa có phiếu bảo trì',
                          subtitle:
                              'Tạo phiếu để theo dõi lịch sửa chữa thiết bị.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return _MaintenanceCard(
                          task: task,
                          onStart: () => _updateTask(task, 'Đang bảo trì'),
                          onComplete: () => _openCompleteDialog(task),
                        );
                      },
                    ),
            ),
    );
  }

  void _clearForm() {
    _selectedEquipmentId = null;
    _selectedReportId = null;
    _scheduledAt = DateTime.now();
    _technicianController.clear();
    _noteController.clear();
    _estimatedCostController.text = '0';
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

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceTask task;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const _MaintenanceCard({
    required this.task,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(task.status);

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
                    task.equipmentName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                StatusBadge(label: task.status, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text('Kỹ thuật viên: ${task.technicianName}'),
            Text('Lịch bảo trì: ${_formatDate(task.scheduledAt)}'),
            Text('Chi phí dự kiến: ${task.estimatedCost.toStringAsFixed(0)}đ'),
            if (task.actualCost > 0)
              Text('Chi phí thực tế: ${task.actualCost.toStringAsFixed(0)}đ'),
            if (task.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task.note),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (task.status == 'Chờ xử lý')
                  OutlinedButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.construction_outlined),
                    label: const Text('Bắt đầu'),
                  ),
                const SizedBox(width: 8),
                if (task.status != 'Hoàn thành')
                  ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.task_alt_outlined),
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
      case 'Hoàn thành':
        return AppTheme.successColor;
      case 'Đang bảo trì':
        return AppTheme.warningColor;
      default:
        return AppTheme.infoColor;
    }
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
