class Equipment {
  final int maThietBi;
  final String tenThietBi;
  final double giaThueNgay;
  final String trangThai; // 'SanSang', 'DangChoThue', 'BaoTri'
  final String? imageUrl;
  final String? moTa;

  Equipment({
    required this.maThietBi,
    required this.tenThietBi,
    required this.giaThueNgay,
    required this.trangThai,
    this.imageUrl,
    this.moTa,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      maThietBi: json['maThietBi'] as int? ?? 0,
      tenThietBi: json['tenThietBi'] as String? ?? '',
      giaThueNgay: (json['giaThueNgay'] as num?)?.toDouble() ?? 0.0,
      trangThai: json['trangThai'] as String? ?? 'SanSang',
      imageUrl: json['imageUrl'] as String?,
      moTa: json['moTa'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maThietBi': maThietBi,
      'tenThietBi': tenThietBi,
      'giaThueNgay': giaThueNgay,
      'trangThai': trangThai,
      'imageUrl': imageUrl,
      'moTa': moTa,
    };
  }
}

class Contract {
  final int maHopDong;
  final String tenKhachHang;
  final String maDinhDanhHopDong;
  final String trangThai; // 'DangHieuLuc', 'QuaHan'
  final String? ngayBatDau;
  final String? ngayKetThuc;

  Contract({
    required this.maHopDong,
    required this.tenKhachHang,
    required this.maDinhDanhHopDong,
    required this.trangThai,
    this.ngayBatDau,
    this.ngayKetThuc,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      maHopDong: json['maHopDong'] as int? ?? 0,
      tenKhachHang: json['tenKhachHang'] as String? ?? '',
      maDinhDanhHopDong: json['maDinhDanhHopDong'] as String? ?? '',
      trangThai: json['trangThai'] as String? ?? 'DangHieuLuc',
      ngayBatDau: json['ngayBatDau'] as String?,
      ngayKetThuc: json['ngayKetThuc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maHopDong': maHopDong,
      'tenKhachHang': tenKhachHang,
      'maDinhDanhHopDong': maDinhDanhHopDong,
      'trangThai': trangThai,
      'ngayBatDau': ngayBatDau,
      'ngayKetThuc': ngayKetThuc,
    };
  }
}
