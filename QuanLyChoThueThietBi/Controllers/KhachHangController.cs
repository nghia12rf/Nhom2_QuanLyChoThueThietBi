using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using Microsoft.Data.SqlClient;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Yêu cầu đăng nhập (Bearer Token)
    public class KhachHangController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;

        public KhachHangController(QuanLyChoThueThietBiContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // GET: api/KhachHang
        [HttpGet]
        public async Task<ActionResult<IEnumerable<KhachHangDto>>> GetKhachHangs()
        {
            try
            {
                // ProjectTo giúp tránh lỗi vòng lặp và tối ưu hóa câu lệnh SQL
                var dtos = await _context.KhachHangs
                    .ProjectTo<KhachHangDto>(_mapper.ConfigurationProvider)
                    .ToListAsync();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Message = "Lỗi lấy danh sách khách hàng",
                    Error = ex.Message,
                    Detail = ex.InnerException?.Message
                });
            }
        }

        // GET: api/KhachHang/5
        [HttpGet("{id}")]
        public async Task<ActionResult<KhachHangDto>> GetKhachHang(int id)
        {
            var dto = await _context.KhachHangs
                .Where(x => x.MaKhachHang == id)
                .ProjectTo<KhachHangDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();

            if (dto == null) return NotFound(new { Message = $"Không tìm thấy khách hàng ID: {id}" });

            return Ok(dto);
        }

        // POST: api/KhachHang
        [HttpPost]
        [Authorize(Roles = "Admin")] // Chỉ Admin mới có quyền thêm
        public async Task<ActionResult<KhachHangDto>> PostKhachHang([FromBody] KhachHangDto dto)
        {
            try
            {
                // Chuyển DTO từ Flutter gửi lên thành Entity để lưu vào DB
                var entity = _mapper.Map<KhachHang>(dto);

                _context.KhachHangs.Add(entity);
                await _context.SaveChangesAsync();

                // Map ngược lại để trả về kết quả kèm theo ID vừa sinh ra
                var result = _mapper.Map<KhachHangDto>(entity);
                return CreatedAtAction(nameof(GetKhachHang), new { id = entity.MaKhachHang }, result);
            }
            catch (DbUpdateException ex)
            {
                var sqlException = ex.InnerException as SqlException;
                return BadRequest(new { Message = "Lỗi CSDL (Có thể trùng mã hoặc dữ liệu không hợp lệ)", Error = sqlException?.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi hệ thống", Error = ex.Message });
            }
        }

        // PUT: api/KhachHang/5
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> PutKhachHang(int id, [FromBody] KhachHangDto dto)
        {
            if (id != dto.MaKhachHang) return BadRequest(new { Message = "ID không khớp" });

            var entity = await _context.KhachHangs.FindAsync(id);
            if (entity == null) return NotFound();

            // Cập nhật dữ liệu từ DTO vào Entity đang được theo dõi
            _mapper.Map(dto, entity);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = "Không thể cập nhật", Error = ex.Message });
            }

            return NoContent();
        }

        // DELETE: api/KhachHang/5
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteKhachHang(int id)
        {
            var entity = await _context.KhachHangs.FindAsync(id);
            if (entity == null) return NotFound();

            // Kiểm tra xem khách hàng có đang trong hợp đồng nào không (tránh lỗi khóa ngoại)
            var coHopDong = await _context.HopDongs.AnyAsync(h => h.MaKhachHang == id);
            if (coHopDong) return BadRequest(new { Message = "Không thể xóa khách hàng đang có hợp đồng thuê!" });

            _context.KhachHangs.Remove(entity);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
} 