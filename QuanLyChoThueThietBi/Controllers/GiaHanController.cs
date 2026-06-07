using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using QuanLyChoThueThietBi.Models;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;


[Route("api/[controller]")]
[ApiController]
[Authorize(Roles = "Admin")] // Chỉ Admin mới được gia hạn
public class GiaHanController : ControllerBase
{
    private readonly QuanLyChoThueThietBiContext _context;
    private readonly IMapper _mapper;

    public GiaHanController(QuanLyChoThueThietBiContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    // GET: api/GiaHan
    [HttpGet]
    public async Task<ActionResult<IEnumerable<GiaHanHopDongDto>>> GetGiaHans()
    {
        var list = await _context.GiaHanHopDongs.ToListAsync();
        return Ok(_mapper.Map<IEnumerable<GiaHanHopDongDto>>(list));
    }

    // POST: api/GiaHan
    [HttpPost]
    public async Task<ActionResult<GiaHanHopDongDto>> PostGiaHan(GiaHanCreateDto dto)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null) return Unauthorized();
        int userId = int.Parse(userIdClaim);

        var hopDong = await _context.HopDongs
            .Include(h => h.ChiTietHopDongs)
            .FirstOrDefaultAsync(h => h.MaHopDong == dto.MaHopDong);
        if (hopDong == null) return BadRequest("Hợp đồng không tồn tại");
        if (hopDong.TrangThai != "DangHieuLuc" && hopDong.TrangThai != "QuaHan")
            return BadRequest("Không thể gia hạn hợp đồng ở trạng thái này");
        if (dto.NgayKetThucMoi <= hopDong.NgayKetThucDuKien)
            return BadRequest("Ngày kết thúc mới phải lớn hơn ngày kết thúc hiện tại");

        // Lưu ngày cũ
        DateTime ngayCu = hopDong.NgayKetThucDuKien;

        // Tính số tiền bổ sung dựa trên giá thuê của các thiết bị
        int soNgayGiaHan = (dto.NgayKetThucMoi - ngayCu).Days;
        decimal tienBoSung = 0;
        foreach (var ct in hopDong.ChiTietHopDongs)
        {
            var thietBi = await _context.ThietBis.FindAsync(ct.MaThietBi);
            if (thietBi != null)
            {
                tienBoSung += soNgayGiaHan * thietBi.GiaThueNgay;
            }
        }

        // Tạo bản ghi gia hạn
        var giaHan = new GiaHanHopDong
        {
            MaHopDong = dto.MaHopDong,
            NgayKetThucCu = ngayCu,
            NgayKetThucMoi = dto.NgayKetThucMoi,
            SoTienBoSung = tienBoSung,
            LyDoGiaHan = dto.LyDoGiaHan,
            MaNguoiThucHien = userId
        };
        _context.GiaHanHopDongs.Add(giaHan);

        // Cập nhật hợp đồng
        hopDong.NgayKetThucDuKien = dto.NgayKetThucMoi;
        hopDong.TongTien += tienBoSung;
        hopDong.TrangThai = "GiaHan";

        // Ghi lịch sử cho từng thiết bị
        foreach (var ct in hopDong.ChiTietHopDongs)
        {
            _context.LichSuLuanChuyens.Add(new LichSuLuanChuyen
            {
                MaThietBi = ct.MaThietBi,
                LoaiLuanChuyen = "GiaHan",
                MaHopDongLienQuan = hopDong.MaHopDong,
                TrangThaiTruoc = "DangChoThue",
                TrangThaiSau = "DangChoThue",
                MaNguoiThucHien = userId,
                NgayTao = DateTime.Now,
                GhiChu = $"Gia hạn đến {dto.NgayKetThucMoi:dd/MM/yyyy}"
            });
        }

        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetGiaHans), new { id = giaHan.MaGiaHan }, _mapper.Map<GiaHanHopDongDto>(giaHan));
    }
}