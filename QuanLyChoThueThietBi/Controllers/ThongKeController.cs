using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ThongKeController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;

        public ThongKeController(QuanLyChoThueThietBiContext context)
        {
            _context = context;
        }

        // GET: api/ThongKe/TonKho
        [HttpGet("TonKho")]
        public async Task<IActionResult> GetTonKho()
        {
            var data = await _context.ThietBis
                .GroupBy(t => t.TrangThai)
                .Select(g => new
                {
                    TrangThai = g.Key,
                    SoLuong = g.Count()
                })
                .ToListAsync();

            return Ok(data);
        }

        // GET: api/ThongKe/HieuSuat
        [HttpGet("HieuSuat")]
        public async Task<IActionResult> GetHieuSuat()
        {
            var topEquipments = await _context.ChiTietHopDongs
                .Include(c => c.MaThietBiNavigation)
                .GroupBy(c => new { c.MaThietBi, c.MaThietBiNavigation.TenThietBi })
                .Select(g => new
                {
                    TenThietBi = g.Key.TenThietBi,
                    SoLuotThue = g.Count(),
                    TongDoanhThu = g.Sum(c => c.ThanhTien)
                })
                .OrderByDescending(x => x.SoLuotThue)
                .Take(5)
                .ToListAsync();

            return Ok(topEquipments);
        }

        // GET: api/ThongKe/SuCo
        [HttpGet("SuCo")]
        public async Task<IActionResult> GetSuCo()
        {
            var totalEquipments = await _context.ThietBis.CountAsync();
            var totalDamaged = await _context.PhieuThuHois.CountAsync(p => p.CoHuHong == true);

            double tyLeHong = totalEquipments > 0 ? (double)totalDamaged / totalEquipments * 100 : 0;

            var topDamagedEquipments = await _context.PhieuThuHois
                .Where(p => p.CoHuHong == true)
                .Include(p => p.MaHopDongNavigation)
                    .ThenInclude(h => h.ChiTietHopDongs)
                        .ThenInclude(c => c.MaThietBiNavigation)
                .SelectMany(p => p.MaHopDongNavigation.ChiTietHopDongs,
                    (p, ct) => new { ct.MaThietBiNavigation.TenThietBi })
                .GroupBy(x => x.TenThietBi)
                .Select(g => new
                {
                    TenThietBi = g.Key,
                    SoLanHong = g.Count()
                })
                .OrderByDescending(x => x.SoLanHong)
                .Take(3)
                .ToListAsync();

            return Ok(new
            {
                TyLeHong = Math.Round(tyLeHong, 1),
                TopThietBiHong = topDamagedEquipments
            });
        }
    }
}