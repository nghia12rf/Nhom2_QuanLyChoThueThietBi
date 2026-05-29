class LoginResponse {
  final String token;
  final String vaiTro;
  final String hoTen;
  final String tenDangNhap;

  LoginResponse({
    required this.token,
    required this.vaiTro,
    required this.hoTen,
    required this.tenDangNhap,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      vaiTro: json['vaiTro'] ?? '',
      hoTen: json['hoTen'] ?? '',
      tenDangNhap: json['tenDangNhap'] ?? '',
    );
  }
}
