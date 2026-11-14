-- ==============================================================================
-- KỊCH BẢN KIỂM THỬ 4: BẢO VỆ ĐƠN HÀNG ĐÃ HOÀN TẤT / HỦY (TRG_BAO_VE_DON_HOAN_THANH)
-- ==============================================================================
-- Mục tiêu: Kiểm chứng trigger bảo toàn dữ liệu lịch sử kế toán:
--  - Chặn sửa/xoá dòng chi tiết món của đơn đã 'Hoàn thành' hoặc 'Hủy đơn' (ORA-20011)
-- ==============================================================================

SET SERVEROUTPUT ON;

-- 4.0 Tạo đơn hàng đã Hoàn thành và 1 dòng chi tiết
INSERT INTO tbDonHang (
    madh, ngaydathang, trangthai, tongtien, phiship, phidichvu,
    maquan, mattdh, hinhthucthanhtoan
) VALUES (
    6666, SYSTIMESTAMP, 'Hoàn thành', 80000, 15000, 5000,
    1, 1, 1
);

INSERT INTO tbChiTietDonHang (mactdh, madh, mamon, soluong, dongia)
VALUES (66601, 6666, 1, 1, 60000);
COMMIT;

PROMPT ====================================================================
PROMPT 4.1 Thử sửa số lượng món của đơn đã 'Hoàn thành' (Kỳ vọng: ORA-20011)
PROMPT ====================================================================
BEGIN
    UPDATE tbChiTietDonHang
    SET soluong = 5
    WHERE mactdh = 66601;

    PROMPT -> THẤT BẠI: Lẽ ra trigger phải cấm sửa chi tiết đơn đã hoàn tất!
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('-> BẮT ĐƯỢC LỖI KỲ VỌNG: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('-> Trigger trg_bao_ve_don_hoan_thanh bảo vệ tính toàn vẹn kế toán.');
END;
/

PROMPT ====================================================================
PROMPT 4.2 Thử xoá dòng chi tiết của đơn đã 'Hoàn thành' (Kỳ vọng: ORA-20011)
PROMPT ====================================================================
BEGIN
    DELETE FROM tbChiTietDonHang
    WHERE mactdh = 66601;

    PROMPT -> THẤT BẠI: Lẽ ra trigger phải cấm xoá món của đơn đã hoàn tất!
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('-> BẮT ĐƯỢC LỖI KỲ VỌNG: ' || SQLERRM);
END;
/

-- Dọn dẹp dữ liệu test (Tạm thời chuyển về 'Chờ xác nhận' trước khi xoá để qua mặt trigger)
UPDATE tbDonHang SET trangthai = 'Chờ xác nhận' WHERE madh = 6666;
DELETE FROM tbChiTietDonHang WHERE mactdh = 66601;
DELETE FROM tbDonHang WHERE madh = 6666;
COMMIT;
PROMPT Đã dọn dẹp dữ liệu test TC4.
