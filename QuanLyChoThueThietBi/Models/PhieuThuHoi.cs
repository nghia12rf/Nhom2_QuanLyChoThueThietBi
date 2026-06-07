using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class PhieuThuHoi
{
    public int MaPhieuThuHoi { get; set; }

    public int MaHopDong { get; set; }

    public DateTime NgayTra { get; set; }

    public int? SoNgayTre { get; set; }

    public decimal? TienPhatTre { get; set; }

    public decimal? PhiHuHong { get; set; }

    public decimal? TongTienPhaiThanhToan { get; set; }

    public bool? CoHuHong { get; set; }

    public string? GhiChuHuHong { get; set; }

    public string? DanhSachAnhHuHong { get; set; }

    public int MaNguoiNhan { get; set; }

    public DateTime? NgayTao { get; set; }

    public virtual HopDong MaHopDongNavigation { get; set; } = null!;

    public virtual NguoiDung MaNguoiNhanNavigation { get; set; } = null!;
}
