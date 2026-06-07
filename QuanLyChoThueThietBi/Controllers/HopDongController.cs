using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using AutoMapper;
using System.Security.Claims;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HopDongController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;

        public HopDongController(QuanLyChoThueThietBiContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // 1. LẤY DANH SÁCH HỢP ĐỒNG (Có lọc trạng thái & Tách Query)
        [HttpGet]
        public async Task<ActionResult<IEnumerable<HopDongDto>>> GetHopDongs([FromQuery] string? trangThai)
        {
            try
            {
                var query = _context.HopDongs
                    .Include(h => h.MaKhachHangNavigation)
                    .Include(h => h.ChiTietHopDongs)
                        .ThenInclude(ct => ct.MaThietBiNavigation)
                    .AsSplitQuery() // Giải quyết lỗi 'WITH' trên SQL Server bản cũ
                    .AsQueryable();

                if (!string.IsNullOrEmpty(trangThai))
                {
                    var statusList = trangThai.Split(',').Select(s => s.Trim()).ToList();
                    query = query.Where(h => h.TrangThai != null && statusList.Contains(h.TrangThai));
                }

                var hopDongs = await query.ToListAsync();
                return Ok(_mapper.Map<IEnumerable<HopDongDto>>(hopDongs));
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi truy vấn dữ liệu", detail = ex.Message });
            }
        }

        // 2. TÌM HỢP ĐỒNG THEO MÃ THIẾT BỊ (Phục vụ chức năng Thu hồi)
        [HttpGet("ByEquipment/{equipmentId}")]
        public async Task<ActionResult> GetHopDongByEquipment(int equipmentId)
        {
            // Tìm hợp đồng đang hiệu lực hoặc quá hạn có chứa thiết bị này
            var hopDong = await _context.HopDongs
                .Include(h => h.MaKhachHangNavigation)
                .Where(h => (h.TrangThai == "DangHieuLuc" || h.TrangThai == "QuaHan")
                         && h.ChiTietHopDongs.Any(ct => ct.MaThietBi == equipmentId))
                .OrderByDescending(h => h.NgayTao)
                .Select(h => new {
                    h.MaHopDong,
                    h.MaDinhDanhHopDong,
                    // Map thủ công để lấy đúng tên công ty khách hàng
                    TenKhachHang = h.MaKhachHangNavigation != null ? h.MaKhachHangNavigation.TenCongTy : "Khách lẻ",
                    h.NgayKetThucDuKien
                })
                .FirstOrDefaultAsync();

            if (hopDong == null)
                return NotFound(new { message = "Thiết bị này không nằm trong hợp đồng nào đang thuê." });

            return Ok(hopDong);
        }

        // 3. TẠO MỚI HỢP ĐỒNG (Có Transaction & Tự động đổi trạng thái máy)
        [HttpPost]
        public async Task<ActionResult> PostHopDong([FromBody] HopDongCreateDto dto)
        {
            // Lấy ID người dùng từ Token (Người đang đăng nhập)
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userIdClaim == null) return Unauthorized(new { message = "Bạn cần đăng nhập lại!" });
            int currentUserId = int.Parse(userIdClaim);

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // Map từ DTO sang Model
                var hopDong = _mapper.Map<HopDong>(dto);

                hopDong.MaNguoiTao = currentUserId;
                hopDong.NgayTao = DateTime.Now;

                _context.HopDongs.Add(hopDong);
                await _context.SaveChangesAsync();

                // Cập nhật trạng thái từng thiết bị sang 'DangChoThue'
                foreach (var item in hopDong.ChiTietHopDongs)
                {
                    var thietBi = await _context.ThietBis.FindAsync(item.MaThietBi);
                    if (thietBi != null)
                    {
                        if (thietBi.TrangThai != "SanSang")
                        {
                            await transaction.RollbackAsync();
                            return BadRequest(new { message = $"Thiết bị {thietBi.TenThietBi} không sẵn sàng!" });
                        }
                        thietBi.TrangThai = "DangChoThue";
                    }
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return Ok(new { message = "Tạo hợp đồng thành công!" });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { detail = ex.InnerException?.Message ?? ex.Message });
            }
        }
    }
}