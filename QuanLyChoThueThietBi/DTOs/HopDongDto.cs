namespace RentalEquipmentAPI.DTOs
{
    // DTO trả về khi lấy danh sách/chi tiết (Dùng cho GET)
    public class HopDongDto
    {
        public int MaHopDong { get; set; }
        public string MaDinhDanhHopDong { get; set; } = null!;
        public int MaKhachHang { get; set; }
        public string? TenKhachHang { get; set; } // Lấy từ MaKhachHangNavigation
        public DateTime NgayBatDau { get; set; }
        public DateTime NgayKetThucDuKien { get; set; }
        public DateTime? NgayKetThucThucTe { get; set; }
        public decimal TongTien { get; set; }
        public decimal TienCoc { get; set; }
        public string TrangThai { get; set; } = "DangHieuLuc";
        public string? GhiChu { get; set; }

        // Khởi tạo sẵn danh sách để tránh lỗi NullReferenceException
        public List<ChiTietHopDongDto> ChiTiet { get; set; } = new();
    }

    // DTO dùng khi tạo mới hợp đồng (Dùng cho POST)
    public class HopDongCreateDto
    {
        public string MaDinhDanhHopDong { get; set; } = null!;
        public int MaKhachHang { get; set; }
        public DateTime NgayBatDau { get; set; }
        public DateTime NgayKetThucDuKien { get; set; }
        public decimal TienCoc { get; set; }
        public string? GhiChu { get; set; }
        public List<ChiTietHopDongCreateDto> ChiTiet { get; set; } = new();
    }

    public class ChiTietHopDongDto
    {
        public int MaChiTietHopDong { get; set; }
        public int MaThietBi { get; set; }
        public string? TenThietBi { get; set; } // Lấy từ MaThietBiNavigation
        public decimal GiaThueThoiDiem { get; set; }
        public decimal ThanhTien { get; set; }
        public string? GhiChu { get; set; }
    }

    public class ChiTietHopDongCreateDto
    {
        public int MaThietBi { get; set; }
        public string? GhiChu { get; set; }
    }
}