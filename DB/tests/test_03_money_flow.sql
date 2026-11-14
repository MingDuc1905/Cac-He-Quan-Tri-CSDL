-- ==============================================================================
-- KỊCH BẢN KIỂM THỬ 3: XỬ LÝ DÒNG TIỀN VÍ & HOA HỒNG (TRG_XU_LY_DONG_TIEN_DON_HANG)
-- ==============================================================================
-- Mục tiêu: Kiểm chứng trigger tính toán trừ tiền ví khách và cộng tiền quán/shipper:
--  - Chặn ORA-20002 nếu số dư ví khách không đủ khi chuyển sang 'Đã đặt'
--  - Tự động cộng tiền quán (tongtien - phiship - phidichvu) và tiền shipper khi 'Hoàn thành'
-- ==============================================================================

SET SERVEROUTPUT ON;

-- 3.0 Tạo user test có số dư ví ít (chỉ có 10.000đ)
INSERT INTO tbUser (userid, username, password, email, sdt, trangthai, vitien)
VALUES (9990, 'test_khach_ngheo', '123456', 'ngheo@test.com', '0999000111', 1, 10000);

INSERT INTO tbThongTinDatHang (mattdh, tennguoinhan, sdt, diachi, userid)
VALUES (9990, 'Khách Nghèo', '0999000111', '123 Test Street', 9990);

-- Tạo đơn hàng giá trị 120.000đ (vượt quá 10.000đ ví)
INSERT INTO tbDonHang (
    madh, ngaydathang, trangthai, tongtien, phiship, phidichvu,
    maquan, mattdh, hinhthucthanhtoan
) VALUES (
    7777, SYSTIMESTAMP, 'Chờ xác nhận', 120000, 15000, 5000,
    1, 9990, 1 -- HTTT 1: Ví điện tử
);
COMMIT;

PROMPT ====================================================================
PROMPT 3.1 Thử đặt đơn khi số dư ví không đủ (Kỳ vọng: Lỗi ORA-20002)
PROMPT ====================================================================
BEGIN
    UPDATE tbDonHang
    SET trangthai = 'Đã đặt'
    WHERE madh = 7777;

    PROMPT -> THẤT BẠI: Lẽ ra trigger phải phát hiện số dư không đủ!
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('-> BẮT ĐƯỢC LỖI KỲ VỌNG: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('-> Trigger trg_xu_ly_dong_tien_don_hang chặn trừ tiền âm thành công.');
END;
/

PROMPT ====================================================================
PROMPT 3.2 Nạp tiền ví khách và thử lại chuyển sang 'Đã đặt' (Kỳ vọng: Thành công)
PROMPT ====================================================================
UPDATE tbUser SET vitien = 500000 WHERE userid = 9990;
COMMIT;

UPDATE tbDonHang SET trangthai = 'Đã đặt' WHERE madh = 7777;
COMMIT;

SELECT vitien AS vitien_sau_khi_tru
FROM tbUser WHERE userid = 9990;
PROMPT -> Thành công: Ví khách đã bị trừ 120.000đ từ 500.000đ còn 380.000đ.

PROMPT ====================================================================
PROMPT 3.3 Chuyển đơn sang 'Hoàn thành' (Kỳ vọng: Quán và Shipper được nhận tiền)
PROMPT ====================================================================
-- Gán shipper cho đơn hàng
UPDATE tbDonHang SET mashipper = 1 WHERE madh = 7777;
UPDATE tbDonHang SET trangthai = 'Đang giao' WHERE madh = 7777;
COMMIT;

-- Xem số dư quán và shipper trước khi hoàn thành đơn
SELECT u.username, u.vitien
FROM tbUser u
WHERE u.userid IN (SELECT userid FROM tbQuanAn WHERE userid = 1
                   UNION
                   SELECT userid FROM tbShipper WHERE userid = 1);

-- Chuyển hoàn thành đơn
UPDATE tbDonHang SET trangthai = 'Hoàn thành' WHERE madh = 7777;
COMMIT;

-- Xem số dư quán và shipper sau khi hoàn thành đơn
SELECT u.username, u.vitien AS vitien_sau_hoan_thanh
FROM tbUser u
WHERE u.userid IN (SELECT userid FROM tbQuanAn WHERE userid = 1
                   UNION
                   SELECT userid FROM tbShipper WHERE userid = 1);
PROMPT -> Thành công: Tiền món đã cộng cho quán, phí ship đã cộng cho shipper.

-- Dọn dẹp dữ liệu test
DELETE FROM tbLichSuTrangThaiDon WHERE madh = 7777;
DELETE FROM tbDonHang WHERE madh = 7777;
DELETE FROM tbThongTinDatHang WHERE mattdh = 9990;
DELETE FROM tbUser WHERE userid = 9990;
COMMIT;
PROMPT Đã dọn dẹp dữ liệu test TC3.
