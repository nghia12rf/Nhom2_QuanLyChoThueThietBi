using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Yêu cầu đính kèm Bearer Token từ Flutter
    public class PhieuThuHoiController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;
        private const decimal TIEN_PHAT_MOI_NGAY = 100000; // Phạt 100.000đ/ngày trễ

        public PhieuThuHoiController(QuanLyChoThueThietBiContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userIdClaim == null) return 0;
            return int.Parse(userIdClaim);
        }

        // POST: api/PhieuThuHoi
        [HttpPost]
        public async Task<ActionResult> PostPhieuThuHoi([FromBody] PhieuThuHoiCreateDto dto)
        {
            if (dto == null || dto.MaHopDong <= 0)
            {
                return BadRequest(new { message = "Dữ liệu yêu cầu thanh toán không hợp lệ!" });
            }

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 1. Tìm kiếm hợp đồng
                var hopDong = await _context.HopDongs
                    .Include(h => h.ChiTietHopDongs)
                    .FirstOrDefaultAsync(h => h.MaHopDong == dto.MaHopDong);

                if (hopDong == null)
                    return BadRequest(new { message = $"Không tìm thấy hợp đồng có mã số {dto.MaHopDong}." });

                if (hopDong.TrangThai == "DaKetThuc")
                    return BadRequest(new { message = "Hợp đồng này đã được quyết toán đóng trước đó." });

                // 2. Xác thực người thực hiện & Tránh sập khóa ngoại (FK) nếu thiếu Token từ Flutter
                int currentUserId = GetCurrentUserId();
                if (currentUserId <= 0)
                {
                    // Lấy ID đầu tiên trong bảng NguoiDung làm fallback phòng hờ
                    var defaultUser = await _context.NguoiDungs.Select(u => u.MaNguoiDung).FirstOrDefaultAsync();
                    if (defaultUser > 0)
                    {
                        currentUserId = defaultUser;
                    }
                    else
                    {
                        // Nếu DB trống rỗng hoàn toàn, bắt buộc dùng ID = 1 (Phải đảm bảo DB đã được chèn sẵn ID = 1)
                        currentUserId = 1;
                    }
                }

                // 3. Tính toán thời gian trễ (Lấy trực tiếp giờ Server cho chuẩn xác)
                DateTime ngayTraThucTe = DateTime.Now;
                int soNgayTre = 0;
                decimal tienPhatTre = 0;

                DateTime ngayDuKien = hopDong.NgayKetThucDuKien;
                TimeSpan hieuNgay = ngayTraThucTe.Date - ngayDuKien.Date;
                if (hieuNgay.Days > 0)
                {
                    soNgayTre = hieuNgay.Days;
                    tienPhatTre = soNgayTre * TIEN_PHAT_MOI_NGAY;
                }

                // 4. Tính toán dòng tiền thu thực tế
                decimal phiHuHong = dto.PhiHuHong;
                decimal tienCoc = hopDong.TienCoc ?? 0;
                decimal tongTienHopDong = hopDong.TongTien;

                decimal tongPhaiThanhToan = tongTienHopDong + tienPhatTre + phiHuHong - tienCoc;
                if (tongPhaiThanhToan < 0) tongPhaiThanhToan = 0;

                // 5. Tạo phiếu thu hồi
                var phieu = new PhieuThuHoi
                {
                    MaHopDong = dto.MaHopDong,
                    NgayTra = ngayTraThucTe,
                    SoNgayTre = soNgayTre,
                    TienPhatTre = tienPhatTre,
                    PhiHuHong = phiHuHong,
                    TongTienPhaiThanhToan = tongPhaiThanhToan,
                    CoHuHong = dto.CoHuHong,
                    GhiChuHuHong = dto.GhiChuHuHong ?? "",
                    DanhSachAnhHuHong = dto.DanhSachAnhHuHong ?? "",
                    MaNguoiNhan = currentUserId,
                    NgayTao = DateTime.Now
                };

                _context.PhieuThuHois.Add(phieu);

                // 6. Cập nhật trạng thái hợp đồng
                hopDong.TrangThai = "DaKetThuc";
                hopDong.NgayKetThucThucTe = ngayTraThucTe;

                // 7. Cập nhật kho thiết bị & Ghi lịch sử luân chuyển
                if (hopDong.ChiTietHopDongs != null && hopDong.ChiTietHopDongs.Count > 0)
                {
                    foreach (var ct in hopDong.ChiTietHopDongs)
                    {
                        var thietBi = await _context.ThietBis.FindAsync(ct.MaThietBi);
                        if (thietBi != null)
                        {
                            string trangThaiMoi = dto.CoHuHong ? "BaoTri" : "SanSang";
                            thietBi.TrangThai = trangThaiMoi;

                            var lichSu = new LichSuLuanChuyen
                            {
                                MaThietBi = ct.MaThietBi,
                                LoaiLuanChuyen = "ThuHoi", // Hoặc "Tra" đều được vì DB đã mở rộng quyền nhận chuỗi ở Bước 1
                                MaHopDongLienQuan = hopDong.MaHopDong,
                                TrangThaiTruoc = "DangChoThue",
                                TrangThaiSau = trangThaiMoi,
                                MaNguoiThucHien = currentUserId,
                                NgayTao = DateTime.Now,
                                GhiChu = dto.CoHuHong ? $"Quyết toán máy lỗi: {dto.GhiChuHuHong}" : "Quyết toán máy tốt"
                            };
                            _context.LichSuLuanChuyens.Add(lichSu);
                        }
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                // 8. Trả về DTO kết quả sạch cho Flutter
                var responseDto = new PhieuThuHoiDto
                {
                    MaPhieuThuHoi = phieu.MaPhieuThuHoi,
                    MaHopDong = phieu.MaHopDong,
                    NgayTra = phieu.NgayTra,
                    SoNgayTre = soNgayTre,
                    TienPhatTre = tienPhatTre,
                    PhiHuHong = phiHuHong,
                    TongTienPhaiThanhToan = tongPhaiThanhToan,
                    CoHuHong = dto.CoHuHong,
                    GhiChuHuHong = phieu.GhiChuHuHong,
                    DanhSachAnhHuHong = phieu.DanhSachAnhHuHong,
                    MaNguoiNhan = phieu.MaNguoiNhan
                };

                return Ok(responseDto);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();

                // In log trực tiếp ra cửa sổ Output của Visual Studio backend để dễ theo dõi
                System.Diagnostics.Debug.WriteLine($"[ERROR PHIEUTHUHOI]: {ex.Message}");
                if (ex.InnerException != null)
                    System.Diagnostics.Debug.WriteLine($"[INNER EXCEPTION]: {ex.InnerException.Message}");

                var sqlErrorMessage = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
                return StatusCode(500, new
                {
                    message = "Lỗi xử lý hệ thống Backend",
                    error = ex.Message,
                    detail = sqlErrorMessage
                });
            }
        }
    }
}