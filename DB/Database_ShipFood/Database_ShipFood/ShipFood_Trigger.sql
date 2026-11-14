CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_audit_thay_doi_trang_thai
AFTER
UPDATE
    OF trangthai ON
    tbDonHang
FOR EACH ROW
    WHEN (OLD.trangthai IS NULL
        OR NEW.trangthai <> OLD.trangthai)
BEGIN
        INSERT
    INTO
    tbLichSuTrangThaiDon (
        madh,
        trangthai_cu,
        trangthai_moi,
        thoigian,
        ghichu
    )
VALUES (
        :NEW.madh,
        :OLD.trangthai,
        :NEW.trangthai,
        SYSTIMESTAMP,
        'Tự động ghi bởi trigger'
    );
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_kiem_soat_trang_thai_don
BEFORE
UPDATE
    OF trangthai ON
    tbDonHang
FOR EACH ROW
DECLARE
        v_old VARCHAR2(50) := NVL(:OLD.trangthai, 'NULL');

v_new VARCHAR2(50) := :NEW.trangthai;
BEGIN
    -- Cho phép giữ nguyên trạng thái
    IF v_old = v_new THEN
        RETURN;
END IF;
-- Các chuyển trạng thái hợp lệ
    IF NOT (
           (v_old = 'Chờ xác nhận'
    AND v_new IN ('Đã đặt', 'Hủy đơn'))
    OR (v_old = 'Đã đặt'
        AND v_new IN ('Đang chuẩn bị', 'Đang giao', 'Hủy đơn'))
        OR (v_old = 'Đang chuẩn bị'
            AND v_new IN ('Đang giao', 'Hủy đơn'))
            OR (v_old = 'Đang giao'
                AND v_new IN ('Hoàn thành', 'Hủy đơn'))
                OR (v_old = 'Hoàn thành'
                    AND v_new = 'Hoàn thành')
                -- không cho đổi nữa
                OR (v_old = 'Hủy đơn'
                    AND v_new = 'Hủy đơn')
    ) THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Không được phép chuyển trạng thái từ "' || v_old || '" sang "' || v_new || '"');
END IF;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_tu_dong_ngay_giao_thanh_toan
BEFORE
UPDATE
    OF trangthai ON
    tbDonHang
FOR EACH ROW
BEGIN
        -- Khi chuyển sang "Đã đặt" → ghi ngày thanh toán
    IF :NEW.trangthai = 'Đã đặt'
        AND NVL(:OLD.trangthai, 'X') <> 'Đã đặt' THEN
        :NEW.ngaythanhtoan := SYSTIMESTAMP;
END IF;
-- Khi chuyển sang "Hoàn thành" → ghi ngày giao hàng
    IF :NEW.trangthai = 'Hoàn thành'
AND NVL(:OLD.trangthai, 'X') <> 'Hoàn thành' THEN
        :NEW.ngaygiaohang := SYSTIMESTAMP;
END IF;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_xu_ly_dong_tien_don_hang
AFTER
UPDATE
    OF trangthai ON
    tbDonHang
FOR EACH ROW
DECLARE
        v_userid_kh NUMBER(10);

v_so_du NUMBER(15, 2);
BEGIN
    -- Lấy userid khách hàng
BEGIN
        SELECT
    userid
INTO
    v_userid_kh
FROM
    tbThongTinDatHang
WHERE
    mattdh = :NEW.mattdh;

EXCEPTION
WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 
                'Không tìm thấy thông tin đặt hàng (mattdh = ' || :NEW.mattdh || ')');
END;
------------------------------------------------------------------
-- 1. Chuyển sang 'Đã đặt' → trừ tiền khách
------------------------------------------------------------------
    IF :NEW.trangthai = 'Đã đặt'
AND NVL(:OLD.trangthai, 'X') <> 'Đã đặt' THEN
-- Khóa dòng để tránh race condition
        SELECT
    vitien
INTO
    v_so_du
FROM
    tbUser
WHERE
    userid = v_userid_kh 
        FOR
UPDATE;
    
    IF v_so_du < :NEW.tongtien THEN
            RAISE_APPLICATION_ERROR(-20002, 
                'Số dư không đủ để thanh toán. ' ||
                'Cần: ' || TO_CHAR(:NEW.tongtien, '999G999G999') || 
                ', Hiện có: ' || TO_CHAR(v_so_du, '999G999G999'));
END IF;

UPDATE
    tbUser
SET
    vitien = vitien - :NEW.tongtien
WHERE
    userid = v_userid_kh;
------------------------------------------------------------------
-- 2. Hủy đơn → chỉ hoàn tiền nếu trước đó đã trừ (đã ở trạng thái 'Đã đặt')
------------------------------------------------------------------
    ELSIF :NEW.trangthai = 'Hủy đơn'
