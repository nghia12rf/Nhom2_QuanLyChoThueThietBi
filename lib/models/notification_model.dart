class NotificationModel {
  final int maThongBao;
  final String tieuDe;
  final String noiDung;
  final String loaiThongBao;
  final bool daDoc;
  final DateTime? ngayTao;

  NotificationModel({
    required this.maThongBao,
    required this.tieuDe,
    required this.noiDung,
    required this.loaiThongBao,
    required this.daDoc,
    this.ngayTao,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      maThongBao: json['maThongBao'] ?? 0,
      tieuDe: json['tieuDe'] ?? '',
      noiDung: json['noiDung'] ?? '',
      loaiThongBao: json['loaiThongBao'] ?? '',
      daDoc: json['daDoc'] ?? false,
      ngayTao: json['ngayTao'] != null
          ? DateTime.tryParse(json['ngayTao'].toString())
          : null,
    );
  }
}