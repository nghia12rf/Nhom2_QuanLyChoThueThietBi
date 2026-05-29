class ContractExtension {
  final String id;
  final int contractId;
  final String contractCode;
  final String customerName;
  final DateTime? oldEndDate;
  final DateTime newEndDate;
  final String reason;
  final String status;
  final DateTime createdAt;

  const ContractExtension({
    required this.id,
    required this.contractId,
    required this.contractCode,
    required this.customerName,
    required this.oldEndDate,
    required this.newEndDate,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  ContractExtension copyWith({String? status}) {
    return ContractExtension(
      id: id,
      contractId: contractId,
      contractCode: contractCode,
      customerName: customerName,
      oldEndDate: oldEndDate,
      newEndDate: newEndDate,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  factory ContractExtension.fromJson(Map<String, dynamic> json) {
    return ContractExtension(
      id: json['id'] as String? ?? '',
      contractId: json['contractId'] as int? ?? 0,
      contractCode: json['contractCode'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      oldEndDate: DateTime.tryParse(json['oldEndDate']?.toString() ?? ''),
      newEndDate:
          DateTime.tryParse(json['newEndDate']?.toString() ?? '') ??
          DateTime.now(),
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'Đã ghi nhận',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractId': contractId,
      'contractCode': contractCode,
      'customerName': customerName,
      'oldEndDate': oldEndDate?.toIso8601String(),
      'newEndDate': newEndDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
