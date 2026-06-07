using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class GiaHanHopDong
{
    public int MaGiaHan { get; set; }

    public int MaHopDong { get; set; }

    public DateTime NgayKetThucCu { get; set; }
    public DateTime NgayKetThucMoi { get; set; }

    public decimal SoTienBoSung { get; set; }

    public string? LyDoGiaHan { get; set; }

    public int MaNguoiThucHien { get; set; }

    public DateTime? NgayTao { get; set; }

    public virtual HopDong MaHopDongNavigation { get; set; } = null!;

    public virtual NguoiDung MaNguoiThucHienNavigation { get; set; } = null!;
}
