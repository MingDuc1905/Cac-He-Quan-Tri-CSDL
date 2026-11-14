-- ==============================================================================
-- TRUY VẤN 3: LỊCH SỬ CHUYỂN TRẠNG THÁI ĐƠN HÀNG (AUDIT LOG JOIN TBDONHANG)
-- ==============================================================================
-- ⚠️ CHƯA CHẠY TRÊN ORACLE 23AI THẬT. Các bảng plan/Cost dưới đây là SỐ DỰ KIẾN, không phải
-- output thật của DBMS_XPLAN.DISPLAY. Phải chạy lại trên Oracle 23ai thật và dán đúng output.
-- ==============================================================================
-- Ngữ cảnh: Khách hàng hoặc Shipper xem dòng thời gian (Timeline) các mốc trạng thái
-- của đơn hàng để theo dõi tiến trình giao thức ăn.
-- ==============================================================================

-- 1. Câu truy vấn gốc
EXPLAIN PLAN FOR
SELECT l.id, l.madh, l.trangthai_cu, l.trangthai_moi, l.thoigian, l.ghichu, d.tongtien
FROM tbLichSuTrangThaiDon l
JOIN tbDonHang d ON d.madh = l.madh
WHERE l.madh = 1001
ORDER BY l.thoigian ASC;

-- 2. Hiển thị Execution Plan TRƯỚC TỐI ƯU
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*
----------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name               | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                    |     5 |   450 |    24   (5)| 00:00:01 |
|   1 |  SORT ORDER BY                |                    |     5 |   450 |    24   (5)| 00:00:01 |
|   2 |   NESTED LOOPS                |                    |     5 |   450 |    23   (0)| 00:00:01 |
|   3 |    TABLE ACCESS FULL          | TBLICHSUTRANGTHAIDON|    5 |   320 |    20   (0)| 00:00:01 |
|   4 |    TABLE ACCESS BY INDEX ROWID| TBDONHANG          |     1 |    26 |     1   (0)| 00:00:01 |
|   5 |     INDEX UNIQUE SCAN         | PK_TBDONHANG       |     1 |       |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------
Nhận xét (plan DỰ KIẾN, chưa chạy thật):
- Bảng tbLichSuTrangThaiDon bị TABLE ACCESS FULL vì chưa có index trên cột khoá ngoại madh.
- Cần thực hiện SORT ORDER BY trên cột thoigian.
- Cost dự kiến ban đầu: ~24 (số minh hoạ, cần thay bằng số thật).
*/

-- 3. Đề xuất Index tối ưu hóa (DDL)
CREATE INDEX idx_lichsu_madh_thoigian ON tbLichSuTrangThaiDon (madh, thoigian ASC);

-- 4. Chạy lại Execution Plan SAU TỐI ƯU
EXPLAIN PLAN FOR
SELECT l.id, l.madh, l.trangthai_cu, l.trangthai_moi, l.thoigian, l.ghichu, d.tongtien
FROM tbLichSuTrangThaiDon l
JOIN tbDonHang d ON d.madh = l.madh
WHERE l.madh = 1001
ORDER BY l.thoigian ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*
----------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name                    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                         |     5 |   450 |     3   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |                         |     5 |   450 |     3   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID | TBLICHSUTRANGTHAIDON    |     5 |   320 |     2   (0)| 00:00:01 |
|   3 |    INDEX RANGE SCAN           | IDX_LICHSU_MADH_THOIGIAN|     5 |       |     1   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID | TBDONHANG               |     1 |    26 |     1   (0)| 00:00:01 |
|   5 |    INDEX UNIQUE SCAN          | PK_TBDONHANG            |     1 |       |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------
Đánh giá kết quả tối ưu (DỰ KIẾN, chưa chạy thật):
- Bảng tbLichSuTrangThaiDon dự kiến chuyển sang INDEX RANGE SCAN trên index (madh, thoigian).
- Dự kiến triệt tiêu bước SORT ORDER BY nhờ index scan đã trả về dữ liệu đúng thứ tự mong muốn.
- Cost dự kiến giảm (số minh hoạ: 24 -> 3) — PHẢI thay bằng số thật sau khi chạy lại trên Oracle.
*/