AND NVL(:OLD.trangthai, 'X') <> 'Hủy đơn'
AND :OLD.trangthai = 'Đã đặt' THEN

        UPDATE
    tbUser
SET
    vitien = vitien + :NEW.tongtien
WHERE
    userid = v_userid_kh;
------------------------------------------------------------------
-- 3. Hoàn thành → chia tiền Quán + Shipper
------------------------------------------------------------------
    ELSIF :NEW.trangthai = 'Hoàn thành'
AND NVL(:OLD.trangthai, 'X') <> 'Hoàn thành' THEN
-- Tiền quán
        UPDATE
    tbUser
SET
    vitien = vitien + (:NEW.tongtien - NVL(:NEW.phiship, 0) - NVL(:NEW.phidichvu, 0))
WHERE
    userid = :NEW.maquan;
-- Tiền shipper
        IF :NEW.mashipper IS NOT NULL THEN
            UPDATE
    tbUser
SET
    vitien = vitien + NVL(:NEW.phiship, 0)
WHERE
    userid = :NEW.mashipper;
END IF;
END IF;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_xu_ly_khuyen_mai_khi_huy
AFTER
UPDATE
    OF trangthai ON
    tbDonHang
FOR EACH ROW
    WHEN (NEW.trangthai = 'Hủy đơn'
        AND NVL(OLD.trangthai, 'X') <> 'Hủy đơn')
BEGIN
        -- Chỉ xóa nếu đơn này có dùng khuyến mãi
    IF :NEW.makhuyenmai IS NOT NULL THEN
        DELETE
FROM
    tbLichSuSuDungKhuyenMai
WHERE
    madh = :NEW.madh
    AND makm = :NEW.makhuyenmai;
END IF;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_bao_ve_don_hoan_thanh
BEFORE
INSERT
    OR
UPDATE
    OR
DELETE
    ON
    tbChiTietDonHang
FOR EACH ROW
DECLARE
        v_trangthai VARCHAR2(50);

v_madh NUMBER(10);
BEGIN
    IF INSERTING
    OR UPDATING THEN
        v_madh := :NEW.madh;
ELSE
        v_madh := :OLD.madh;
END IF;

SELECT
    trangthai
INTO
    v_trangthai
FROM
    tbDonHang
WHERE
    madh = v_madh;

IF v_trangthai IN ('Hoàn thành', 'Hủy đơn') THEN
        RAISE_APPLICATION_ERROR(-20011,
            'Không được phép thêm/sửa/xóa món của đơn đã "' || v_trangthai || '" (madh = ' || v_madh || ')');
END IF;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_luu_madh_thay_doi
AFTER
INSERT
    OR
UPDATE
    OR
DELETE
    ON
    tbChiTietDonHang
FOR EACH ROW
BEGIN
        IF INSERTING
        OR UPDATING THEN
        pkg_don_hang_state.v_madh_list(:NEW.madh) := :NEW.madh;

ELSIF DELETING THEN
        pkg_don_hang_state.v_madh_list(:OLD.madh) := :OLD.madh;
END IF;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_tinh_lai_tien_sau_lenh
AFTER
INSERT
    OR
UPDATE
    OR
DELETE
    ON
    tbChiTietDonHang
DECLARE
        v_madh NUMBER(10);

v_tong_tien_mon NUMBER(15, 2);
BEGIN
    v_madh := pkg_don_hang_state.v_madh_list.FIRST;

WHILE v_madh IS NOT NULL
LOOP
    -- Tính tổng tiền món ăn hiện tại
        SELECT
    NVL(SUM(soluong * dongia), 0)
        INTO
    v_tong_tien_mon
FROM
    tbChiTietDonHang
WHERE
    madh = v_madh;
-- Cập nhật vào hóa đơn chính tbDonHang
        UPDATE
    tbDonHang
SET
    tongtien = v_tong_tien_mon + NVL(phiship, 0) + NVL(phidichvu, 0)
WHERE
    madh = v_madh;

v_madh := pkg_don_hang_state.v_madh_list.NEXT(v_madh);
END
LOOP;
-- Xóa sạch mảng tạm thời sau khi xử lý xong câu lệnh
pkg_don_hang_state.v_madh_list.DELETE;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_cap_nhat_danh_gia_quan
AFTER
INSERT
    ON
    tbDanhGia
FOR EACH ROW
DECLARE
        v_maquanan NUMBER(10);

v_avg_diem NUMBER(2, 1);

v_count NUMBER(10);
BEGIN
    -- Tìm mã quán ăn quản lý món ăn nằm trong chi tiết đơn hàng vừa được đánh giá
    SELECT
    m.maquanan
