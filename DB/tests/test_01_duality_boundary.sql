-- ==============================================================================
-- KỊCH BẢN KIỂM THỬ 1: DUALITY VIEW BOUNDARY & PERMISSION TEST
-- ==============================================================================
-- Mục tiêu: Kiểm chứng quyền can thiệp dữ liệu qua Duality View DV_DON_HANG:
--  - Cho phép INSERT/UPDATE chiTiet và danhGia (WITH INSERT UPDATE DELETE)
--  - Từ chối sửa trực tiếp quanAn, giaoHang, thanhToan, shipper (WITH NOUPDATE)
-- ==============================================================================

SET SERVEROUTPUT ON;

PROMPT ====================================================================
PROMPT 1.1 Kiểm tra thêm chi tiết món vào đơn hàng (Kỳ vọng: Thành công)
PROMPT ====================================================================

-- Thêm 1 dòng chi tiết đơn hàng trực tiếp
INSERT INTO tbChiTietDonHang (mactdh, madh, mamon, soluong, dongia)
VALUES (99001, 1, 11, 2, 55000);

COMMIT;
PROMPT -> Thành công: Đã thêm chi tiết món vào đơn hàng #1.

PROMPT ====================================================================
PROMPT 1.2 Kiểm tra cập nhật số lượng chi tiết món (Kỳ vọng: Thành công)
PROMPT ====================================================================

UPDATE tbChiTietDonHang
SET soluong = 3
WHERE mactdh = 99001;

COMMIT;
PROMPT -> Thành công: Đã cập nhật số lượng món thành 3.

PROMPT ====================================================================
PROMPT 1.3 Kiểm tra cập nhật qua Duality View trường NOUPDATE (Kỳ vọng: Thất bại)
PROMPT ====================================================================

-- Cố gắng cập nhật thông tin Quán ăn qua JSON Duality View
-- Vì quanAn được khai báo: WITH NOINSERT NOUPDATE NODELETE
-- Nên Oracle 23ai sẽ chặn lại với mã lỗi ORA-42399
BEGIN
    UPDATE DV_DON_HANG d
    SET d.data = JSON_TRANSFORM(
        d.data,
        SET '$.quanAn.tenquanan' = 'Quán Ăn Thay Đổi Bất Hợp Pháp'
    )
    WHERE d.data."_id".number() = 1;
    
    PROMPT -> THẤT BẠI: Lẽ ra Oracle phải chặn câu lệnh này!
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('-> BẮT ĐƯỢC LỖI KỲ VỌNG: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('-> Giải thích: Duality View bảo vệ tính toàn vẹn của bảng quan hệ tbQuanAn.');
END;
/

-- Dọn dẹp dữ liệu test
DELETE FROM tbChiTietDonHang WHERE mactdh = 99001;
COMMIT;
PROMPT Đã dọn dẹp dữ liệu test TC1.
