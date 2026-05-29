import 'dart:convert';

import 'package:nhom2_quanlythietbichothue/models/contract_extension.dart';
import 'package:nhom2_quanlythietbichothue/models/damage_report.dart';
import 'package:nhom2_quanlythietbichothue/models/maintenance_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OperationsService {
  static const String _damageReportsKey = 'damage_reports';
  static const String _maintenanceTasksKey = 'maintenance_tasks';
  static const String _contractExtensionsKey = 'contract_extensions';

  Future<List<DamageReport>> getDamageReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_damageReportsKey);
    if (raw == null || raw.isEmpty) return [];

    final data = jsonDecode(raw) as List<dynamic>;
    final reports = data
        .map((item) => DamageReport.fromJson(item as Map<String, dynamic>))
        .toList();
    reports.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return reports;
  }

  Future<void> saveDamageReport(DamageReport report) async {
    final reports = await getDamageReports();
    reports.insert(0, report);
    await _saveList(_damageReportsKey, reports.map((e) => e.toJson()).toList());
  }

  Future<void> updateDamageReport(DamageReport report) async {
    final reports = await getDamageReports();
    final index = reports.indexWhere((item) => item.id == report.id);
    if (index == -1) return;

    reports[index] = report;
    await _saveList(_damageReportsKey, reports.map((e) => e.toJson()).toList());
  }

  Future<List<MaintenanceTask>> getMaintenanceTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_maintenanceTasksKey);
    if (raw == null || raw.isEmpty) return [];

    final data = jsonDecode(raw) as List<dynamic>;
    final tasks = data
        .map((item) => MaintenanceTask.fromJson(item as Map<String, dynamic>))
        .toList();
    tasks.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return tasks;
  }

  Future<void> saveMaintenanceTask(MaintenanceTask task) async {
    final tasks = await getMaintenanceTasks();
    tasks.insert(0, task);
    await _saveList(
      _maintenanceTasksKey,
      tasks.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> updateMaintenanceTask(MaintenanceTask task) async {
    final tasks = await getMaintenanceTasks();
    final index = tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) return;

    tasks[index] = task;
    await _saveList(
      _maintenanceTasksKey,
      tasks.map((e) => e.toJson()).toList(),
    );
  }

  Future<List<ContractExtension>> getContractExtensions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_contractExtensionsKey);
    if (raw == null || raw.isEmpty) return [];

    final data = jsonDecode(raw) as List<dynamic>;
    final extensions = data
        .map((item) => ContractExtension.fromJson(item as Map<String, dynamic>))
        .toList();
    extensions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return extensions;
  }

  Future<void> saveContractExtension(ContractExtension extension) async {
    final extensions = await getContractExtensions();
    extensions.insert(0, extension);
    await _saveList(
      _contractExtensionsKey,
      extensions.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> updateContractExtension(ContractExtension extension) async {
    final extensions = await getContractExtensions();
    final index = extensions.indexWhere((item) => item.id == extension.id);
    if (index == -1) return;

    extensions[index] = extension;
    await _saveList(
      _contractExtensionsKey,
      extensions.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }
}
