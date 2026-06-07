using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace QuanLyChoThueThietBi.Models;

public partial class QuanLyChoThueThietBiContext : DbContext
{
    public QuanLyChoThueThietBiContext()
    {
    }

    public QuanLyChoThueThietBiContext(DbContextOptions<QuanLyChoThueThietBiContext> options)
        : base(options)
    {
    }

    public virtual DbSet<ChiTietHopDong> ChiTietHopDongs { get; set; }

    public virtual DbSet<DanhMucThietBi> DanhMucThietBis { get; set; }

    public virtual DbSet<GiaHanHopDong> GiaHanHopDongs { get; set; }

    public virtual DbSet<HopDong> HopDongs { get; set; }

    public virtual DbSet<KhachHang> KhachHangs { get; set; }

    public virtual DbSet<LichSuLuanChuyen> LichSuLuanChuyens { get; set; }

    public virtual DbSet<NguoiDung> NguoiDungs { get; set; }

    public virtual DbSet<PhieuThuHoi> PhieuThuHois { get; set; }

    public virtual DbSet<ThietBi> ThietBis { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=DESKTOP-VB88CJ4\\SQLEXPRESS;Database=QuanLyChoThueThietBiDB;Trusted_Connection=True;TrustServerCertificate=True;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ChiTietHopDong>(entity =>
        {
            entity.HasKey(e => e.MaChiTietHopDong).HasName("PK__ChiTietH__0DA24B738FBE8DAB");

            entity.ToTable("ChiTietHopDong");

            entity.Property(e => e.GhiChu).HasMaxLength(200);
            entity.Property(e => e.GiaThueThoiDiem).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ThanhTien).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.MaHopDongNavigation).WithMany(p => p.ChiTietHopDongs)
                .HasForeignKey(d => d.MaHopDong)
                .HasConstraintName("FK__ChiTietHo__MaHop__2E1BDC42");

            entity.HasOne(d => d.MaThietBiNavigation).WithMany(p => p.ChiTietHopDongs)
                .HasForeignKey(d => d.MaThietBi)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ChiTietHo__MaThi__2F10007B");
        });

        modelBuilder.Entity<DanhMucThietBi>(entity =>
        {
            entity.HasKey(e => e.MaDanhMuc).HasName("PK__DanhMucT__B375088779E5CA0D");

            entity.ToTable("DanhMucThietBi");

            entity.Property(e => e.MoTa).HasMaxLength(255);
            entity.Property(e => e.TenDanhMuc).HasMaxLength(100);
        });

        modelBuilder.Entity<GiaHanHopDong>(entity =>
        {
            entity.HasKey(e => e.MaGiaHan).HasName("PK__GiaHanHo__C3260BA4D433FA45");

            entity.ToTable("GiaHanHopDong");

            entity.Property(e => e.LyDoGiaHan).HasMaxLength(500);
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.SoTienBoSung).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.MaHopDongNavigation).WithMany(p => p.GiaHanHopDongs)
                .HasForeignKey(d => d.MaHopDong)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__GiaHanHop__MaHop__31EC6D26");

            entity.HasOne(d => d.MaNguoiThucHienNavigation).WithMany(p => p.GiaHanHopDongs)
                .HasForeignKey(d => d.MaNguoiThucHien)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__GiaHanHop__MaNgu__32E0915F");
        });

        modelBuilder.Entity<HopDong>(entity =>
        {
            entity.HasKey(e => e.MaHopDong).HasName("PK__HopDong__36DD4342E1BB5ADC");

            entity.ToTable("HopDong");

            entity.HasIndex(e => e.MaDinhDanhHopDong, "UQ__HopDong__8D35584CFDBA50A1").IsUnique();

            entity.Property(e => e.GhiChu).HasMaxLength(500);
            entity.Property(e => e.MaDinhDanhHopDong).HasMaxLength(50);
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.TienCoc)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(18, 2)");
            entity.Property(e => e.TongTien).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.TrangThai)
                .HasMaxLength(20)
                .HasDefaultValue("DangHieuLuc");

            entity.HasOne(d => d.MaKhachHangNavigation).WithMany(p => p.HopDongs)
                .HasForeignKey(d => d.MaKhachHang)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__HopDong__MaKhach__267ABA7A");

            entity.HasOne(d => d.MaNguoiTaoNavigation).WithMany(p => p.HopDongs)
                .HasForeignKey(d => d.MaNguoiTao)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__HopDong__MaNguoi__2A4B4B5E");
        });

        modelBuilder.Entity<KhachHang>(entity =>
        {
            entity.HasKey(e => e.MaKhachHang).HasName("PK__KhachHan__88D2F0E5FB524563");

            entity.ToTable("KhachHang");

            entity.HasIndex(e => e.MaDinhDanhKhachHang, "UQ__KhachHan__CA108E53C01622C4").IsUnique();

            entity.Property(e => e.DiaChi).HasMaxLength(255);
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.MaDinhDanhKhachHang).HasMaxLength(50);
            entity.Property(e => e.MaSoThue)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.NguoiDaiDien).HasMaxLength(100);
            entity.Property(e => e.SoDienThoai)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.TenCongTy).HasMaxLength(200);
        });

        modelBuilder.Entity<LichSuLuanChuyen>(entity =>
        {
            entity.HasKey(e => e.MaLuanChuyen).HasName("PK__LichSuLu__C8DDB07703323883");

            entity.ToTable("LichSuLuanChuyen");

            entity.Property(e => e.GhiChu).HasMaxLength(500);
            entity.Property(e => e.LoaiLuanChuyen).HasMaxLength(20);
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.TrangThaiSau).HasMaxLength(20);
            entity.Property(e => e.TrangThaiTruoc).HasMaxLength(20);

            entity.HasOne(d => d.MaHopDongLienQuanNavigation).WithMany(p => p.LichSuLuanChuyens)
                .HasForeignKey(d => d.MaHopDongLienQuan)
                .HasConstraintName("FK__LichSuLua__MaHop__412EB0B6");

            entity.HasOne(d => d.MaNguoiThucHienNavigation).WithMany(p => p.LichSuLuanChuyens)
                .HasForeignKey(d => d.MaNguoiThucHien)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__LichSuLua__MaNgu__4222D4EF");

            entity.HasOne(d => d.MaThietBiNavigation).WithMany(p => p.LichSuLuanChuyens)
                .HasForeignKey(d => d.MaThietBi)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__LichSuLua__MaThi__3F466844");
        });

        modelBuilder.Entity<NguoiDung>(entity =>
        {
            entity.HasKey(e => e.MaNguoiDung).HasName("PK__NguoiDun__C539D76265EFBF4C");

            entity.ToTable("NguoiDung");

            entity.HasIndex(e => e.TenDangNhap, "UQ__NguoiDun__55F68FC0020AD195").IsUnique();

            entity.HasIndex(e => e.Email, "UQ__NguoiDun__A9D10534423239AE").IsUnique();

            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.HoTen).HasMaxLength(100);
            entity.Property(e => e.MatKhauHash).HasMaxLength(255);
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.TenDangNhap).HasMaxLength(50);
            entity.Property(e => e.TrangThaiHoatDong).HasDefaultValue(true);
            entity.Property(e => e.VaiTro).HasMaxLength(20);
        });

        modelBuilder.Entity<PhieuThuHoi>(entity =>
        {
            entity.HasKey(e => e.MaPhieuThuHoi).HasName("PK__PhieuThu__E926BF0D59B757D9");

            entity.ToTable("PhieuThuHoi");

            entity.Property(e => e.CoHuHong).HasDefaultValue(false);
            entity.Property(e => e.GhiChuHuHong).HasMaxLength(500);
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.PhiHuHong)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(18, 2)");
            entity.Property(e => e.SoNgayTre).HasDefaultValue(0);
            entity.Property(e => e.TienPhatTre)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(18, 2)");
            entity.Property(e => e.TongTienPhaiThanhToan).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.MaHopDongNavigation).WithMany(p => p.PhieuThuHois)
                .HasForeignKey(d => d.MaHopDong)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__PhieuThuH__MaHop__36B12243");

            entity.HasOne(d => d.MaNguoiNhanNavigation).WithMany(p => p.PhieuThuHois)
                .HasForeignKey(d => d.MaNguoiNhan)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__PhieuThuH__MaNgu__3B75D760");
        });

        modelBuilder.Entity<ThietBi>(entity =>
        {
            entity.HasKey(e => e.MaThietBi).HasName("PK__ThietBi__8AEC71F77E8A4313");

            entity.ToTable("ThietBi");

            entity.HasIndex(e => e.SoSeri, "UQ__ThietBi__089A7951D59A0CF4").IsUnique();

            entity.HasIndex(e => e.MaDinhDanhThietBi, "UQ__ThietBi__8090F6BC4422B8AF").IsUnique();

            entity.Property(e => e.GiaThueNgay).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.GiaTriTaiSan).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.HangSanXuat).HasMaxLength(100);
            entity.Property(e => e.HinhAnhUrl).HasMaxLength(500);
            entity.Property(e => e.MaDinhDanhThietBi).HasMaxLength(50);
            entity.Property(e => e.Model).HasMaxLength(100);
            entity.Property(e => e.NgayTao)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.SoSeri).HasMaxLength(100);
            entity.Property(e => e.TenThietBi).HasMaxLength(200);
            entity.Property(e => e.TrangThai)
                .HasMaxLength(20)
                .HasDefaultValue("SanSang");

            entity.HasOne(d => d.MaDanhMucNavigation).WithMany(p => p.ThietBis)
                .HasForeignKey(d => d.MaDanhMuc)
                .HasConstraintName("FK__ThietBi__MaDanhM__1ED998B2");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
