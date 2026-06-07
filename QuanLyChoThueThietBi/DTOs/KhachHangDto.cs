namespace RentalEquipmentAPI.DTOs
{
    public class KhachHangDto
    {
        public int MaKhachHang { get; set; }
        public string MaDinhDanhKhachHang { get; set; } = null!;

        // Nghĩa bổ sung dòng này để khớp với MappingProfile
        public string TenKhachHang { get; set; } = null!;

        public string NguoiDaiDien { get; set; } = null!;
        public string SoDienThoai { get; set; } = null!;
        public string? Email { get; set; }
        public string? DiaChi { get; set; }
        public string? MaSoThue { get; set; }
    }
}