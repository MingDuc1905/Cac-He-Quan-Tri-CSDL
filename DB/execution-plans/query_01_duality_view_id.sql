-- ==============================================================================
-- TRUY VẤN 1: TRUY VẤN DUALITY VIEW THEO ID (DV_DON_HANG)
-- ==============================================================================
-- ⚠️ CHƯA CHẠY TRÊN ORACLE 23AI THẬT. Các bảng plan/Cost dưới đây là SỐ DỰ KIẾN, không phải
-- output thật của DBMS_XPLAN.DISPLAY. Phải chạy lại trên Oracle 23ai thật và dán đúng output.
-- ==============================================================================
-- Ngữ cảnh: Ứng dụng client lấy toàn bộ tài liệu JSON lồng 3 cấp của 1 đơn hàng cụ thể.
-- Bảng liên quan: tbDonHang, tbQuanAn, tbThongTinDatHang, tbLoaiHinhThanhToan,
--                 tbShipper, tbKhuyenMai, tbChiTietDonHang, tbBienTheMonAn, tbMonAn, tbDanhGia
-- ==============================================================================

-- 1. Câu truy vấn kiểm tra
EXPLAIN PLAN FOR
SELECT data
FROM DV_DON_HANG
WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 1;

-- 2. Hiển thị Execution Plan TRƯỚC TỐI ƯU
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*
----------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name               | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                    |     1 |  4096 |    48   (3)| 00:00:01 |
|   1 |  NESTED LOOPS OUTER           |                    |     1 |  4096 |    48   (3)| 00:00:01 |
|   2 |   TABLE ACCESS FULL           | TBDONHANG          |     1 |   128 |    15   (0)| 00:00:01 |
|   3 |   TABLE ACCESS BY INDEX ROWID | TBQUANAN           |     1 |    64 |     2   (0)| 00:00:01 |
|   4 |    INDEX UNIQUE SCAN          | PK_TBQUANAN        |     1 |       |     1   (0)| 00:00:01 |
|   5 |   TABLE ACCESS FULL           | TBCHITIETDONHANG   |    10 |   520 |    18   (0)| 00:00:01 |
|   6 |    TABLE ACCESS FULL          | TBDANHGIA          |     2 |   120 |    12   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------
Nhận xét (plan DỰ KIẾN, chưa chạy thật):
- Bảng tbChiTietDonHang bị Full Table Scan vì chưa có index trên khoá ngoại madh.
- Tương tự bảng tbDanhGia bị Full Table Scan trên mactdh.
- Cost dự kiến ban đầu: ~48 (số minh hoạ, cần thay bằng số thật sau khi chạy EXPLAIN PLAN).
*/

-- 3. Đề xuất Index tối ưu hóa (DDL)
-- Index khoá ngoại liên kết chi tiết đơn hàng tới đơn hàng chính
CREATE INDEX idx_chitietdonhang_madh ON tbChiTietDonHang (madh);

-- Index khoá ngoại liên kết đánh giá tới dòng chi tiết món
CREATE INDEX idx_danhgia_mactdh ON tbDanhGia (mactdh);

-- 4. Chạy lại Execution Plan SAU TỐI ƯU
EXPLAIN PLAN FOR
SELECT data
FROM DV_DON_HANG
WHERE JSON_VALUE(data, '$._id' RETURNING NUMBER) = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*
----------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name                    | Rows | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                         |    1 |  4096 |     9   (0)| 00:00:01 |
|   1 |  NESTED LOOPS OUTER           |                         |    1 |  4096 |     9   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID | TBDONHANG               |    1 |   128 |     2   (0)| 00:00:01 |
|   3 |    INDEX UNIQUE SCAN          | PK_TBDONHANG            |    1 |       |     1   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID | TBCHITIETDONHANG        |    2 |   104 |     2   (0)| 00:00:01 |
|   5 |    INDEX RANGE SCAN           | IDX_CHITIETDONHANG_MADH |    2 |       |     1   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | TBDANHGIA               |    1 |    60 |     2   (0)| 00:00:01 |
|   7 |    INDEX RANGE SCAN           | IDX_DANHGIA_MACTDH      |    1 |       |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------
Đánh giá kết quả tối ưu (DỰ KIẾN, chưa chạy thật):
- TABLE ACCESS FULL trên tbChiTietDonHang dự kiến chuyển thành INDEX RANGE SCAN (idx_chitietdonhang_madh).
- TABLE ACCESS FULL trên tbDanhGia dự kiến chuyển thành INDEX RANGE SCAN (idx_danhgia_mactdh).
- Cost dự kiến giảm (số minh hoạ: 48 -> 9) — PHẢI thay bằng số thật sau khi chạy lại trên Oracle.
*/
