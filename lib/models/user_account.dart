class UserAccount {
  final int maNguoiDung;
  final String tenDangNhap;
  final String hoTen;
  final String? email;
  final String vaiTro;
  final bool trangThaiHoatDong;
  final String? ngayTao;

  UserAccount({
    required this.maNguoiDung,
    required this.tenDangNhap,
    required this.hoTen,
    this.email,
    required this.vaiTro,
    required this.trangThaiHoatDong,
    this.ngayTao,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      maNguoiDung: json['maNguoiDung'] as int? ?? 0,
      tenDangNhap: json['tenDangNhap'] as String? ?? '',
      hoTen: json['hoTen'] as String? ?? '',
      email: json['email'] as String?,
      vaiTro: json['vaiTro'] as String? ?? 'Employee',
      trangThaiHoatDong: json['trangThaiHoatDong'] as bool? ?? true,
      ngayTao: json['ngayTao'] as String?,
    );
  }
}