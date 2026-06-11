USE [master]
GO
IF DB_ID('QuanLyChoThueThietBiDB') IS NOT NULL
BEGIN
    ALTER DATABASE [QuanLyChoThueThietBiDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [QuanLyChoThueThietBiDB];
END
GO
CREATE DATABASE [QuanLyChoThueThietBiDB]
GO
USE [QuanLyChoThueThietBiDB]
GO
/****** Object:  Table [dbo].[ChiTietHopDong]    Script Date: 6/11/2026 8:30:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiTietHopDong](
	[MaChiTietHopDong] [int] IDENTITY(1,1) NOT NULL,
	[MaHopDong] [int] NOT NULL,
	[MaThietBi] [int] NOT NULL,
	[GiaThueThoiDiem] [decimal](18, 2) NOT NULL,
	[ThanhTien] [decimal](18, 2) NOT NULL,
	[GhiChu] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[MaChiTietHopDong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DanhMucThietBi]    Script Date: 6/11/2026 8:30:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DanhMucThietBi](
	[MaDanhMuc] [int] IDENTITY(1,1) NOT NULL,
	[TenDanhMuc] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MoTa] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[MaDanhMuc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GiaHanHopDong]    Script Date: 6/11/2026 8:30:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GiaHanHopDong](
	[MaGiaHan] [int] IDENTITY(1,1) NOT NULL,
	[MaHopDong] [int] NOT NULL,
	[NgayKetThucCu] [date] NOT NULL,
	[NgayKetThucMoi] [date] NOT NULL,
	[SoTienBoSung] [decimal](18, 2) NOT NULL,
	[LyDoGiaHan] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaNguoiThucHien] [int] NOT NULL,
	[NgayTao] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[MaGiaHan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HopDong]    Script Date: 6/11/2026 8:30:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HopDong](
	[MaHopDong] [int] IDENTITY(1,1) NOT NULL,
	[MaDinhDanhHopDong] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MaKhachHang] [int] NOT NULL,
	[NgayBatDau] [date] NOT NULL,
	[NgayKetThucDuKien] [date] NOT NULL,
	[NgayKetThucThucTe] [date] NULL,
	[TongTien] [decimal](18, 2) NOT NULL,
	[TienCoc] [decimal](18, 2) NULL DEFAULT ((0)),
	[TrangThai] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT ('DangHieuLuc'),
	[MaNguoiTao] [int] NOT NULL,
	[NgayTao] [datetime] NULL DEFAULT (getdate()),
	[GhiChu] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[MaHopDong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[MaDinhDanhHopDong] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD CHECK  (([TrangThai]='GiaHan' OR [TrangThai]='QuaHan' OR [TrangThai]='DaKetThuc' OR [TrangThai]='DangHieuLuc'))
GO
/****** Object:  Table [dbo].[KhachHang]    Script Date: 6/11/2026 8:30:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KhachHang](
	[MaKhachHang] [int] IDENTITY(1,1) NOT NULL,
	[MaDinhDanhKhachHang] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TenCongTy] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NguoiDaiDien] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SoDienThoai] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Email] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DiaChi] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaSoThue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NgayTao] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[MaKhachHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[MaDinhDanhKhachHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LichSuLuanChuyen]    Script Date: 6/11/2026 8:30:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LichSuLuanChuyen](
	[MaLuanChuyen] [int] IDENTITY(1,1) NOT NULL,
	[MaThietBi] [int] NOT NULL,
	[LoaiLuanChuyen] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaHopDongLienQuan] [int] NULL,
	[TrangThaiTruoc] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TrangThaiSau] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GhiChu] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaNguoiThucHien] [int] NOT NULL,
	[NgayTao] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[MaLuanChuyen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[LichSuLuanChuyen]  WITH CHECK ADD CHECK  (([LoaiLuanChuyen]='GiaHan' OR [LoaiLuanChuyen]='DiBaoTri' OR [LoaiLuanChuyen]='NhapHoi' OR [LoaiLuanChuyen]='XuatThue'))
GO
/****** Object:  Table [dbo].[NguoiDung]    Script Date: 6/11/2026 8:30:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NguoiDung](
	[MaNguoiDung] [int] IDENTITY(1,1) NOT NULL,
	[TenDangNhap] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MatKhauHash] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HoTen] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Email] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VaiTro] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TrangThaiHoatDong] [bit] NULL DEFAULT ((1)),
	[NgayTao] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[MaNguoiDung] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[TenDangNhap] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[NguoiDung]  WITH CHECK ADD CHECK  (([VaiTro]='Employee' OR [VaiTro]='Admin'))
GO
/****** Object:  Table [dbo].[PhieuThuHoi]    Script Date: 6/11/2026 8:30:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhieuThuHoi](
	[MaPhieuThuHoi] [int] IDENTITY(1,1) NOT NULL,
	[MaHopDong] [int] NOT NULL,
	[NgayTra] [date] NOT NULL,
	[SoNgayTre] [int] NULL DEFAULT ((0)),
	[TienPhatTre] [decimal](18, 2) NULL DEFAULT ((0)),
	[PhiHuHong] [decimal](18, 2) NULL DEFAULT ((0)),
	[TongTienPhaiThanhToan] [decimal](18, 2) NULL,
	[CoHuHong] [bit] NULL DEFAULT ((0)),
	[GhiChuHuHong] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DanhSachAnhHuHong] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MaNguoiNhan] [int] NOT NULL,
	[NgayTao] [datetime] NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[MaPhieuThuHoi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ThietBi]    Script Date: 6/11/2026 8:30:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThietBi](
	[MaThietBi] [int] IDENTITY(1,1) NOT NULL,
	[MaDinhDanhThietBi] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TenThietBi] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MaDanhMuc] [int] NULL,
	[HangSanXuat] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Model] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SoSeri] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GiaThueNgay] [decimal](18, 2) NOT NULL DEFAULT ((0)),
	[GiaTriTaiSan] [decimal](18, 2) NULL,
	[TrangThai] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT ('SanSang'),
	[ThongSoKyThuat] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HinhAnhUrl] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NgayTao] [datetime] NULL DEFAULT (getdate()),
	[CongSuat] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TrongLuong] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DienAp] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AnhLienQuan] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[MaThietBi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SoSeri] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[MaDinhDanhThietBi] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[ThietBi]  WITH CHECK ADD CHECK  (([TrangThai]='NgungSuDung' OR [TrangThai]='BaoTri' OR [TrangThai]='DangChoThue' OR [TrangThai]='SanSang'))
GO
/****** Object:  Table [dbo].[ThongBao]    Script Date: 6/11/2026 8:30:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThongBao](
	[MaThongBao] [int] IDENTITY(1,1) NOT NULL,
	[TieuDe] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NoiDung] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoaiThongBao] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NgayTao] [datetime] NULL DEFAULT (getdate()),
	[DaDoc] [bit] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[MaThongBao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[ChiTietHopDong]  WITH CHECK ADD FOREIGN KEY([MaHopDong])
REFERENCES [dbo].[HopDong] ([MaHopDong])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ChiTietHopDong]  WITH CHECK ADD FOREIGN KEY([MaThietBi])
REFERENCES [dbo].[ThietBi] ([MaThietBi])
GO
ALTER TABLE [dbo].[GiaHanHopDong]  WITH CHECK ADD FOREIGN KEY([MaHopDong])
REFERENCES [dbo].[HopDong] ([MaHopDong])
GO
ALTER TABLE [dbo].[GiaHanHopDong]  WITH CHECK ADD FOREIGN KEY([MaNguoiThucHien])
REFERENCES [dbo].[NguoiDung] ([MaNguoiDung])
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD FOREIGN KEY([MaKhachHang])
REFERENCES [dbo].[KhachHang] ([MaKhachHang])
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD FOREIGN KEY([MaNguoiTao])
REFERENCES [dbo].[NguoiDung] ([MaNguoiDung])
GO
ALTER TABLE [dbo].[LichSuLuanChuyen]  WITH CHECK ADD FOREIGN KEY([MaHopDongLienQuan])
REFERENCES [dbo].[HopDong] ([MaHopDong])
GO
ALTER TABLE [dbo].[LichSuLuanChuyen]  WITH CHECK ADD FOREIGN KEY([MaNguoiThucHien])
REFERENCES [dbo].[NguoiDung] ([MaNguoiDung])
GO
ALTER TABLE [dbo].[LichSuLuanChuyen]  WITH CHECK ADD FOREIGN KEY([MaThietBi])
REFERENCES [dbo].[ThietBi] ([MaThietBi])
GO
ALTER TABLE [dbo].[PhieuThuHoi]  WITH CHECK ADD FOREIGN KEY([MaHopDong])
REFERENCES [dbo].[HopDong] ([MaHopDong])
GO
ALTER TABLE [dbo].[PhieuThuHoi]  WITH CHECK ADD FOREIGN KEY([MaNguoiNhan])
REFERENCES [dbo].[NguoiDung] ([MaNguoiDung])
GO
ALTER TABLE [dbo].[ThietBi]  WITH CHECK ADD FOREIGN KEY([MaDanhMuc])
REFERENCES [dbo].[DanhMucThietBi] ([MaDanhMuc])
GO
