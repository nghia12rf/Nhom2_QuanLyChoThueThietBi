using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class KhachHang
{
    public int MaKhachHang { get; set; }

    public string MaDinhDanhKhachHang { get; set; } = null!;

    public string TenCongTy { get; set; } = null!;

    public string NguoiDaiDien { get; set; } = null!;

    public string SoDienThoai { get; set; } = null!;

    public string? Email { get; set; }

    public string? DiaChi { get; set; }

    public string? MaSoThue { get; set; }

    public DateTime? NgayTao { get; set; }

    public virtual ICollection<HopDong> HopDongs { get; set; } = new List<HopDong>();
}
