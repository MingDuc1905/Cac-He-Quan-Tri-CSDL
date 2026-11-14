-- ===============================================================
-- SHIPFOOD - BO SUNG DU LIEU MAU
-- Oracle Database 23ai
-- Chay SAU khi da chay ShipFood_SeedData.sql goc.
-- ===============================================================

-- 1. Tắt trigger Bảo vệ đơn hàng vì đơn hàng madh=25 đang là hoàn thành
ALTER TRIGGER trg_bao_ve_don_hoan_thanh DISABLE;

-- 2. Chạy hết script để Update Database

-- 3. Bật lại trigger Bảo vệ đơn hàng sau khi update database
ALTER TRIGGER trg_bao_ve_don_hoan_thanh ENABLE;

-- ===============================================================


-- 1. Hinh thuc thanh toan (DonHang bat buoc tham chieu MAHTTT)
INSERT INTO tbLoaiHinhThanhToan (tenhinhthuc, mota)
SELECT 'Tiền mặt khi nhận hàng', 'Thanh toán tiền mặt cho shipper khi nhận món'
FROM dual
WHERE NOT EXISTS (
    SELECT 1 FROM tbLoaiHinhThanhToan
    WHERE tenhinhthuc = 'Tiền mặt khi nhận hàng'
);

INSERT INTO tbLoaiHinhThanhToan (tenhinhthuc, mota)
SELECT 'Ví điện tử MoMo', 'Thanh toán trực tuyến qua ví MoMo'
FROM dual
WHERE NOT EXISTS (
    SELECT 1 FROM tbLoaiHinhThanhToan
    WHERE tenhinhthuc = 'Ví điện tử MoMo'
);

-- 2. Thông tin nhận hàng cho 3 khách hàng có sẵn: userid 1, 2, 5
INSERT INTO tbThongTinDatHang (sdt, diachi, toado, tennguoinhan, userid)
SELECT '0987654321', '12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh',
       NULL, 'Trần Thị B', 1
FROM dual
WHERE NOT EXISTS (
    SELECT 1 FROM tbThongTinDatHang
    WHERE userid = 1 AND diachi = '12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh'
);

INSERT INTO tbThongTinDatHang (sdt, diachi, toado, tennguoinhan, userid)
SELECT '0901234567', '25 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh',
       NULL, 'Lê Văn C', 2
FROM dual
WHERE NOT EXISTS (
    SELECT 1 FROM tbThongTinDatHang
    WHERE userid = 2 AND diachi = '25 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh'
);

INSERT INTO tbThongTinDatHang (sdt, diachi, toado, tennguoinhan, userid)
SELECT '0977777777', '88 Cách Mạng Tháng 8, Quận 3, TP. Hồ Chí Minh',
       NULL, 'Phạm Thị D', 5
FROM dual
WHERE NOT EXISTS (
    SELECT 1 FROM tbThongTinDatHang
    WHERE userid = 5 AND diachi = '88 Cách Mạng Tháng 8, Quận 3, TP. Hồ Chí Minh'
);

-- 3. Món ăn: MAQUANAN là USERID của quán; MADANHMUC: 1=Đồ ăn, 2=Đồ uống.
-- 10 món mẫu thuộc các quán đã được tạo trong seed gốc.
INSERT INTO tbMonAn (tenmon, mota, hinhanh, maquanan, madanhmuc, conhang, isDeleted)
SELECT x.tenmon, x.mota, 'https://unsplash.com', x.maquanan, x.madanhmuc, TRUE, FALSE
FROM (
    SELECT 'Pizza phô mai' tenmon, 'Pizza phủ phô mai mozzarella' mota, 6 maquanan, 1 madanhmuc FROM dual UNION ALL
    SELECT 'Pizza xúc xích', 'Pizza xúc xích và phô mai', 6, 1 FROM dual UNION ALL
    SELECT 'Cơm gà chiên mắm', 'Cơm nóng ăn kèm gà chiên nước mắm', 7, 1 FROM dual UNION ALL
    SELECT 'Cơm sườn trứng', 'Cơm sườn nướng và trứng ốp la', 7, 1 FROM dual UNION ALL
    SELECT 'Bún đậu thập cẩm', 'Bún đậu, chả cốm, thịt luộc và nem', 8, 1 FROM dual UNION ALL
    SELECT 'Đậu hũ chiên', 'Đậu hũ chiên giòn ăn kèm rau', 8, 1 FROM dual UNION ALL
    SELECT 'Bún mắm đặc biệt', 'Bún mắm với tôm, mực và cá', 12, 1 FROM dual UNION ALL
    SELECT 'Gà tre nướng', 'Gà tre nướng nguyên con', 13, 1 FROM dual UNION ALL
    SELECT 'Sushi cá hồi', 'Sushi cá hồi tươi', 14, 1 FROM dual UNION ALL
    SELECT 'Trà đào cam sả', 'Trà đào kết hợp cam và sả', 11, 2 FROM dual
) x
WHERE NOT EXISTS (
    SELECT 1 FROM tbMonAn m
    WHERE m.tenmon = x.tenmon AND m.maquanan = x.maquanan
);

