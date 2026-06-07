using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using QuanLyChoThueThietBi.Models;
using RentalEquipmentAPI.DTOs;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace QuanLyChoThueThietBi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [AllowAnonymous]   // <-- QUAN TRỌNG: Cho phép truy cập không cần token
    public class AuthController : ControllerBase
    {
        private readonly QuanLyChoThueThietBiContext _context;
        private readonly IConfiguration _config;

        public AuthController(QuanLyChoThueThietBiContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto loginDto)
        {
            if (loginDto == null)
                return BadRequest(new { message = "Dữ liệu không hợp lệ" });

            if (string.IsNullOrEmpty(loginDto.TenDangNhap) || string.IsNullOrEmpty(loginDto.MatKhau))
                return BadRequest(new { message = "Vui lòng nhập đầy đủ thông tin" });

            // 1. Tìm user trong DB
            var user = await _context.NguoiDungs
                .FirstOrDefaultAsync(u => u.TenDangNhap == loginDto.TenDangNhap
                                       && u.MatKhauHash == loginDto.MatKhau);

            if (user == null)
            {
                return Unauthorized(new { message = "Sai tên đăng nhập hoặc mật khẩu" });
            }

            // 2. Tạo JWT token
            var token = GenerateJwtToken(user);

            // 3. Trả về thông tin
            return Ok(new
            {
                token,
                vaiTro = user.VaiTro,
                hoTen = user.HoTen,
                tenDangNhap = user.TenDangNhap
            });
        }

        private string GenerateJwtToken(NguoiDung user)
        {
            var jwtKey = _config["Jwt:Key"];
            if (string.IsNullOrEmpty(jwtKey))
                throw new InvalidOperationException("JWT Key is not configured.");

            var jwtIssuer = _config["Jwt:Issuer"];
            var jwtAudience = _config["Jwt:Audience"];
            var durationInMinutes = Convert.ToDouble(_config["Jwt:DurationInMinutes"] ?? "60");

            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.MaNguoiDung.ToString()),
                new Claim(ClaimTypes.Name, user.TenDangNhap ?? ""),
                new Claim(ClaimTypes.Role, user.VaiTro ?? "User"),
                new Claim("FullName", user.HoTen ?? "")
            };

            var token = new JwtSecurityToken(
                issuer: jwtIssuer,
                audience: jwtAudience,
                claims: claims,
                expires: DateTime.Now.AddMinutes(durationInMinutes),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}