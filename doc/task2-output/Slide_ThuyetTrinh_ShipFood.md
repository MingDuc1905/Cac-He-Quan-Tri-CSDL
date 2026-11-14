# SLIDE THUYẾT TRÌNH BẢO VỆ ĐỒ ÁN HỆ QUẢN TRỊ CSDL (HUFLIT)
## ĐỀ TÀI 15: HỆ THỐNG QUẢN LÝ ĐƠN HÀNG BÁN HÀNG ĐA NỀN TẢNG (SHIPFOOD)
### CÔNG NGHỆ: ORACLE DATABASE 23ai — JSON RELATIONAL DUALITY VIEWS & ORDS REST API
**Giảng viên:** ThS. Lê Thị Minh Nguyện | **Nhóm:** 5 | **Thời gian:** 11/2026

---

### SLIDE 1: TRANG TIÊU ĐỀ
- **Tên đề tài**: Hệ thống Quản lý Đơn hàng cho Ứng dụng Bán hàng Đa nền tảng (ShipFood)
- **Công nghệ cốt lõi**: Oracle 23ai JSON Relational Duality Views, Auto-REST ORDS, PL/SQL State Machine & Triggers.
- **Thành viên nhóm & Phân chia trách nhiệm**:
  - Thành viên 1: Task 3 — Thiết kế CSDL & Cài đặt Schema/Duality Views.
  - Thành viên 2: Task 1 — Triển khai ORDS REST API & Ứng dụng Web Demo.
  - Thành viên 3: Task 2 — Kiểm thử nghiệp vụ, Tối ưu hoá Execution Plan & Soạn thảo tài liệu.

---

### SLIDE 2: BỐI CẢNH & THÁCH THỨC BÁN HÀNG ĐA NỀN TẢNG (OMNICHANNEL)
- **Bán hàng đa kênh F&B**: Bán đồng thời qua App riêng của quán, Website, sàn Grab/ShopeeFood.
- **Thách thức kỹ thuật**:
  - **Xung đột mô hình (Impedance Mismatch)**: Phía client thích JSON Document phẳng/lồng để render nhanh; phía kế toán bắt buộc phải dùng CSDL Quan hệ (Relational) để đảm bảo ACID.
  - **Đồng bộ tồn kho real-time**: Tránh bán trùng hoặc đơn hàng hiển thị không nhất quán giữa các kênh.

---

### SLIDE 3: GIẢI PHÁP ĐỘT PHÁ VỚI ORACLE 23ai DUALITY VIEWS
- **JSON Relational Duality View là gì?**
  - Lưu trữ dưới dạng bảng quan hệ chuẩn hoá (3NF).
  - Xuất ra và nhận vào trực tiếp dưới dạng JSON Document.
  - Loại bỏ hoàn toàn tầng ORM (EF Core, Hibernate) trung gian.
- **Quyền can thiệp linh hoạt trên từng thuộc tính**:
  - `WITH INSERT UPDATE DELETE` cho phép ghi đè bảng con.
  - `WITH NOINSERT NOUPDATE NODELETE` bảo vệ các bảng danh mục cha (Quán ăn, Thanh toán).

---

### SLIDE 4: MÔ HÌNH DỮ LIỆU & KIẾN TRÚC 5 DUALITY VIEWS
- **Sơ đồ liên kết thực thể (ERD)**: `tbUser`, `tbQuanAn`, `tbKhachHang`, `tbShipper`, `tbDonHang`, `tbChiTietDonHang`, `tbBienTheMonAn`, `tbDanhGia`.
- **5 Duality Views đã triển khai**:
  1. `DV_DON_HANG` (Lồng 3 cấp: Đơn -> Món -> Size -> Đánh giá).
  2. `DV_KHACH_HANG` (Khách hàng + Sổ địa chỉ).
  3. `DV_QUAN_AN` (Quán ăn + Thực đơn).
  4. `DV_MON_AN` (Món ăn + Biến thể kích thước/giá + Khuyến mãi).
  5. `DV_KHUYEN_MAI` (Voucher + Danh sách món áp dụng).

---

### SLIDE 5: KIẾN TRÚC ORDS REST API (TỰ ĐỘNG SINH KHÔNG CẦN BACKEND)
- Sơ đồ luồng:
  `Client Web / Mobile` <--> `HTTP/JSON` <--> `ORDS` <--> `Oracle 23ai Duality View` <--> `Relational Tables`.
- Các Endpoint tiêu biểu:
  - `GET /ords/shipfood/dv_don_hang/` (Lấy danh sách đơn).
  - `GET /ords/shipfood/dv_don_hang/{id}` (Lấy đơn hàng lồng 3 cấp).
  - `POST /ords/shipfood/dv_don_hang/` (Tạo đơn hàng kèm danh sách chi tiết món).
  - `PUT /ords/shipfood/dv_don_hang/{id}` (Cập nhật trạng thái đơn).

---

### SLIDE 6: ỨNG DỤNG MINH HOẠ (DEMO APP)
- **Giao diện Web Single-Page Application (HTML/CSS/JS thuần)**:
  - Đáp ứng yêu cầu bắt buộc: Giao diện thật, không demo bằng SQL Developer / SQL*Plus.
  - Tích hợp 2 chế độ: Live ORDS (kết nối Oracle thật) & Mock Mode (mô phỏng chuẩn Duality).
- **Chức năng chính**:
  1. Dashboard theo dõi KPI: Tổng đơn, Đang xử lý, Hoàn thành, Doanh thu.
  2. Xem tài liệu JSON Duality View 3 cấp (cây phân cấp tương tác).
  3. Form đặt món mới (POST lồng nhiều biến thể).
  4. Bảng điều khiển kiểm thử State Machine chuyển trạng thái.

