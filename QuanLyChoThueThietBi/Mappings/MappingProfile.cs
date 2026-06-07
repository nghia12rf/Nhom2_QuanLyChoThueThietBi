using AutoMapper;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        // --- 1. THIẾT BỊ ---
        CreateMap<ThietBi, ThietBiDto>()
            .ForMember(dest => dest.MoTa, opt => opt.MapFrom(src => src.ThongSoKyThuat))
            .ReverseMap()
            .ForMember(dest => dest.ThongSoKyThuat, opt => opt.MapFrom(src => src.MoTa));

        // --- 2. KHÁCH HÀNG ---
        CreateMap<KhachHang, KhachHangDto>()
            .ForMember(dest => dest.TenKhachHang, opt => opt.MapFrom(src => src.TenCongTy))
            .ReverseMap()
            .ForMember(dest => dest.TenCongTy, opt => opt.MapFrom(src => src.TenKhachHang));

        // --- 3. DANH MỤC THIẾT BỊ ---
        CreateMap<DanhMucThietBi, DanhMucThietBiDto>().ReverseMap();

        // --- 4. CHI TIẾT HỢP ĐỒNG ---
        // Thêm ReverseMap để hỗ trợ chuyển đổi ngược khi lưu dữ liệu từ DTO vào DB
        CreateMap<ChiTietHopDong, ChiTietHopDongDto>()
            .ForMember(dest => dest.TenThietBi, opt => opt.MapFrom(src =>
                src.MaThietBiNavigation != null ? src.MaThietBiNavigation.TenThietBi : null))
            .ReverseMap();

        CreateMap<ChiTietHopDongCreateDto, ChiTietHopDong>();

        // --- 5. HỢP ĐỒNG ---
        CreateMap<HopDong, HopDongDto>()
            .ForMember(dest => dest.TenKhachHang, opt => opt.MapFrom(src =>
                src.MaKhachHangNavigation != null ? src.MaKhachHangNavigation.TenCongTy : null))
            .ForMember(dest => dest.ChiTiet, opt => opt.MapFrom(src => src.ChiTietHopDongs))
            .ReverseMap()
            // Ánh xạ ngược danh sách từ ChiTiet (DTO) vào ChiTietHopDongs (Model)
            .ForMember(dest => dest.ChiTietHopDongs, opt => opt.MapFrom(src => src.ChiTiet))
            // Bỏ qua navigation property của khách hàng để tránh lỗi khi cập nhật
            .ForMember(dest => dest.MaKhachHangNavigation, opt => opt.Ignore());

        // Mapping dành cho thao tác tạo mới hợp đồng
        CreateMap<HopDongCreateDto, HopDong>()
            .ForMember(dest => dest.ChiTietHopDongs, opt => opt.MapFrom(src => src.ChiTiet));

        // --- 6. PHIẾU THU HỒI ---
        CreateMap<PhieuThuHoi, PhieuThuHoiDto>().ReverseMap();
        CreateMap<PhieuThuHoiCreateDto, PhieuThuHoi>();

        // --- 7. GIA HẠN HỢP ĐỒNG ---
        // Sửa lỗi 'Int32 Days' bằng cách sử dụng phương thức Subtract và TotalDays rõ ràng
        CreateMap<GiaHanHopDong, GiaHanHopDongDto>()
            .ForMember(dest => dest.SoNgayGiaHan, opt =>
                opt.MapFrom(src => (int)src.NgayKetThucMoi.Subtract(src.NgayKetThucCu).TotalDays))
            .ReverseMap();

        CreateMap<GiaHanCreateDto, GiaHanHopDong>();
    }
}