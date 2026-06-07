using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class LichSuLuanChuyen
{
    public int MaLuanChuyen { get; set; }

    public int MaThietBi { get; set; }

    public string? LoaiLuanChuyen { get; set; }

    public int? MaHopDongLienQuan { get; set; }

    public string? TrangThaiTruoc { get; set; }

    public string? TrangThaiSau { get; set; }

    public string? GhiChu { get; set; }

    public int MaNguoiThucHien { get; set; }

    public DateTime? NgayTao { get; set; }

    public virtual HopDong? MaHopDongLienQuanNavigation { get; set; }

    public virtual NguoiDung MaNguoiThucHienNavigation { get; set; } = null!;

    public virtual ThietBi MaThietBiNavigation { get; set; } = null!;
}
