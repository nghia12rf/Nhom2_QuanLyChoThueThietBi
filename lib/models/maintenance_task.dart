class MaintenanceTask {
  final String id;
  final int equipmentId;
  final String equipmentName;
  final String? damageReportId;
  final String technicianName;
  final DateTime scheduledAt;
  final String status;
  final String note;
  final double estimatedCost;
  final double actualCost;
  final DateTime? completedAt;

  const MaintenanceTask({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    this.damageReportId,
    required this.technicianName,
    required this.scheduledAt,
    required this.status,
    required this.note,
    required this.estimatedCost,
    this.actualCost = 0,
    this.completedAt,
  });

  MaintenanceTask copyWith({
    String? technicianName,
    DateTime? scheduledAt,
    String? status,
    String? note,
    double? estimatedCost,
    double? actualCost,
    DateTime? completedAt,
  }) {
    return MaintenanceTask(
      id: id,
      equipmentId: equipmentId,
      equipmentName: equipmentName,
      damageReportId: damageReportId,
      technicianName: technicianName ?? this.technicianName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      note: note ?? this.note,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      id: json['id'] as String? ?? '',
      equipmentId: json['equipmentId'] as int? ?? 0,
      equipmentName: json['equipmentName'] as String? ?? '',
      damageReportId: json['damageReportId'] as String?,
      technicianName: json['technicianName'] as String? ?? '',
      scheduledAt:
          DateTime.tryParse(json['scheduledAt']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'Chờ xử lý',
      note: json['note'] as String? ?? '',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
      actualCost: (json['actualCost'] as num?)?.toDouble() ?? 0,
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'damageReportId': damageReportId,
      'technicianName': technicianName,
      'scheduledAt': scheduledAt.toIso8601String(),
      'status': status,
      'note': note,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