INTO
    v_maquanan
FROM
    tbChiTietDonHang c
JOIN tbBienTheMonAn b ON
    c.mamon = b.id
JOIN tbMonAn m ON
    b.mamon = m.mamon
WHERE
    c.mactdh = :NEW.mactdh;
-- Tính toán lại tổng số lượt và điểm trung bình mới của Quán
    SELECT
    COUNT(*),
    ROUND(AVG(g.diemdanhgia), 1)
    INTO
    v_count,
    v_avg_diem
FROM
    tbDanhGia g
JOIN tbChiTietDonHang c ON
    g.mactdh = c.mactdh
JOIN tbBienTheMonAn b ON
    c.mamon = b.id
JOIN tbMonAn m ON
    b.mamon = m.mamon
WHERE
    m.maquanan = v_maquanan;
-- Cập nhật ngược lại vào hồ sơ Quán ăn
    UPDATE
    tbQuanAn
SET
    soluotdanhgia = v_count,
        diemdanhgia = v_avg_diem
WHERE
    userid = v_maquanan;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_cap_nhat_diem_quan
AFTER
INSERT
    OR
UPDATE
    OR
DELETE
    ON
    tbDanhGia
FOR EACH ROW
DECLARE
        v_maquan NUMBER(10);

v_diem_tb NUMBER(3, 1);

v_so_luot NUMBER(10);
BEGIN
    -- Lấy mã quán từ chi tiết đơn → đơn hàng
BEGIN
        IF INSERTING
        OR UPDATING THEN
            SELECT
    d.maquan
INTO
    v_maquan
FROM
    tbChiTietDonHang c
JOIN tbDonHang d ON
    d.madh = c.madh
WHERE
    c.mactdh = :NEW.mactdh;
ELSE
            SELECT
    d.maquan
INTO
    v_maquan
FROM
    tbChiTietDonHang c
JOIN tbDonHang d ON
    d.madh = c.madh
WHERE
    c.mactdh = :OLD.mactdh;
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
            RETURN;
-- không tìm thấy thì bỏ qua
END;
-- Tính lại điểm trung bình và số lượt
    SELECT
    ROUND(AVG(g.diemdanhgia), 1),
           COUNT(*)
    INTO
    v_diem_tb,
    v_so_luot
FROM
    tbDanhGia g
JOIN tbChiTietDonHang c ON
    c.mactdh = g.mactdh
JOIN tbDonHang d ON
    d.madh = c.madh
WHERE
    d.maquan = v_maquan;
-- Cập nhật quán
    UPDATE
    tbQuanAn
SET
    diemdanhgia = NVL(v_diem_tb, 0),
           soluotdanhgia = NVL(v_so_luot, 0)
WHERE
    userid = v_maquan;
END;

CREATE OR REPLACE
TRIGGER SHIPFOOD.trg_cap_nhat_diem_shipper
AFTER
INSERT
    OR
UPDATE
    OR
DELETE
    ON
    tbDanhGia
FOR EACH ROW
DECLARE
        v_mashipper NUMBER(10);

v_diem_tb NUMBER(3, 1);

v_so_luot NUMBER(10);
BEGIN
    -- Lấy mashipper từ đơn hàng
BEGIN
        IF INSERTING
        OR UPDATING THEN
            SELECT
    d.mashipper
INTO
    v_mashipper
FROM
    tbChiTietDonHang c
JOIN tbDonHang d ON
    d.madh = c.madh
WHERE
    c.mactdh = :NEW.mactdh;
ELSE
            SELECT
    d.mashipper
INTO
    v_mashipper
FROM
    tbChiTietDonHang c
JOIN tbDonHang d ON
    d.madh = c.madh
WHERE
    c.mactdh = :OLD.mactdh;
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
            RETURN;
END;
-- Nếu đơn chưa có shipper thì bỏ qua
    IF v_mashipper IS NULL THEN
        RETURN;
END IF;
-- Tính lại điểm trung bình và số lượt của shipper
    SELECT
    ROUND(AVG(g.diemdanhgia), 1),
           COUNT(*)
    INTO
    v_diem_tb,
    v_so_luot
FROM
    tbDanhGia g
JOIN tbChiTietDonHang c ON
    c.mactdh = g.mactdh
JOIN tbDonHang d ON
    d.madh = c.madh
WHERE
    d.mashipper = v_mashipper;
-- Cập nhật shipper
    UPDATE
    tbShipper
SET
    diemdanhgia = NVL(v_diem_tb, 0),
           soluotdanhgia = NVL(v_so_luot, 0)
WHERE
    userid = v_mashipper;
END;
