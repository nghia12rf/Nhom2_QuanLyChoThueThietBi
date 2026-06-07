using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using AutoMapper;
using AutoMapper.QueryableExtensions;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DanhMucThietBiController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IMapper _mapper;

        public DanhMucThietBiController(
            QuanLyChoThueThietBiContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // =====================================================
        // GET: api/DanhMucThietBi
        // Lấy tất cả danh mục
        // =====================================================
        [HttpGet]
        public async Task<ActionResult<IEnumerable<DanhMucThietBiDto>>> GetDanhMucs()
        {
            var danhMucs = await _context.DanhMucThietBis
                .ProjectTo<DanhMucThietBiDto>(_mapper.ConfigurationProvider)
                .ToListAsync();

            return Ok(danhMucs);
        }

        // Lấy danh mục theo mã
        [HttpGet("{id}")]
        public async Task<ActionResult<DanhMucThietBiDto>> GetDanhMuc(int id)
        {
            var danhMuc = await _context.DanhMucThietBis
                .Where(x => x.MaDanhMuc == id)
                .ProjectTo<DanhMucThietBiDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();

            if (danhMuc == null)
            {
                return NotFound(new
                {
                    message = "Không tìm thấy danh mục"
                });
            }

            return Ok(danhMuc);
        }

        // Thêm mới danh mục
        [HttpPost]
        public async Task<ActionResult<DanhMucThietBiDto>> CreateDanhMuc(
            DanhMucThietBiDto dto)
        {
            // Kiểm tra tên danh mục bị trùng
            bool isExist = await _context.DanhMucThietBis
                .AnyAsync(x => x.TenDanhMuc == dto.TenDanhMuc);

            if (isExist)
            {
                return BadRequest(new
                {
                    message = "Tên danh mục đã tồn tại"
                });
            }

            var danhMuc = _mapper.Map<DanhMucThietBi>(dto);

            _context.DanhMucThietBis.Add(danhMuc);
            await _context.SaveChangesAsync();

            var result = _mapper.Map<DanhMucThietBiDto>(danhMuc);

            return CreatedAtAction(
                nameof(GetDanhMuc),
                new { id = result.MaDanhMuc },
                result
            );
        }

        // Cập nhật danh mục
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateDanhMuc(
            int id,
            DanhMucThietBiDto dto)
        {
            if (id != dto.MaDanhMuc)
            {
                return BadRequest(new
                {
                    message = "Mã danh mục không hợp lệ"
                });
            }

            var danhMuc = await _context.DanhMucThietBis.FindAsync(id);

            if (danhMuc == null)
            {
                return NotFound(new
                {
                    message = "Không tìm thấy danh mục"
                });
            }

            // Kiểm tra tên bị trùng
            bool isExist = await _context.DanhMucThietBis
                .AnyAsync(x =>
                    x.TenDanhMuc == dto.TenDanhMuc &&
                    x.MaDanhMuc != id);

            if (isExist)
            {
                return BadRequest(new
                {
                    message = "Tên danh mục đã tồn tại"
                });
            }

            // Mapping dữ liệu mới vào entity cũ
            _mapper.Map(dto, danhMuc);

            _context.Entry(danhMuc).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!DanhMucExists(id))
                {
                    return NotFound(new
                    {
                        message = "Danh mục không tồn tại"
                    });
                }

                throw;
            }

            return Ok(new
            {
                message = "Cập nhật danh mục thành công"
            });
        }

        // Xóa danh mục
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDanhMuc(int id)
        {
            var danhMuc = await _context.DanhMucThietBis
                .Include(x => x.ThietBis)
                .FirstOrDefaultAsync(x => x.MaDanhMuc == id);

            if (danhMuc == null)
            {
                return NotFound(new
                {
                    message = "Không tìm thấy danh mục"
                });
            }

            // Không cho xóa nếu còn thiết bị
            if (danhMuc.ThietBis.Any())
            {
                return BadRequest(new
                {
                    message = "Danh mục đang chứa thiết bị, không thể xóa"
                });
            }

            _context.DanhMucThietBis.Remove(danhMuc);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Xóa danh mục thành công"
            });
        }

        // Kiểm tra tồn tại
        private bool DanhMucExists(int id)
        {
            return _context.DanhMucThietBis
                .Any(e => e.MaDanhMuc == id);
        }
    }
}