-- 4. Biến thể món ăn. ID tự sinh theo sequence mặc định của bảng.
INSERT INTO tbBienTheMonAn (mamon, tensize, giatien)
SELECT m.mamon, v.tensize, v.giatien
FROM (
    SELECT 'Pizza phô mai' tenmon, 6 maquanan, 'Nhỏ' tensize, 89000 giatien FROM dual UNION ALL
    SELECT 'Pizza phô mai', 6, 'Lớn', 139000 FROM dual UNION ALL
    SELECT 'Pizza xúc xích', 6, 'Nhỏ', 99000 FROM dual UNION ALL
    SELECT 'Pizza xúc xích', 6, 'Lớn', 149000 FROM dual UNION ALL
    SELECT 'Cơm gà chiên mắm', 7, 'Thường', 45000 FROM dual UNION ALL
    SELECT 'Cơm gà chiên mắm', 7, 'Đặc biệt', 59000 FROM dual UNION ALL
    SELECT 'Cơm sườn trứng', 7, 'Thường', 50000 FROM dual UNION ALL
    SELECT 'Cơm sườn trứng', 7, 'Đặc biệt', 65000 FROM dual UNION ALL
    SELECT 'Bún đậu thập cẩm', 8, 'Nhỏ', 55000 FROM dual UNION ALL
    SELECT 'Bún đậu thập cẩm', 8, 'Lớn', 79000 FROM dual UNION ALL
    SELECT 'Đậu hũ chiên', 8, 'Phần', 25000 FROM dual UNION ALL
    SELECT 'Bún mắm đặc biệt', 12, 'Tô thường', 55000 FROM dual UNION ALL
    SELECT 'Bún mắm đặc biệt', 12, 'Tô lớn', 70000 FROM dual UNION ALL
    SELECT 'Gà tre nướng', 13, 'Nửa con', 180000 FROM dual UNION ALL
    SELECT 'Gà tre nướng', 13, 'Nguyên con', 340000 FROM dual UNION ALL
    SELECT 'Sushi cá hồi', 14, '6 miếng', 85000 FROM dual UNION ALL
    SELECT 'Sushi cá hồi', 14, '10 miếng', 135000 FROM dual UNION ALL
    SELECT 'Trà đào cam sả', 11, 'M', 30000 FROM dual UNION ALL
    SELECT 'Trà đào cam sả', 11, 'L', 39000 FROM dual
) v
JOIN tbMonAn m
  ON m.tenmon = v.tenmon AND m.maquanan = v.maquanan
WHERE NOT EXISTS (
    SELECT 1 FROM tbBienTheMonAn b
    WHERE b.mamon = m.mamon AND b.tensize = v.tensize
);

-- 5. Đơn hàng mẫu. MADH tự sinh; mỗi đơn tham chiếu thông tin nhận hàng,
-- quán ăn và hình thức thanh toán đã có.
INSERT INTO tbDonHang
    (maquan, mattdh, trangthai, tongtien, hinhthucthanhtoan,
     ghichu, makhuyenmai, phiship, phidichvu, mashipper)
SELECT x.maquan, t.mattdh, x.trangthai, x.tongtien, h.mahttt,
       x.ghichu, NULL, x.phiship, x.phidichvu, x.mashipper
FROM (
    SELECT 1 userid, 6 maquan, 'Chờ xác nhận' trangthai, 0 tongtien,
           'Giao giờ hành chính' ghichu, 15000 phiship, 2000 phidichvu, CAST(NULL AS NUMBER) mashipper,
           '12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh' diachi FROM dual UNION ALL
    SELECT 2, 7, 'Đã đặt', 0, 'Ít cơm, thêm nước mắm', 18000, 2000, CAST(NULL AS NUMBER),
           '25 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh' FROM dual UNION ALL
    SELECT 5, 8, 'Đang chuẩn bị', 0, 'Không lấy rau thơm', 12000, 2000, CAST(NULL AS NUMBER),
           '88 Cách Mạng Tháng 8, Quận 3, TP. Hồ Chí Minh' FROM dual UNION ALL
    SELECT 1, 12, 'Đang giao', 0, 'Gọi trước khi giao', 15000, 2000, 3,
           '12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh' FROM dual UNION ALL
    SELECT 2, 14, 'Hoàn thành', 0, 'Để tại quầy bảo vệ', 18000, 2000, 4,
           '25 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh' FROM dual UNION ALL
    SELECT 5, 11, 'Hủy đơn', 0, 'Khách yêu cầu hủy', 12000, 2000, CAST(NULL AS NUMBER),
           '88 Cách Mạng Tháng 8, Quận 3, TP. Hồ Chí Minh' FROM dual
) x
JOIN tbThongTinDatHang t
  ON t.userid = x.userid AND t.diachi = x.diachi
JOIN tbLoaiHinhThanhToan h
  ON h.tenhinhthuc = 'Tiền mặt khi nhận hàng'
WHERE NOT EXISTS (
    SELECT 1 FROM tbDonHang d
    WHERE d.mattdh = t.mattdh
      AND d.maquan = x.maquan
      AND d.ghichu = x.ghichu
);