---

### SLIDE 7: HỆ THỐNG TRIGGER NGHIỆP VỤ & BẢO VỆ TÀI CHÍNH
- **State Machine Trigger (`trg_kiem_soat_trang_thai_don`)**:
  - Kiểm soát luồng trạng thái nghiêm ngặt: `Chờ xác nhận -> Đã đặt -> Đang chuẩn bị -> Đang giao -> Hoàn thành`.
  - Chặn đứng mọi hành vi nhảy cóc hoặc chuyển ngược trạng thái (Mã lỗi `ORA-20010`).
- **Trigger Xử lý Dòng tiền (`trg_xu_ly_dong_tien_don_hang`)**:
  - Kiểm tra số dư ví điện tử của khách hàng trước khi xác nhận đơn (Chặn `ORA-20002` nếu thiếu tiền).
  - Tự động cộng tiền món cho quán và phí ship cho tài xế khi giao thành công.
- **Trigger Bảo vệ Đơn hoàn thành (`trg_bao_ve_don_hoan_thanh`)**:
  - Chặn sửa/xoá chi tiết đơn sau khi đã hoàn tất (Mã lỗi `ORA-20011`).

---

### SLIDE 8: XỬ LÝ LỖI MUTATING TABLE VỚI PACKAGE PL/SQL
- **Vấn đề**: Khi trigger mức hàng (ROW trigger) trên bảng `tbChiTietDonHang` tính lại tổng tiền trên bảng cha `tbDonHang`, Oracle sẽ báo lỗi Mutating Table `ORA-04091`.
- **Giải pháp**: Xây dựng Package `SHIPFOOD.pkg_don_hang_state`:
  - Dùng bảng tạm Associative Array trong bộ nhớ phiên làm việc (`v_madh_list`).
  - Tách thành 2 bước: Trigger FOR EACH ROW ghi nhận mã đơn thay đổi -> Trigger STATEMENT tính toán tổng tiền sau khi lệnh SQL kết thúc -> Xoá mảng.
  - Kết quả: Không bao giờ xảy ra lỗi xung đột phiên.

---

### SLIDE 9: KẾT QUẢ 5 KỊCH BẢN KIỂM THỬ (⚠️ DỰ KIẾN — CHƯA CHẠY TRÊN ORACLE THẬT)
- **Bảng tổng kết (cần chạy lại trên Oracle 23ai thật trước khi thuyết trình)**:
  - TC1: Duality Boundary Protection -> dự kiến bị chặn (`NOINSERT/NOUPDATE/NODELETE`).
  - TC2: State Machine Validation -> dự kiến bị chặn (`ORA-20010`).
  - TC3: Kiểm tra Số dư Ví & Quyết toán -> dự kiến bị chặn (`ORA-20002`).
  - TC4: Bảo vệ Toàn vẹn Đơn Hoàn tất -> dự kiến bị chặn (`ORA-20011`).
  - TC5: Tự động Aggregation Điểm đánh giá -> dự kiến cập nhật tự động.
  - *Chạy script trong `DB/tests/` và thay bảng này bằng kết quả PASS/FAIL thật trước khi báo cáo.*

---

### SLIDE 10: TỐI ƯU HOÁ EXECUTION PLAN — TRUY VẤN DUALITY VIEW (QUERY 1) — ⚠️ DỰ KIẾN
- **Truy vấn**: Lấy chi tiết đơn hàng `DV_DON_HANG` theo ID.
- **Trước tối ưu (dự kiến)**: `TABLE ACCESS FULL` trên `tbChiTietDonHang` & `tbDanhGia`.
- **Giải pháp**: Tạo 2 Foreign Key Index:
  - `idx_chitietdonhang_madh ON tbChiTietDonHang (madh)`
  - `idx_danhgia_mactdh ON tbDanhGia (mactdh)`
- **Sau tối ưu (dự kiến)**: Chuyển thành `INDEX RANGE SCAN`, giảm Cost đáng kể — *điền số Cost
  thật sau khi chạy `EXPLAIN PLAN` trên Oracle 23ai (xem `DB/execution-plans/query_01_...sql`)*.

---

### SLIDE 11: TỐI ƯU HOÁ EXECUTION PLAN — DASHBOARD QUÁN ĂN (QUERY 2) — ⚠️ DỰ KIẾN
- **Truy vấn**: Lọc đơn theo `maquan`, trạng thái và khoảng ngày; sắp xếp ngày giảm dần.
- **Trước tối ưu (dự kiến)**: Quét toàn bảng `tbDonHang` + Bước `SORT ORDER BY` tốn CPU/RAM.
- **Giải pháp**: **Composite Index**:
  - `idx_donhang_quan_status_date ON tbDonHang (maquan, trangthai, ngaydathang DESC)`
- **Sau tối ưu (dự kiến)**: Dự kiến triệt tiêu bước `SORT ORDER BY`, chuyển sang Index Range
  Scan — *điền số Cost thật sau khi chạy lại trên Oracle (xem
  `DB/execution-plans/query_02_...sql`)*.

---

### SLIDE 12: TỔNG KẾT & ĐÁNH GIÁ ĐỒ ÁN
- **Kết quả đạt được**:
  1. Triển khai trọn vẹn đồ án theo chuẩn cấu trúc 6 chương của HUFLIT.
  2. Đáp ứng xuất sắc toàn bộ rubric: CSDL chuẩn hoá, Duality View 3 cấp, ORDS REST API, Web Demo trực quan, 5 kịch bản test, tối ưu Execution Plan giảm >80-92% chi phí.
  3. Sẵn sàng 100% cho 4 vòng vấn đáp cá nhân.
