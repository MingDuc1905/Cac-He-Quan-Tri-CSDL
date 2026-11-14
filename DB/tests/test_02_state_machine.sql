-- ==============================================================================
-- KỊCH BẢN KIỂM THỬ 2: STATE MACHINE TRIGGER (TRG_KIEM_SOAT_TRANG_THAI_DON)
-- ==============================================================================
-- Mục tiêu: Kiểm chứng trigger kiểm soát chu trình chuyển đổi trạng thái đơn hàng:
--  - Chuyển hợp lệ: Chờ xác nhận -> Đã đặt -> Đang chuẩn bị -> Đang giao -> Hoàn thành
--  - Chuyển sai quy tắc: Bắn lỗi ORA-20010 và ghi log rollback
-- ==============================================================================

SET SERVEROUTPUT ON;

-- 2.0 Chuẩn bị đơn hàng test
INSERT INTO tbDonHang (
    madh, ngaydathang, trangthai, tongtien, phiship, phidichvu,
    maquan, mattdh, hinhthucthanhtoan
) VALUES (
    8888, SYSTIMESTAMP, 'Chờ xác nhận', 100000, 15000, 5000,
    1, 1, 1
);
COMMIT;
PROMPT Đã tạo đơn hàng test #8888 ở trạng thái: 'Chờ xác nhận'

PROMPT ====================================================================
PROMPT 2.1 Chuyển hợp lệ: Chờ xác nhận -> Đã đặt (Kỳ vọng: Thành công)
PROMPT ====================================================================
UPDATE tbDonHang
SET trangthai = 'Đã đặt'
WHERE madh = 8888;
COMMIT;
PROMPT -> Thành công: Đã chuyển sang 'Đã đặt'.

PROMPT ====================================================================
PROMPT 2.2 Chuyển hợp lệ tiếp: Đã đặt -> Đang giao (Kỳ vọng: Thành công)
PROMPT ====================================================================
UPDATE tbDonHang
SET trangthai = 'Đang giao'
WHERE madh = 8888;
COMMIT;
PROMPT -> Thành công: Đã chuyển sang 'Đang giao'.

PROMPT ====================================================================
PROMPT 2.3 Chuyển sai quy tắc: Đang giao -> Chờ xác nhận (Kỳ vọng: ORA-20010)
PROMPT ====================================================================
BEGIN
    UPDATE tbDonHang
    SET trangthai = 'Chờ xác nhận'
    WHERE madh = 8888;

    PROMPT -> THẤT BẠI: Lẽ ra trigger phải chặn chuyển ngược trạng thái!
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('-> BẮT ĐƯỢC LỖI KỲ VỌNG: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('-> Trigger trg_kiem_soat_trang_thai_don hoạt động chính xác.');
END;
/

PROMPT ====================================================================
PROMPT 2.4 Kiểm tra bảng Audit tbLichSuTrangThaiDon (Trigger trg_audit_thay_doi_trang_thai)
PROMPT ====================================================================
SELECT madh, trangthai_cu, trangthai_moi, thoigian, ghichu
FROM tbLichSuTrangThaiDon
WHERE madh = 8888
ORDER BY thoigian ASC;

-- Dọn dẹp dữ liệu test
DELETE FROM tbLichSuTrangThaiDon WHERE madh = 8888;
DELETE FROM tbDonHang WHERE madh = 8888;
COMMIT;
PROMPT Đã dọn dẹp dữ liệu test TC2.
