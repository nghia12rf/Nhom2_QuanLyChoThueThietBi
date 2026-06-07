using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class HopDong
{
    public int MaHopDong { get; set; }

    public string MaDinhDanhHopDong { get; set; } = null!;

    public int MaKhachHang { get; set; }

    public DateTime NgayBatDau { get; set; }
    public DateTime NgayKetThucDuKien { get; set; }
    public DateTime? NgayKetThucThucTe { get; set; }

    public decimal TongTien { get; set; }

    public decimal? TienCoc { get; set; }

    public string? TrangThai { get; set; }

    public int MaNguoiTao { get; set; }

    public DateTime? NgayTao { get; set; }

    public string? GhiChu { get; set; }

    public virtual ICollection<ChiTietHopDong> ChiTietHopDongs { get; set; } = new List<ChiTietHopDong>();

    public virtual ICollection<GiaHanHopDong> GiaHanHopDongs { get; set; } = new List<GiaHanHopDong>();

    public virtual ICollection<LichSuLuanChuyen> LichSuLuanChuyens { get; set; } = new List<LichSuLuanChuyen>();

    public virtual KhachHang MaKhachHangNavigation { get; set; } = null!;

    public virtual NguoiDung MaNguoiTaoNavigation { get; set; } = null!;

    public virtual ICollection<PhieuThuHoi> PhieuThuHois { get; set; } = new List<PhieuThuHoi>();
}
