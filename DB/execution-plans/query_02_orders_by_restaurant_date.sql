-- ==============================================================================
-- TRUY VẤN 2: TRUY VẤN ĐƠN HÀNG THEO QUÁN ĂN, KHOẢNG NGÀY & TRẠNG THÁI
-- ==============================================================================
-- ⚠️ CHƯA CHẠY TRÊN ORACLE 23AI THẬT. Các bảng plan/Cost dưới đây là SỐ DỰ KIẾN, không phải
-- output thật của DBMS_XPLAN.DISPLAY. Phải chạy lại trên Oracle 23ai thật và dán đúng output.
-- ==============================================================================
-- Ngữ cảnh: Màn hình Dashboard chủ quán ăn tra cứu các đơn hàng đã đặt trong ngày
-- để quản lý đơn đang nấu và doanh thu.
-- Tần suất: Rất cao (truy vấn theo thời gian thực mỗi 15-30 giây).
-- ==============================================================================

-- 1. Câu truy vấn gốc
EXPLAIN PLAN FOR
SELECT d.madh, d.ngaydathang, d.trangthai, d.tongtien, t.tennguoinhan, t.sdt
FROM tbDonHang d
JOIN tbThongTinDatHang t ON t.mattdh = d.mattdh
WHERE d.maquan = 1
  AND d.trangthai = 'Đang chuẩn bị'
  AND d.ngaydathang >= TO_TIMESTAMP('2026-11-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
  AND d.ngaydathang <= TO_TIMESTAMP('2026-11-30 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
ORDER BY d.ngaydathang DESC;

-- 2. Hiển thị Execution Plan TRƯỚC TỐI ƯU
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*
----------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name               | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                    |    25 |  2400 |    65   (4)| 00:00:01 |
|   1 |  SORT ORDER BY                |                    |    25 |  2400 |    65   (4)| 00:00:01 |
|   2 |   NESTED LOOPS                |                    |    25 |  2400 |    64   (2)| 00:00:01 |
|   3 |    TABLE ACCESS FULL          | TBDONHANG          |    25 |  1500 |    38   (3)| 00:00:01 |
|   4 |    TABLE ACCESS BY INDEX ROWID| TBTHONGTINDATHANG  |     1 |    36 |     1   (0)| 00:00:01 |
|   5 |     INDEX UNIQUE SCAN         | PK_THONGTINDATHANG |     1 |       |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------
Nhận xét (plan DỰ KIẾN, chưa chạy thật):
- Bảng tbDonHang phải quét toàn bộ bảng (TABLE ACCESS FULL).
- Sau khi lọc xong, hệ thống phải thực hiện bước SORT ORDER BY trên bộ nhớ (tốn CPU và I/O).
- Cost dự kiến ban đầu: ~65 (số minh hoạ, cần thay bằng số thật).
*/

-- 3. Đề xuất Composite Index (Index phức hợp)
-- Tạo index bao trùm cả cột lọc đẳng thức (maquan, trangthai) và cột sắp xếp/khoảng (ngaydathang)
CREATE INDEX idx_donhang_quan_status_date ON tbDonHang (maquan, trangthai, ngaydathang DESC);

-- 4. Chạy lại Execution Plan SAU TỐI ƯU
EXPLAIN PLAN FOR
SELECT d.madh, d.ngaydathang, d.trangthai, d.tongtien, t.tennguoinhan, t.sdt
FROM tbDonHang d
JOIN tbThongTinDatHang t ON t.mattdh = d.mattdh
WHERE d.maquan = 1
  AND d.trangthai = 'Đang chuẩn bị'
  AND d.ngaydathang >= TO_TIMESTAMP('2026-11-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
  AND d.ngaydathang <= TO_TIMESTAMP('2026-11-30 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
ORDER BY d.ngaydathang DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*
----------------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name                         | Rows  | Bytes | Cost (%CPU)| Time |
----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                              |    25 |  2400 |     5   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |                              |    25 |  2400 |     5   (0)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID | TBDONHANG                    |    25 |  1500 |     3   (0)| 00:00:01 |
|   3 |    INDEX RANGE SCAN           | IDX_DONHANG_QUAN_STATUS_DATE |    25 |       |     2   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID | TBTHONGTINDATHANG            |     1 |    36 |     1   (0)| 00:00:01 |
|   5 |    INDEX UNIQUE SCAN          | PK_THONGTINDATHANG           |     1 |       |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------------
Đánh giá kết quả tối ưu (DỰ KIẾN, chưa chạy thật):
- Dự kiến triệt tiêu bước SORT ORDER BY vì dữ liệu trong index đã được lưu theo thứ tự `ngaydathang DESC`.
- Bảng tbDonHang dự kiến chuyển từ TABLE ACCESS FULL sang INDEX RANGE SCAN trên index phức hợp mới tạo.
- Cost dự kiến giảm (số minh hoạ: 65 -> 5) — PHẢI thay bằng số thật sau khi chạy lại trên Oracle.
*/
