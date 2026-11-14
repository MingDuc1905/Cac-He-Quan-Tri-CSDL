-- ==============================================================================
-- KỊCH BẢN KIỂM THỬ 5: TÍNH ĐIỂM TRUNG BÌNH ĐÁNH GIÁ (TRG_CAP_NHAT_DIEM_QUAN & SHIPPER)
-- ==============================================================================
-- Mục tiêu: Kiểm chứng trigger tự động tổng hợp (aggregation) điểm đánh giá:
--  - Khi thêm mới hoặc cập nhật tbDanhGia, điểm trung bình và số lượt của Quán ăn
--    và Shipper được tự động tính lại chính xác.
-- ==============================================================================

SET SERVEROUTPUT ON;

-- 5.0 Xem điểm và số lượt đánh giá ban đầu của quán ăn ID = 1 và shipper ID = 1
SELECT userid, tenquanan, diemdanhgia, soluotdanhgia FROM tbQuanAn WHERE userid = 1;
SELECT userid, tenshipper, diemdanhgia, soluotdanhgia FROM tbShipper WHERE userid = 1;

-- 5.1 Tạo đơn hàng hoàn thành để có mactdh hợp lệ
INSERT INTO tbDonHang (
    madh, ngaydathang, trangthai, tongtien, phiship, phidichvu,
    maquan, mashipper, mattdh, hinhthucthanhtoan
) VALUES (
    5555, SYSTIMESTAMP, 'Hoàn thành', 70000, 15000, 5000,
    1, 1, 1, 1
);

INSERT INTO tbChiTietDonHang (mactdh, madh, mamon, soluong, dongia)
VALUES (55501, 5555, 1, 1, 50000);
COMMIT;

PROMPT ====================================================================
PROMPT 5.2 Thêm đánh giá 5 sao cho đơn hàng #5555
PROMPT ====================================================================
INSERT INTO tbDanhGia (
    madg, mactdh, diemdanhgia, nhanxet, ngaydanhgia
) VALUES (
    55599, 55501, 5, 'Món ăn rất ngon, giao siêu nhanh!', SYSTIMESTAMP
);
COMMIT;

PROMPT -> Đã thêm tbDanhGia 5 sao. Kiểm tra lại Quán và Shipper:
SELECT userid, tenquanan, diemdanhgia, soluotdanhgia FROM tbQuanAn WHERE userid = 1;
SELECT userid, tenshipper, diemdanhgia, soluotdanhgia FROM tbShipper WHERE userid = 1;

PROMPT ====================================================================
PROMPT 5.3 Cập nhật đánh giá từ 5 sao xuống 1 sao (Kỳ vọng: Điểm giảm ngay lập tức)
PROMPT ====================================================================
UPDATE tbDanhGia
SET diemdanhgia = 1, nhanxet = 'Đồ ăn nguội, giao nhầm món!'
WHERE madg = 55599;
COMMIT;

PROMPT -> Đã sửa tbDanhGia thành 1 sao. Kiểm tra điểm mới:
SELECT userid, tenquanan, diemdanhgia, soluotdanhgia FROM tbQuanAn WHERE userid = 1;
SELECT userid, tenshipper, diemdanhgia, soluotdanhgia FROM tbShipper WHERE userid = 1;

-- Dọn dẹp dữ liệu test
DELETE FROM tbDanhGia WHERE madg = 55599;
UPDATE tbDonHang SET trangthai = 'Chờ xác nhận' WHERE madh = 5555;
DELETE FROM tbChiTietDonHang WHERE mactdh = 55501;
DELETE FROM tbDonHang WHERE madh = 5555;
COMMIT;

-- Kích hoạt cập nhật lại điểm chuẩn cho quán và shipper
UPDATE tbQuanAn SET diemdanhgia = 4.5, soluotdanhgia = 10 WHERE userid = 1;
UPDATE tbShipper SET diemdanhgia = 4.8, soluotdanhgia = 10 WHERE userid = 1;
COMMIT;
PROMPT Đã dọn dẹp dữ liệu test TC5.
