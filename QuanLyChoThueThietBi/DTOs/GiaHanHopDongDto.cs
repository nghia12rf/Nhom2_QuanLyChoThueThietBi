public class GiaHanHopDongDto
{
    public int MaGiaHan { get; set; }
    public int MaHopDong { get; set; }
    public DateTime NgayKetThucCu { get; set; }
    public DateTime NgayKetThucMoi { get; set; }
    public int SoNgayGiaHan { get; set; }
    public decimal SoTienBoSung { get; set; }
    public string? LyDoGiaHan { get; set; }
    public int MaNguoiThucHien { get; set; }
}

public class GiaHanCreateDto
{
    public int MaHopDong { get; set; }
    public DateTime NgayKetThucMoi { get; set; }
    public string? LyDoGiaHan { get; set; }
}