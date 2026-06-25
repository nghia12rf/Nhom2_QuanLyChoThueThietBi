class DamageReport {
  final String id;
  final int equipmentId;
  final String equipmentName;
  final String reporterName;
  final String severity;
  final String description;
  final String status;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  const DamageReport({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.reporterName,
    required this.severity,
    required this.description,
    required this.status,
    required this.reportedAt,
    this.resolvedAt,
    this.resolutionNote,
  });

  DamageReport copyWith({
    String? status,
    DateTime? resolvedAt,
    String? resolutionNote,
  }) {
    return DamageReport(
      id: id,
      equipmentId: equipmentId,
      equipmentName: equipmentName,
      reporterName: reporterName,
      severity: severity,
      description: description,
      status: status ?? this.status,
      reportedAt: reportedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }

  factory DamageReport.fromJson(Map<String, dynamic> json) {
    return DamageReport(
      id: json['id'] as String? ?? '',
      equipmentId: json['equipmentId'] as int? ?? 0,
      equipmentName: json['equipmentName'] as String? ?? '',
      reporterName: json['reporterName'] as String? ?? '',
      severity: json['severity'] as String? ?? 'Trung bình',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'Mới',
      reportedAt:
          DateTime.tryParse(json['reportedAt']?.toString() ?? '') ??
          DateTime.now(),
      resolvedAt: DateTime.tryParse(json['resolvedAt']?.toString() ?? ''),
      resolutionNote: json['resolutionNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'reporterName': reporterName,
      'severity': severity,
      'description': description,
      'status': status,
      'reportedAt': reportedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolutionNote': resolutionNote,
    };
  }
}
