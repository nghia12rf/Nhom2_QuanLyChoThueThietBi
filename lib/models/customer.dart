class Customer {
  final int maKhachHang;
  final String maDinhDanhKhachHang;
  final String tenCongTy;
  final String nguoiDaiDien;
  final String soDienThoai;
  final String? email;
  final String? diaChi;
  final String? maSoThue;
  final DateTime? ngayTao;

  Customer({
    required this.maKhachHang,
    required this.maDinhDanhKhachHang,
    required this.tenCongTy,
    required this.nguoiDaiDien,
    required this.soDienThoai,
    this.email,
    this.diaChi,
    this.maSoThue,
    this.ngayTao,
  });

  // JSON -> Object
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      maKhachHang: json['maKhachHang'] ?? 0,

      maDinhDanhKhachHang:
          json['maDinhDanhKhachHang'] ?? '',

      tenCongTy: json['tenCongTy'] ?? '',

      nguoiDaiDien: json['nguoiDaiDien'] ?? '',

      soDienThoai: json['soDienThoai'] ?? '',

      email: json['email'],

      diaChi: json['diaChi'],

      maSoThue: json['maSoThue'],

      ngayTao:
          json['ngayTao'] != null
              ? DateTime.parse(json['ngayTao'])
              : null,
    );
  }

  // Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'maKhachHang': maKhachHang,
      'maDinhDanhKhachHang':
          maDinhDanhKhachHang,
      'tenCongTy': tenCongTy,
      'nguoiDaiDien': nguoiDaiDien,
      'soDienThoai': soDienThoai,
      'email': email,
      'diaChi': diaChi,
      'maSoThue': maSoThue,
      'ngayTao': ngayTao?.toIso8601String(),
    };
  }
}