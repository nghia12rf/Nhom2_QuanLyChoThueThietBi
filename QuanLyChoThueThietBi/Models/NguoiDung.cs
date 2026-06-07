using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class NguoiDung
{
    public int MaNguoiDung { get; set; }

    public string TenDangNhap { get; set; } = null!;

    public string MatKhauHash { get; set; } = null!;

    public string HoTen { get; set; } = null!;

    public string? Email { get; set; }

    public string VaiTro { get; set; } = null!;

    public bool? TrangThaiHoatDong { get; set; }

    public DateTime? NgayTao { get; set; }

    public virtual ICollection<GiaHanHopDong> GiaHanHopDongs { get; set; } = new List<GiaHanHopDong>();

    public virtual ICollection<HopDong> HopDongs { get; set; } = new List<HopDong>();

    public virtual ICollection<LichSuLuanChuyen> LichSuLuanChuyens { get; set; } = new List<LichSuLuanChuyen>();

    public virtual ICollection<PhieuThuHoi> PhieuThuHois { get; set; } = new List<PhieuThuHoi>();
}
