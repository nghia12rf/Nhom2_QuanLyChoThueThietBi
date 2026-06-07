using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class ChiTietHopDong
{
    public int MaChiTietHopDong { get; set; }

    public int MaHopDong { get; set; }

    public int MaThietBi { get; set; }

    public decimal GiaThueThoiDiem { get; set; }

    public decimal ThanhTien { get; set; }

    public string? GhiChu { get; set; }

    public virtual HopDong MaHopDongNavigation { get; set; } = null!;

    public virtual ThietBi MaThietBiNavigation { get; set; } = null!;
}
