-- ===============================================================
-- SHIPFOOD - Oracle Database 23ai Seed Data
-- ===============================================================

-- Xoá dữ liệu cũ bằng cú pháp Oracle trước khi seed (Duy trì thứ tự để tránh lỗi FK)
-- Bật nếu bạn muốn xóa sạch dữ liệu cũ để chạy lại từ đầu:
/*
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbChiTietDonHang';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbDanhGia';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbTinNhan';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbDonHang';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbThongTinDatHang';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbMonAnKhuyenMai';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbKhuyenMai';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbBienTheMonAn';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbMonAn';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbDanhMuc';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbQuanAn';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbShipper';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbKhachHang';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbAdmin';
EXECUTE IMMEDIATE 'TRUNCATE TABLE tbUser';
*/
ALTER USER SHIPFOOD QUOTA UNLIMITED ON USERS;

-- ==================== tbUser ====================
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(1,  'tranthib',       'abcdef',        'Khách hàng', '0987654321', 2000.00,    'tranthib@example.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(2,  'levanc',         'qwerty',        'Khách hàng', '0901234567', 1500.00,    'levanc@example.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(3,  'shippery',       'shipy456',      'Shipper',     '0955555555', 1000.00,    'shippery@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(4,  'shipperz',       'shipz789',      'Shipper',     '0966666666', 1200.00,    'shipperz@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(5,  'phamthid',       'xyz123',        'Khách hàng', '0977777777', 1800.00,    'phamthid@example.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(6,  'konekopizza',    'konekopizza',   'Quán ăn',    '0922227262', 10000.00,   'konekopizza@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(7,  'com1990nvs',     'com1990nvs',    'Quán ăn',    '0632563451', 10000000.00, 'com1990@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(8,  'bundaugiadi',    'bundaugiadi',   'Quán ăn',    '0632586299', 50000000.00, 'bundaugiadi@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(9,  'quanchayanlactam', 'quanchayanlactam', 'Quán ăn', '0986123487', 4000000.00,  'chayanlactam@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(10, 'changanuongbahong', 'changanuongbahong', 'Quán ăn', '0728973833', 130000000.00, 'changanuongbahong@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(11, 'tralong',        'tralong',       'Quán ăn',    '0286472897', 130000000.00, 'tralong@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(12, 'bunmambadong',   'bunmambadong',  'Quán ăn',    '0905816478', 130000000.00, 'bunmambadong@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(13, 'danghoanggatre', 'danghoanggatre', 'Quán ăn',   '0902123654', 130000000.00, 'danghoanggatre@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(14, 'sushitotoro',    'sushitotoro',   'Quán ăn',    '0286677897', 130000000.00, 'sushitotoro@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(15, '43bakery',       '43bakery',      'Quán ăn',    '0164982356', 30000000.00,  '43bakery@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(16, 'admin1',         'admin1',        'Admin',       '0902122309', 0.00,        'admin1@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(17, 'admin2',         'admin2',        'Admin',       '0286673478', 0.00,        'admin2@gmail.com', 1);
INSERT INTO tbUser (userid, username, pwd, loaitaikhoan, sdt, vitien, email, trangthai) VALUES
(18, 'admin3',         'admin3',        'Admin',       '0383766899', 0.00,        'admin3@gmail.com', 1);

-- ==================== tbAdmin ====================
INSERT INTO tbAdmin (userid, tenadmin) VALUES (16, 'Admin 1');
INSERT INTO tbAdmin (userid, tenadmin) VALUES (17, 'Admin 2');
INSERT INTO tbAdmin (userid, tenadmin) VALUES (18, 'Admin 3');

-- ==================== tbKhachHang ====================
INSERT INTO tbKhachHang (userid, tenkh) VALUES (1, 'Tran Thi B');
INSERT INTO tbKhachHang (userid, tenkh) VALUES (2, 'Le Van C');
INSERT INTO tbKhachHang (userid, tenkh) VALUES (5, 'Pham Thi D');

-- ==================== tbShipper ====================
INSERT INTO tbShipper (userid, tenshipper, diachi, toado, diemdanhgia, soluotdanhgia, trangthai, hinhanh) VALUES
(3, 'Le Van Y', '48 Cao Thắng, P.Thanh Bình, Quận 3, TP. Hồ Chí Minh', NULL, 4, 80, 'Không hoạt động', 'https://unsplash.com');
INSERT INTO tbShipper (userid, tenshipper, diachi, toado, diemdanhgia, soluotdanhgia, trangthai, hinhanh) VALUES
(4, 'Nguyen Thi Z', '80 Huỳnh Ngọc Huệ,  Quận Tân Bình, TP. Hồ Chí Minh', NULL, 5, 120, 'Đang hoạt động', 'https://unsplash.com');

-- ==================== tbQuanAn ====================
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(6, 'Koneko Pizza', 'K57H10/12 Bà Bang Nhãn, P. Hòa Hải,  Quận Bình Thạnh, TP. Hồ Chí Minh', NULL, 75, 5, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(7, 'Cơm 1990 - Ngô Văn Sở', '61 Ngô Văn Sở, P.Hòa Khánh Nam,  Quận 12, TP. Hồ Chí Minh', NULL, 300, 5, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(8, 'Bún Đậu Mắm Tôm Gia Di - Nguyễn Văn Thoại', '100 Nguyễn Văn Thoại, P. Mỹ An,  Quận Bình Thạnh, TP. Hồ Chí Minh', NULL, 100, 5, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(9, 'Quán Chay An Lạc Tâm - Phan Đăng Lưu', '117 Phan Đăng Lưu, P. Hòa Cường Bắc,  Quận 3, TP. Hồ Chí Minh', NULL, 100, 5, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(10, 'Chân Gà Nướng Bà Hồng - Trần Cao Vân', '151 Trần Cao Vân, P. Tam Thuận,  Quận Tân Bình, TP. Hồ Chí Minh', NULL, 400, 5, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(11, 'Trà Long - Trà Trái Cây', '149/11 Lê Đình Lý,  Quận 3, TP. Hồ Chí Minh', NULL, 300, 5, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(12, 'Bún Mắm Bà Đông', '145 Huỳnh Thúc Kháng, P. Bình Hiên,  Quận 3, TP. Hồ Chí Minh', NULL, 70, 5, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(13, 'Đàng Hoàng - Gà Tre Đèo Le', '90 Huỳnh Ngọc Huệ,  Quận Tân Bình, TP. Hồ Chí Minh', NULL, 100, 5, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(14, 'Sushi Totoro - Sushi Của Người Việt', '51 Châu Thị Vĩnh Tế, P. Bắc Mỹ Phú, Quận Bình Thạnh, TP. Hồ Chí Minh', NULL, 200, 4, 'Đang mở cửa', 'https://unsplash.com');
INSERT INTO tbQuanAn (userid, tenquanan, diachi, toado, soluotdanhgia, diemdanhgia, trangthai, hinhanh) VALUES
(15, '43 Bakery - Bánh Mì & Bánh Kem - Ngũ Hành Sơn', '149 Ngũ Hành Sơn, P. Mỹ An, Quận Bình Thạnh, TP. Hồ Chí Minh', NULL, 200, 5, 'Đang mở cửa', 'https://unsplash.com');

-- ==================== tbDanhMuc ====================
INSERT INTO tbDanhMuc (madanhmuc, tendanhmuc, mota, hinhanh) VALUES (1, 'Đồ ăn', 'Các món ăn khác nhau từ nhiều nền văn hóa và phong cách ẩm thực khác nhau.', 'https://unsplash.com');
INSERT INTO tbDanhMuc (madanhmuc, tendanhmuc, mota, hinhanh) VALUES (2, 'Đồ uống', 'Các loại đồ uống như nước ngọt, nước trái cây, nước ép, nước lọc, trà, cà phê, cocktail, và nhiều loại đồ uống khác.', 'https://unsplash.com');


