-- ============================================================
-- SCRIPT TẠO DỮ LIỆU MẪU HOÀN CHỈNH CHO ĐỒ ÁN
-- Dự án: Hệ Thống Quản Lý Cho Thuê Thiết Bị Ngành Ảnh & Media
-- ============================================================
USE QuanLyChoThueThietBiDB;
GO

-- Xóa dữ liệu cũ nếu chạy lại script để tránh trùng lặp
DELETE FROM ThongBao;
DELETE FROM LichSuLuanChuyen;
DELETE FROM PhieuThuHoi;
DELETE FROM GiaHanHopDong;
DELETE FROM ChiTietHopDong;
DELETE FROM HopDong;
DELETE FROM KhachHang;
DELETE FROM ThietBi;
DELETE FROM DanhMucThietBi;
DELETE FROM NguoiDung;

-- Reset Identity về 1
DBCC CHECKIDENT ('NguoiDung', RESEED, 0);
DBCC CHECKIDENT ('DanhMucThietBi', RESEED, 0);
DBCC CHECKIDENT ('KhachHang', RESEED, 0);
DBCC CHECKIDENT ('ThietBi', RESEED, 0);
DBCC CHECKIDENT ('HopDong', RESEED, 0);
DBCC CHECKIDENT ('ChiTietHopDong', RESEED, 0);
DBCC CHECKIDENT ('GiaHanHopDong', RESEED, 0);
DBCC CHECKIDENT ('PhieuThuHoi', RESEED, 0);
DBCC CHECKIDENT ('LichSuLuanChuyen', RESEED, 0);
DBCC CHECKIDENT ('ThongBao', RESEED, 0);
GO

-- =============================================
-- 1. KHỞI TẠO TÀI KHOẢN HỆ THỐNG (ADMIN & EMPLOYEE)
-- =============================================
INSERT INTO NguoiDung (TenDangNhap, MatKhauHash, HoTen, Email, VaiTro, TrangThaiHoatDong)
VALUES 
('admin', 'admin123', N'Phạm Tấn Nghĩa (Quản lý)', 'nghia.admin@rental.com', 'Admin', 1),
('employee', 'employee123', N'Ngô Quốc Bình (Nhân viên)', 'binh.emp@rental.com', 'Employee', 1);

DECLARE @adminId INT = (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'admin');
DECLARE @empId INT   = (SELECT MaNguoiDung FROM NguoiDung WHERE TenDangNhap = 'employee');

-- =============================================
-- 2. TẠO ĐỦ 7 DANH MỤC THIẾT BỊ ĐA DẠNG
-- =============================================
INSERT INTO DanhMucThietBi (TenDanhMuc, MoTa) VALUES 
(N'Máy ảnh', N'Các dòng máy ảnh kĩ thuật số DSLR và Mirrorless chuyên nghiệp'),
(N'Ống kính (Lens)', N'Ống kính rời các tiêu cự từ Wide, Prime đến Telephoto'),
(N'Flycam / Drone', N'Thiết bị bay không người lái phục vụ quay phim trên cao'),
(N'Máy quay chuyên dụng', N'Cinema Camera phục vụ quay TVC và sản xuất phim'),
(N'Thiết bị âm thanh', N'Hệ thống thu âm microphone cài áo, boom và máy ghi âm bối cảnh'),
(N'Thiết bị chiếu sáng', N'Hệ thống đèn LED studio, softbox và phụ kiện ánh sáng'),
(N'Phụ kiện chống rung', N'Các thiết bị gimbal cầm tay, tripod cơ động');

