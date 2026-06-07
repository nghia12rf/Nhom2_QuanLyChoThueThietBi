namespace RentalEquipmentAPI.DTOs
{
    public class ThietBiDto
    {
        public int MaThietBi { get; set; }
        public string MaDinhDanhThietBi { get; set; } = null!;
        public string TenThietBi { get; set; } = null!;
        public int? MaDanhMuc { get; set; }
        public string? HangSanXuat { get; set; }
        public string? Model { get; set; }
        public string SoSeri { get; set; } = null!; // Bắt buộc phải có
        public decimal GiaThueNgay { get; set; }
        public string? TrangThai { get; set; }
        public string? HinhAnhUrl { get; set; }

        // --- Các trường mới khớp với Flutter và SQL Nghĩa vừa sửa ---
        public string? MoTa { get; set; } // Sẽ map vào ThongSoKyThuat trong DB
        public string? CongSuat { get; set; }
        public string? TrongLuong { get; set; }
        public string? DienAp { get; set; }
    }
}