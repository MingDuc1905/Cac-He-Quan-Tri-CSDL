# Báo Cáo Phân Tích & Tối Ưu Hóa Execution Plan (ShipFood)

> ⚠️ **CHƯA CHẠY TRÊN ORACLE 23AI THẬT.** Toàn bộ số Cost/Rows/Bytes trong 3 file
> `query_0X_*.sql` và bảng tổng hợp bên dưới là **số liệu ước lượng dự kiến** (suy luận theo
> cấu trúc bảng/số dòng dữ liệu mẫu, không phải output thật của `DBMS_XPLAN.DISPLAY`). Bắt
> buộc phải chạy lại `EXPLAIN PLAN` thật trên Oracle 23ai sau khi cài xong, dán đúng output thật
> vào các file này và cập nhật lại % giảm cost — tuyệt đối không mang số liệu dự kiến này vào
> báo cáo/slide nộp hay dùng để trả lời vấn đáp, vì giám khảo có thể yêu cầu demo lại ngay tại
> chỗ và số liệu không khớp sẽ bị coi là gian lận dữ liệu.

Tài liệu này trình bày hướng phân tích kế hoạch thực thi (Execution Plan) trước và sau tối ưu hoá bằng Index cho 3 truy vấn cốt lõi trong hệ thống ShipFood trên Oracle Database 23ai — cùng với các DDL index đề xuất, chờ chạy thật để lấy số liệu chính xác.

---

## 1. Bảng Tổng Hợp Chi Phí Trước & Sau Tối Ưu

| Truy vấn | Mục đích nghiệp vụ | Cost Trước (dự kiến) | Cost Sau (dự kiến) | Tỷ lệ giảm (dự kiến) | Bước tối ưu chính |
|---|---|:---:|:---:|:---:|---|
| **Query 1** | Lấy JSON Duality View theo ID (`DV_DON_HANG`) | **48*** | **9*** | **~-81%*** | Chuyển `TABLE ACCESS FULL` trên `tbChiTietDonHang` và `tbDanhGia` sang `INDEX RANGE SCAN`. |
| **Query 2** | Dashboard quán: Lọc đơn theo ngày & trạng thái | **65*** | **5*** | **~-92%*** | Loại bỏ hoàn toàn bước `SORT ORDER BY`; dùng Composite Index `(maquan, trangthai, ngaydathang DESC)`. |
| **Query 3** | Timeline lịch sử chuyển trạng thái đơn hàng | **24*** | **3*** | **~-87%*** | Index `(madh, thoigian ASC)` loại bỏ bước sort và chuyển quét toàn bảng sang Range Scan. |

*\* Số dự kiến, chưa chạy `EXPLAIN PLAN` thật — xem cảnh báo ở đầu file.*

---

## 2. Danh Mục Các Lệnh DDL Tạo Index Đề Xuất

Các câu lệnh sau được tổng hợp để chạy trực tiếp trên schema `SHIPFOOD`:

```sql
-- 1. Tối ưu hoá truy vấn Duality View chi tiết đơn và đánh giá
CREATE INDEX idx_chitietdonhang_madh ON tbChiTietDonHang (madh);
CREATE INDEX idx_danhgia_mactdh ON tbDanhGia (mactdh);

-- 2. Tối ưu hoá Dashboard quán ăn (Composite Index)
CREATE INDEX idx_donhang_quan_status_date ON tbDonHang (maquan, trangthai, ngaydathang DESC);

-- 3. Tối ưu hoá tra cứu lịch sử audit trạng thái đơn
CREATE INDEX idx_lichsu_madh_thoigian ON tbLichSuTrangThaiDon (madh, thoigian ASC);
```

---

## 3. Cẩm Nang Trả Lời Vấn Đáp (Tiêu Chí 8 — Rubric Đồ Án)

### Câu hỏi 1: *"Giải thích execution plan trước/sau tối ưu — chi phí giảm ở bước nào?"*
> **Gợi ý trả lời (phải thay số liệu dự kiến bằng số liệu thật đã tự chạy trước khi dùng câu
> này để trả lời vấn đáp!)**:
> "Trong hệ thống ShipFood, trước khi tối ưu, khi truy vấn `DV_DON_HANG` lồng 3 cấp, Oracle phải thực hiện `TABLE ACCESS FULL` trên bảng `tbChiTietDonHang` và `tbDanhGia` vì chưa có index trên các khoá ngoại `madh` và `mactdh`. Sau khi em tạo 2 index `idx_chitietdonhang_madh` và `idx_danhgia_mactdh`, bộ tối ưu CBO (Cost-Based Optimizer) đã chuyển sang `INDEX RANGE SCAN`, giúp chi phí (Cost) giảm đáng kể (số liệu cụ thể: điền sau khi chạy `EXPLAIN PLAN` thật).
>
> Đặc biệt ở Query 2 (Dashboard quán ăn), em đã thiết kế **Composite Index** `(maquan, trangthai, ngaydathang DESC)`. Nhờ đưa cột sắp xếp vào index, Oracle đã triệt tiêu hoàn toàn bước `SORT ORDER BY` trên bộ nhớ Temp/PGA (số liệu cụ thể: điền sau khi chạy thật)."

### Câu hỏi 2: *"JSON Relational Duality View giúp gì cho việc xây dựng REST API so với cách làm truyền thống?"*
> **Gợi ý trả lời**:
> "Trong mô hình truyền thống (như EF Core hay JPA), để lấy một đơn hàng gồm quán, địa chỉ, người nhận, các món ăn và đánh giá, lập trình viên phải viết câu truy vấn JOIN 6–8 bảng hoặc phát sinh lỗi N+1 Query; khi ghi dữ liệu phải tự viết code bóc tách transaction chèn vào từng bảng con.
>
> Với Oracle 23ai Duality Views kết hợp ORDS:
> 1. Toàn bộ tài liệu JSON được sinh tự động ngay trong CSDL, ứng dụng chỉ cần gọi `GET /ords/shipfood/dv_don_hang/{id}` là nhận đủ JSON lồng 3 cấp.
> 2. Khi client `POST` hoặc `PUT`, ORDS tự động ánh xạ JSON xuống các bảng quan hệ tương ứng (`tbDonHang`, `tbChiTietDonHang`) theo các quy tắc bảo mật `WITH INSERT UPDATE DELETE` được định nghĩa sẵn.
> 3. Các trigger kiểm soát nghiệp vụ (như trigger trừ tiền ví, trigger kiểm soát trạng thái) vẫn tự động kích hoạt đầy đủ mà không bị bỏ qua."
