using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using Microsoft.AspNetCore.Authorization;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Bảo mật API bằng Token
    public class ThietBiController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;

        public ThietBiController(QuanLyChoThueThietBiContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/ThietBi
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ThietBiDto>>> GetThietBis()
        {
            try
            {
                var dtos = await _context.ThietBis
                    .ProjectTo<ThietBiDto>(_mapper.ConfigurationProvider)
                    .ToListAsync();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống", Error = ex.Message });
            }
        }

        // GET: api/ThietBi/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ThietBiDto>> GetThietBi(int id)
        {
            var dto = await _context.ThietBis
                .Where(x => x.MaThietBi == id)
                .ProjectTo<ThietBiDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();

            if (dto == null) return NotFound(new { Message = $"Không tìm thấy thiết bị mã {id}" });

            return Ok(dto);
        }

        // POST: api/ThietBi
        [HttpPost]
        [Authorize(Roles = "Admin")] // Chỉ Admin mới được thêm máy
        public async Task<ActionResult<ThietBiDto>> PostThietBi([FromBody] ThietBiDto dto)
        {
            try
            {
                // Kiểm tra trùng mã định danh hoặc số Seri trước khi lưu
                if (await _context.ThietBis.AnyAsync(x => x.SoSeri == dto.SoSeri))
                    return BadRequest(new { Message = "Số Seri này đã tồn tại trên hệ thống!" });

                var entity = _mapper.Map<ThietBi>(dto);

                // Mặc định trạng thái khi thêm mới là Sẵn sàng
                if (string.IsNullOrEmpty(entity.TrangThai)) entity.TrangThai = "SanSang";

                _context.ThietBis.Add(entity);
                await _context.SaveChangesAsync();

                var resultDto = _mapper.Map<ThietBiDto>(entity);
                return CreatedAtAction(nameof(GetThietBi), new { id = entity.MaThietBi }, resultDto);
            }
            catch (DbUpdateException ex)
            {
                var sqlException = ex.InnerException as SqlException;
                return BadRequest(new { Message = "Lỗi CSDL: Kiểm tra lại các trường bắt buộc", Detail = sqlException?.Message });
            }
        }

        // PUT: api/ThietBi/5
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> PutThietBi(int id, [FromBody] ThietBiDto dto)
        {
            // Fix lỗi "ID không khớp" mà Nghĩa gặp bên Flutter
            if (id != dto.MaThietBi)
                return BadRequest(new { Message = $"ID trên URL ({id}) và ID trong dữ liệu ({dto.MaThietBi}) không khớp nhau!" });

            var entity = await _context.ThietBis.FindAsync(id);
            if (entity == null) return NotFound(new { Message = "Không tìm thấy thiết bị để cập nhật" });

            // Cập nhật các trường từ DTO vào Entity đang theo dõi
            _mapper.Map(dto, entity);

            try
            {
                await _context.SaveChangesAsync();
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = "Lỗi cập nhật", Error = ex.Message });
            }
        }

        // DELETE: api/ThietBi/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteThietBi(int id)
        {
            var thietBi = await _context.ThietBis.FindAsync(id);
            if (thietBi == null) return NotFound();

            // Kiểm tra xem máy có đang nằm trong hợp đồng nào không (tránh lỗi khóa ngoại)
            var dangDuocThue = await _context.ChiTietHopDongs.AnyAsync(x => x.MaThietBi == id);
            if (dangDuocThue)
                return BadRequest(new { Message = "Máy này đang nằm trong hợp đồng thuê, không thể xóa!" });

            _context.ThietBis.Remove(thietBi);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}