-- Lấy danh sách ID danh mục để phân bổ sản phẩm
DECLARE @dmMayAnh INT = (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Máy ảnh');
DECLARE @dmLens INT = (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Ống kính (Lens)');
DECLARE @dmFlycam INT = (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Flycam / Drone');
DECLARE @dmMayQuay INT = (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Máy quay chuyên dụng');
DECLARE @dmAmThanh INT = (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Thiết bị âm thanh');
DECLARE @dmAnhSang INT = (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Thiết bị chiếu sáng');
DECLARE @dmGimbal INT = (SELECT MaDanhMuc FROM DanhMucThietBi WHERE TenDanhMuc = N'Phụ kiện chống rung');

-- =============================================
-- 3. TẠO 3 THIẾT BỊ CHO MỖI DANH MỤC (Tổng cộng 21 sản phẩm đầy đủ thông tin)
-- =============================================
INSERT INTO ThietBi (MaDinhDanhThietBi, TenThietBi, MaDanhMuc, HangSanXuat, Model, SoSeri, GiaThueNgay, GiaTriTaiSan, TrangThai, CongSuat, TrongLuong, DienAp, ThongSoKyThuat) VALUES
-- DM1: Máy ảnh
('CAM-001', N'Sony A7 Mark IV', @dmMayAnh, 'Sony', 'ILCE-7M4', 'SN-A7M4-9812', 350000, 45000000, 'SanSang', N'15W', N'658g', N'7.2V', N'Cảm biến 33MP, Quay 4K 60p, lấy nét mắt thời gian thực'),
('CAM-002', N'Canon EOS R5', @dmMayAnh, 'Canon', 'EOS R5', 'SN-R5-1102', 550000, 68000000, 'SanSang', N'18W', N'738g', N'7.4V', N'Cảm biến 45MP, Quay phim 8K RAW, chống rung 5 trục IBIS'),
('CAM-003', N'Nikon Z6 Mark II', @dmMayAnh, 'Nikon', 'Z6 II', 'SN-Z62-4415', 300000, 36000000, 'SanSang', N'12W', N'705g', N'7.0V', N'Cảm biến 24.5MP, Chip kép EXPEED 6, Chụp liên tiếp 14fps'),

-- DM2: Ống kính
('LNS-001', N'Sony FE 24-70mm f/2.8 GM II', @dmLens, 'Sony', 'SEL2470GM2', 'SN-GM2-0019', 250000, 42000000, 'SanSang', N'N/A', N'695g', N'N/A', N'Khẩu độ f/2.8 toàn dải, thấu kính cao cấp XA, Motor lấy nét XD Linear'),
('LNS-002', N'Canon RF 50mm f/1.2L USM', @dmLens, 'Canon', 'RF5012', 'SN-RF50-8821', 300000, 48000000, 'SanSang', N'N/A', N'950g', N'N/A', N'Ống kính chân dung tối thượng dòng L, Khẩu độ siêu lớn f/1.2'),
('LNS-003', N'Sigma 85mm f/1.4 DG DN Art', @dmLens, 'Sigma', '85 F1.4 Art', 'SN-SG85-3316', 180000, 21000000, 'SanSang', N'N/A', N'630g', N'N/A', N'Dòng Art sắc nét cao, bokeh mịn màng chuyên chân dung bối cảnh'),

-- DM3: Flycam / Drone
('FLY-001', N'DJI Mavic 3 Pro Cine', @dmFlycam, 'DJI', 'Mavic 3 Pro', 'SN-MV3C-5561', 800000, 75000000, 'SanSang', N'65W', N'958g', N'15.4V', N'3 Camera Hasselblad, Hỗ trợ Apple ProRes 422 HQ, Bay 43 phút'),
('FLY-002', N'DJI Air 3 Fly More Combo', @dmFlycam, 'DJI', 'Air 3', 'SN-AIR3-7729', 450000, 28000000, 'SanSang', N'45W', N'720g', N'14.8V', N'Camera kép Medium Tele & Wide, Truyền sóng O4, cảm biến va chạm vật cản'),
('FLY-003', N'DJI Mini 4 Pro', @dmFlycam, 'DJI', 'Mini 4 Pro', 'SN-M4P-1204', 300000, 16000000, 'SanSang', N'30W', N'249g', N'7.7V', N'Trọng lượng siêu nhẹ không cần xin phép bay, quay dọc TikTok 4K60 HDR'),

-- DM4: Máy quay chuyên dụng
('MQU-001', N'Sony FX3 Cinema Line', @dmMayQuay, 'Sony', 'ILME-FX3', 'SN-FX3-4912', 650000, 85000000, 'SanSang', N'22W', N'715g', N'7.2V', N'Máy quay Cinema nhỏ gọn, tản nhiệt quạt chủ động, ISO đỉnh cao 409600'),
('MQU-002', N'Blackmagic Pocket Cinema 6K G2', @dmMayQuay, 'Blackmagic', 'BMPCC 6K G2', 'SN-BM6K-0092', 500000, 52000000, 'SanSang', N'30W', N'1200g', N'12V', N'Cảm biến Super 35 HDR, Ngàm EF thông dụng, Quay Blackmagic RAW chuyên nghiệp'),
('MQU-003', N'Canon EOS C70', @dmMayQuay, 'Canon', 'C70', 'SN-C70-9011', 800000, 115000000, 'SanSang', N'35W', N'1170g', N'14.4V', N'Cảm biến DGO góc rộng, ghi hình 4K 120p, tích hợp filter ND cơ học 10-stop'),

-- DM5: Thiết bị âm thanh
('AUD-001', N'Rode Wireless PRO', @dmAmThanh, 'Rode', 'WPRO', 'SN-RWPRO-8123', 150000, 11000000, 'SanSang', N'5W', N'32g/tx', N'5V Type-C', N'Micro cài áo không dây kỹ thuật số 32-bit float an toàn tuyệt đối chống vỡ âm'),
('AUD-002', N'Máy ghi âm Zoom H6 Black', @dmAmThanh, 'Zoom', 'H6', 'SN-ZH6-4401', 120000, 8500000, 'SanSang', N'4W', N'410g', N'6V (4 Pin AA)', N'Ghi âm đồng thời 6 kênh, đầu mic rời thay thế linh hoạt'),
('AUD-003', N'Sennheiser EW 112P G4', @dmAmThanh, 'Sennheiser', 'G4', 'SN-G4-9923', 200000, 16000000, 'SanSang', N'8W', N'160g', N'3V', N'Micro cài áo UHF chuyên nghiệp cho truyền hình, độ ổn định cực cao'),

-- DM6: Thiết bị chiếu sáng
('LGT-001', N'Aputure Amaran 200d S', @dmAnhSang, 'Aputure', '200dS', 'SN-AP200-5121', 200000, 8000000, 'SanSang', N'200W', N'1560g', N'48V', N'Đèn LED nguồn điểm công suất cao, ánh sáng ban ngày 5600K chuẩn CRI 96+'),
('LGT-002', N'Godox VL150 LED Video Light', @dmAnhSang, 'Godox', 'VL150', 'SN-GD150-1204', 150000, 6800000, 'SanSang', N'150W', N'1970g', N'16.8V', N'Đèn spotlight nhỏ gọn kèm hộp điều khiển rời, hỗ trợ pin V-mount di động'),
('LGT-003', N'Đèn thanh Nanlite Pavotube 30C', @dmAnhSang, 'Nanlite', 'Pavotube 30C', 'SN-PT30C-7711', 100000, 5500000, 'SanSang', N'32W', N'850g', N'15V', N'Đèn dạng ống RGBWW đa màu sắc tạo hiệu ứng bối cảnh độc đáo'),

-- DM7: Phụ kiện chống rung
('GMB-001', N'Gimbal DJI Ronin RS 3 Pro', @dmGimbal, 'DJI', 'RS3 Pro', 'SN-RS3P-8822', 250000, 21000000, 'SanSang', N'N/A', N'1500g', N'15.4V', N'Tải trọng lớn 4.5kg, khóa trục tự động, cánh tay sợi carbon siêu cứng'),
('GMB-002', N'Zhiyun Crane 4', @dmGimbal, 'Zhiyun', 'Crane 4', 'SN-CR4-5512', 200000, 14000000, 'SanSang', N'N/A', N'1670g', N'16V', N'Tích hợp đèn báo cân bằng, màn hình cảm ứng, tải trọng tốt cho cinema camera'),
('GMB-003', N'Tripod Manfrotto 504X', @dmGimbal, 'Manfrotto', '504X', 'SN-MF504-0193', 150000, 18000000, 'SanSang', N'N/A', N'3500g', N'N/A', N'Chân tế quay phim củ dầu mượt mà, chịu tải 12kg cân mọi dòng máy lớn');

-- =============================================
-- 4. TẠO DỮ LIỆU KHÁCH HÀNG (ĐỂ CHỌN TRÊN APP)
-- =============================================
INSERT INTO KhachHang (MaDinhDanhKhachHang, TenCongTy, NguoiDaiDien, SoDienThoai, Email, DiaChi, MaSoThue) VALUES 
('KH-001', N'Studio Ảnh Cưới Lavender', N'Nguyễn Thị Hương', '0901234567', 'huong.lavender@gmail.com', N'123 Nguyễn Huệ, Quận 1, TPHCM', '0312345678'),
('KH-002', N'Công ty Truyền thông MediaMax', N'Trần Văn Minh', '0912345678', 'minh.tv@mediamax.vn', N'456 Lê Lợi, Quận 3, TPHCM', '0312345679'),
('KH-003', N'Ê-kíp Production King', N'Lê Hoàng Nam', '0923456789', 'nam.production@gmail.com', N'77 Hoàng Diệu, Quận 4, TPHCM', NULL);

DECLARE @khStudio INT = (SELECT MaKhachHang FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH-001');
DECLARE @khMedia INT  = (SELECT MaKhachHang FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH-002');
DECLARE @khFreelance INT = (SELECT MaKhachHang FROM KhachHang WHERE MaDinhDanhKhachHang = 'KH-003');

-- =============================================
-- 5. KỊCH BẢN HỢP ĐỒNG ĐỂ DEMO TRỰC QUAN (ĐA DẠNG TRẠNG THÁI)
-- =============================================

-- Kịch bản 1: Hợp đồng HD001 - ĐÃ KẾT THÚC VÀ ĐÃ THU HỒI (Có phát sinh lỗi hỏng hóc)
INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, NgayKetThucThucTe, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
VALUES ('HD-2026-0001', @khStudio, '2026-06-01', '2026-06-05', '2026-06-06', 1750000, 1000000, 'DaKetThuc', @adminId, N'Thuê trọn bộ chụp ảnh phóng sự cưới');

DECLARE @hd1 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0001');
DECLARE @tbMayAnh1 INT = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM-001');

INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
VALUES (@hd1, @tbMayAnh1, 350000, 1750000, N'Sony A7 Mark IV (Thuê 5 ngày)');

-- Phiếu thu hồi cho HD001 (Báo trả trễ 1 ngày và làm hỏng máy phải đưa đi bảo trì)
INSERT INTO PhieuThuHoi (MaHopDong, NgayTra, SoNgayTre, TienPhatTre, PhiHuHong, TongTienPhaiThanhToan, CoHuHong, GhiChuHuHong, MaNguoiNhan)
VALUES (@hd1, '2026-06-06', 1, 150000, 500000, 650000, 1, N'Thiết bị trả muộn 1 ngày. Kính ngắm EVF bị va đập nứt nhẹ.', @empId);

-- Lịch sử luân chuyển tương ứng cho HD001
INSERT INTO LichSuLuanChuyen (MaThietBi, LoaiLuanChuyen, MaHopDongLienQuan, TrangThaiTruoc, TrangThaiSau, GhiChu, MaNguoiThucHien)
VALUES 
(@tbMayAnh1, 'XuatThue', @hd1, 'SanSang', 'DangChoThue', N'Xuất kho cho studio Lavender', @empId),
-- Sửa comment: Khi thu hồi máy hỏng chuyển sang trạng thái Bảo Trì
(@tbMayAnh1, 'DiBaoTri', @hd1, 'DangChoThue', 'BaoTri', N'Nhập hồi phát hiện hư hỏng kính ngắm', @empId);


-- Kịch bản 2: Hợp đồng HD002 - ĐANG HIỆU LỰC (Máy đang đi thuê thực tế)
INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, NgayKetThucThucTe, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
VALUES ('HD-2026-0002', @khMedia, '2026-06-09', '2026-06-14', NULL, 4250000, 2000000, 'DangHieuLuc', @adminId, N'Thuê quay TVC nhãn hàng');

DECLARE @hd2 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0002');
DECLARE @tbCanonR5 INT = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'CAM-002');
DECLARE @tbLensCanon INT = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'LNS-002');

INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu) VALUES 
(@hd2, @tbCanonR5, 550000, 2750000, N'Canon EOS R5 (5 ngày)'),
(@hd2, @tbLensCanon, 300000, 1500000, N'Lens Canon RF 50mm f/1.2L'); 

INSERT INTO LichSuLuanChuyen (MaThietBi, LoaiLuanChuyen, MaHopDongLienQuan, TrangThaiTruoc, TrangThaiSau, GhiChu, MaNguoiThucHien) VALUES 
(@tbCanonR5, 'XuatThue', @hd2, 'SanSang', 'DangChoThue', N'Bàn giao thân máy quay TVC', @empId),
(@tbLensCanon, 'XuatThue', @hd2, 'SanSang', 'DangChoThue', N'Bàn giao lens chân dung đi kèm', @empId);


-- Kịch bản 3: Hợp đồng HD003 - HỢP ĐỒNG ĐƯỢC GIA HẠN THÀNH CÔNG
INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, NgayKetThucThucTe, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
VALUES ('HD-2026-0003', @khFreelance, '2026-06-05', '2026-06-12', NULL, 3900000, 1500000, 'GiaHan', @adminId, N'Thuê làm phim ngắn tốt nghiệp');

DECLARE @hd3 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0003');
DECLARE @tbAir3 INT = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'FLY-002');
DECLARE @tbMic INT = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'AUD-003');

INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu) VALUES 
(@hd3, @tbAir3, 450000, 2250000, N'Flycam DJI Air 3 (Dự kiến ban đầu 5 ngày)'),
(@hd3, @tbMic, 200000, 1000000, N'Mic Sennheiser EW 112P G4');

-- Thêm dữ liệu bảng gia hạn mở rộng thêm 2 ngày thuê
INSERT INTO GiaHanHopDong (MaHopDong, NgayKetThucCu, NgayKetThucMoi, SoTienBoSung, LyDoGiaHan, MaNguoiThucHien)
VALUES (@hd3, '2026-06-10', '2026-06-12', 1300000, N'Đoàn phim phát sinh thêm bối cảnh quay ngoại ô', @adminId);

-- Cập nhật tổng tiền hợp đồng sau khi cộng thêm tiền gia hạn
UPDATE HopDong SET TongTien = 5200000 WHERE MaHopDong = @hd3;


-- Kịch bản 4: Hợp đồng HD004 - HỢP ĐỒNG BỊ QUÁ HẠN (Khách chưa mang trả máy)
INSERT INTO HopDong (MaDinhDanhHopDong, MaKhachHang, NgayBatDau, NgayKetThucDuKien, NgayKetThucThucTe, TongTien, TienCoc, TrangThai, MaNguoiTao, GhiChu)
VALUES ('HD-2026-0004', @khFreelance, '2026-05-20', '2026-05-25', NULL, 500000, 500000, 'QuaHan', @adminId, N'Khách quên lịch trả, cần nhân viên gọi điện hối thúc');

DECLARE @hd4 INT = (SELECT MaHopDong FROM HopDong WHERE MaDinhDanhHopDong = 'HD-2026-0004');
-- 🔥 SỬA LỖI TẠI ĐÂY: Thay 'ACC-004' bằng 'LGT-003' đã tồn tại ở Bước 3
DECLARE @tbLed INT = (SELECT MaThietBi FROM ThietBi WHERE MaDinhDanhThietBi = 'LGT-003');

INSERT INTO ChiTietHopDong (MaHopDong, MaThietBi, GiaThueThoiDiem, ThanhTien, GhiChu)
VALUES (@hd4, @tbLed, 100000, 500000, N'Đèn thanh Nanlite Pavotube 30C (Quá hạn chưa trả)');

INSERT INTO LichSuLuanChuyen (MaThietBi, LoaiLuanChuyen, MaHopDongLienQuan, TrangThaiTruoc, TrangThaiSau, GhiChu, MaNguoiThucHien)
VALUES (@tbLed, 'XuatThue', @hd4, 'SanSang', 'DangChoThue', N'Xuất kho đèn quay bối cảnh phim ngắn', @empId);


-- =============================================
-- 6. ĐỒNG BỘ TRẠNG THÁI THIẾT BỊ VÀ THÔNG BÁO HỆ THỐNG
-- =============================================

-- Cập nhật máy hỏng sang Bảo Trì
UPDATE ThietBi SET TrangThai = 'BaoTri' WHERE MaDinhDanhThietBi = 'CAM-001';

-- Cập nhật các máy đang trong hợp đồng hoạt động (HD002, HD003, HD004) sang Đang Cho Thuê
UPDATE ThietBi SET TrangThai = 'DangChoThue' 
WHERE MaDinhDanhThietBi IN ('CAM-002', 'LNS-002', 'FLY-002', 'AUD-003', 'LGT-003');

-- Tạo hệ thống thông báo mẫu (Bản tin Dashboard)
INSERT INTO ThongBao (TieuDe, NoiDung, LoaiThongBao, DaDoc) VALUES 
(N'Cảnh báo quá hạn', N'Hợp đồng HD-2026-0004 của Lê Hoàng Nam đã quá hạn chưa làm thủ tục thu hồi!', 'QuaHan', 0),
(N'Thiết bị sự cố', N'Thiết bị "Sony A7 Mark IV" đã chuyển sang trạng thái bảo trì do hư hỏng từ hợp đồng HD-2026-0001.', 'BaoTri', 0),
(N'Yêu cầu gia hạn', N'Yêu cầu gia hạn hợp đồng HD-2026-0003 thêm 2 ngày đã được phê duyệt bởi Admin.', 'GiaHan', 1),
(N'Hợp đồng mới', N'Nhân viên Ngô Quốc Bình vừa lập hợp đồng mới HD-2026-0002 trị giá 4,250,000đ.', 'HopDong', 1);

PRINT N'✅ [SUCCESS] Đã sửa lỗi đồng bộ! Toàn bộ 21 thiết bị và 4 kịch bản hợp đồng đã được nạp thành công!';