-- 6. Chi tiết đơn hàng: tham chiếu ID biến thể qua tên món + size.
-- DONGIA là giá tại thời điểm đặt hàng.
INSERT INTO tbChiTietDonHang (madh, mamon, soluong, dongia)
SELECT d.madh, b.id, x.soluong, b.giatien
FROM (
    SELECT 1 userid, 6 maquan, '12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh' diachi,
           'Pizza phô mai' tenmon, 'Nhỏ' tensize, 1 soluong,
           'Giao giờ hành chính' ghichu FROM dual UNION ALL
    SELECT 1, 6, '12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh', 'Pizza xúc xích', 'Nhỏ', 1,
           'Giao giờ hành chính' FROM dual UNION ALL
    SELECT 2, 7, '25 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh',
           'Cơm gà chiên mắm', 'Đặc biệt', 2, 'Ít cơm, thêm nước mắm' FROM dual UNION ALL
    SELECT 2, 7, '25 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh',
           'Cơm sườn trứng', 'Thường', 1, 'Ít cơm, thêm nước mắm' FROM dual UNION ALL
    SELECT 5, 8, '88 Cách Mạng Tháng 8, Quận 3, TP. Hồ Chí Minh',
           'Bún đậu thập cẩm', 'Lớn', 1, 'Không lấy rau thơm' FROM dual UNION ALL
    SELECT 5, 8, '88 Cách Mạng Tháng 8, Quận 3, TP. Hồ Chí Minh',
           'Đậu hũ chiên', 'Phần', 2, 'Không lấy rau thơm' FROM dual UNION ALL
    SELECT 1, 12, '12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh',
           'Bún mắm đặc biệt', 'Tô lớn', 1, 'Gọi trước khi giao' FROM dual UNION ALL
    SELECT 1, 12, '12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh',
           'Bún mắm đặc biệt', 'Tô thường', 1, 'Gọi trước khi giao' FROM dual UNION ALL
    SELECT 2, 14, '25 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh',
           'Sushi cá hồi', '6 miếng', 2, 'Để tại quầy bảo vệ' FROM dual UNION ALL
    SELECT 2, 14, '25 Điện Biên Phủ, Quận Bình Thạnh, TP. Hồ Chí Minh',
           'Sushi cá hồi', '10 miếng', 1, 'Để tại quầy bảo vệ' FROM dual UNION ALL
    SELECT 5, 11, '88 Cách Mạng Tháng 8, Quận 3, TP. Hồ Chí Minh',
           'Trà đào cam sả', 'L', 2, 'Khách yêu cầu hủy' FROM dual
) x
JOIN tbThongTinDatHang t
  ON t.userid = x.userid AND t.diachi = x.diachi
JOIN tbDonHang d
  ON d.mattdh = t.mattdh AND d.maquan = x.maquan AND d.ghichu = x.ghichu
JOIN tbMonAn m
  ON m.tenmon = x.tenmon AND m.maquanan = x.maquan
JOIN tbBienTheMonAn b
  ON b.mamon = m.mamon AND b.tensize = x.tensize
WHERE NOT EXISTS (
    SELECT 1 FROM tbChiTietDonHang c
    WHERE c.madh = d.madh AND c.mamon = b.id
);

-- 7. Cập nhật tổng tiền đơn = tổng chi tiết + phí ship + phí dịch vụ.
UPDATE tbDonHang d
SET d.tongtien =
    NVL((SELECT SUM(c.soluong * c.dongia)
         FROM tbChiTietDonHang c
         WHERE c.madh = d.madh), 0)
    + NVL(d.phiship, 0)
    + NVL(d.phidichvu, 0)
WHERE EXISTS (
    SELECT 1 FROM tbChiTietDonHang c WHERE c.madh = d.madh
);

COMMIT;

-- 8. Kiểm tra kết quả
SELECT m.mamon, m.tenmon, q.tenquanan, dm.tendanhmuc
FROM tbMonAn m
JOIN tbQuanAn q ON q.userid = m.maquanan
LEFT JOIN tbDanhMuc dm ON dm.madanhmuc = m.madanhmuc
ORDER BY m.maquanan, m.mamon;

SELECT b.id, m.tenmon, b.tensize, b.giatien
FROM tbBienTheMonAn b
JOIN tbMonAn m ON m.mamon = b.mamon
ORDER BY m.tenmon, b.id;

SELECT d.madh, t.tennguoinhan, q.tenquanan, d.trangthai,
       d.tongtien, d.ngaydathang
FROM tbDonHang d
JOIN tbThongTinDatHang t ON t.mattdh = d.mattdh
JOIN tbQuanAn q ON q.userid = d.maquan
ORDER BY d.madh;

SELECT c.mactdh, c.madh, m.tenmon, b.tensize, c.soluong, c.dongia,
       c.soluong * c.dongia AS thanhtien
FROM tbChiTietDonHang c
JOIN tbBienTheMonAn b ON b.id = c.mamon
JOIN tbMonAn m ON m.mamon = b.mamon
ORDER BY c.madh, c.mactdh;
