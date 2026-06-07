using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class ThietBi
{
    public int MaThietBi { get; set; }

    public string MaDinhDanhThietBi { get; set; } = null!;

    public string TenThietBi { get; set; } = null!;

    public int? MaDanhMuc { get; set; }

    public string? HangSanXuat { get; set; }

    public string? Model { get; set; }

    public string SoSeri { get; set; } = null!;

    public decimal GiaThueNgay { get; set; }

    public decimal? GiaTriTaiSan { get; set; }

    public string? TrangThai { get; set; }

    // Lưu ý: Trường này vẫn giữ nguyên trong DB để map với "MoTa" bên Flutter
    public string? ThongSoKyThuat { get; set; }

    public string? HinhAnhUrl { get; set; }

    public DateTime? NgayTao { get; set; }


    public string? CongSuat { get; set; }

    public string? TrongLuong { get; set; }

    public string? DienAp { get; set; }
    // -----------------------------------------

    public virtual ICollection<ChiTietHopDong> ChiTietHopDongs { get; set; } = new List<ChiTietHopDong>();

    public virtual ICollection<LichSuLuanChuyen> LichSuLuanChuyens { get; set; } = new List<LichSuLuanChuyen>();

    public virtual DanhMucThietBi? MaDanhMucNavigation { get; set; }
}