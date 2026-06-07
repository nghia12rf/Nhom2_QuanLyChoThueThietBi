using System;
using System.Collections.Generic;

namespace QuanLyChoThueThietBi.Models;

public partial class DanhMucThietBi
{
    public int MaDanhMuc { get; set; }

    public string TenDanhMuc { get; set; } = null!;

    public string? MoTa { get; set; }

    public virtual ICollection<ThietBi> ThietBis { get; set; } = new List<ThietBi>();
}
