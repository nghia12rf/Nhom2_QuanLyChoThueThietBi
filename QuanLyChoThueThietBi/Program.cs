using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using QuanLyChoThueThietBi.Models;
using System.Text;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// --- 1. CẤU HÌNH SERVICES (Dependency Injection) ---

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Ngăn chặn lỗi vòng lặp dữ liệu (Object Cycle) khi quan hệ 1-nhiều
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    });

// Kết nối Database SQL Server
builder.Services.AddDbContext<QuanLyChoThueThietBiContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"),
    sqlOptions => {
        // 🔥 Ép EF Core dùng cú pháp cũ hơn (tương thích SQL 2012/2014)
        sqlOptions.UseCompatibilityLevel(120);
    }));

// Đăng ký AutoMapper (Tìm các Profile trong cùng Assembly với Program)
builder.Services.AddAutoMapper(typeof(Program));

// Cấu hình CORS - Cho phép Flutter (mọi nguồn) truy cập API
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Cấu hình JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"] ?? "Key_Bao_Mat_Sieu_Cap_2026_NghiaHUIT_123456";
var key = Encoding.UTF8.GetBytes(jwtKey);

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(key)
        };
    });

// Cấu hình Swagger kèm bảo mật Bearer Token
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "QuanLyChoThueThietBi API", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Nhập Token theo định dạng: Bearer {your_token}"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            new string[] {}
        }
    });
});

var app = builder.Build();

// --- 2. CẤU HÌNH PIPELINE (Middleware - THỨ TỰ LÀ CỰC KỲ QUAN TRỌNG) ---

// [CẬP NHẬT] Kiểm tra môi trường Development
if (app.Environment.IsDevelopment())
{
    // Bật trang báo lỗi chi tiết dành cho lập trình viên
    app.UseDeveloperExceptionPage();

    app.UseSwagger();
    app.UseSwaggerUI();
}

// 1. Phục vụ ảnh từ thư mục wwwroot
app.UseStaticFiles();

// [MẸO] Tạm thời tắt Https để test với Flutter Emulator dễ hơn
// app.UseHttpsRedirection(); 

// 2. Định tuyến (Routing)
app.UseRouting();

// 3. CORS PHẢI nằm sau UseRouting và TRƯỚC Authentication/Authorization
app.UseCors("AllowFlutterApp");

// 4. Xác thực và Phân quyền
app.UseAuthentication();
app.UseAuthorization();

// 5. Map các Controller API
app.MapControllers();

app.Run();