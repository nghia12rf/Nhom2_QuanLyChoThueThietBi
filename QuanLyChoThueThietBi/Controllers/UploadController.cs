using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace RentalEquipmentAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Yêu cầu xác thực để upload
    public class UploadController : ControllerBase
    {
        // Inject IWebHostEnvironment để biết đường dẫn gốc của ứng dụng web
        private readonly IWebHostEnvironment _environment;

        public UploadController(IWebHostEnvironment environment)
        {
            _environment = environment;
        }

        [HttpPost("image")]
        public async Task<IActionResult> UploadImage(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("Không có file nào được tải lên.");

            // 1. Kiểm tra loại file (chỉ cho phép ảnh)
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
            var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowedExtensions.Contains(fileExtension))
            {
                return BadRequest("Định dạng file không được hỗ trợ. Vui lòng upload ảnh.");
            }

            // 2. Kiểm tra kích thước file (giới hạn 5MB)
            if (file.Length > 5 * 1024 * 1024) // 5MB
            {
                return BadRequest("Kích thước file quá lớn. Vui lòng upload ảnh dưới 5MB.");
            }

            // 3. Tạo tên file duy nhất để tránh trùng lặp
            var uniqueFileName = $"{Guid.NewGuid()}{fileExtension}";

            // 4. Xác định đường dẫn thư mục lưu ảnh
            // Tạo thư mục "uploads" trong "wwwroot" nếu chưa có
            var uploadsFolder = Path.Combine(_environment.WebRootPath ?? "wwwroot", "uploads", "damages");
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            // 5. Lưu file vào thư mục
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // 6. Tạo URL công khai để truy cập ảnh
            // URL sẽ có dạng: https://yourdomain.com/uploads/damages/unique-file-name.jpg
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            var imageUrl = $"{baseUrl}/uploads/damages/{uniqueFileName}";

            // 7. Trả về URL của ảnh đã upload
            return Ok(new { imageUrl });
        }
    }
}