# ShipFood — Oracle 23ai Duality View & ORDS Demo Application

Ứng dụng web Single-Page Application (SPA) minh hoạ trực quan cho đồ án Hệ Quản Trị CSDL HUFLIT (Đề tài 15: Hệ thống quản lý đơn hàng cho ứng dụng bán hàng đa nền tảng).

## Mục tiêu đồ án
Theo yêu cầu tại **Mục 3.2–3.3 và Mục 5 của đề bài**:
- Bắt buộc có ứng dụng minh hoạ có giao diện thật, gọi qua lớp API/ORDS tới Oracle Database 23ai.
- Tuyệt đối không demo bằng SQL*Plus / SQL Developer (vi phạm = điểm liệt).
- Khai thác tính năng JSON Relational Duality Views: gọi trực tiếp qua REST API do ORDS sinh tự động mà không cần xây dựng backend CRUD thủ công.

---

## Các tính năng chính của Ứng dụng
1. **Quản lý Đơn hàng (DV_DON_HANG)**:
   - Hiển thị danh sách đơn hàng real-time kèm chỉ số KPI tổng thể (Tổng đơn, Đang xử lý, Hoàn thành, Doanh thu).
   - **Xem chi tiết JSON 3 cấp**: Giao diện phân cấp trực quan và xem raw JSON payload được sinh bởi Duality View (`donHang` -> `chiTiet` -> `bienThe`/`monAn` -> `danhGia`).
2. **Đặt Đơn hàng Mới (POST qua Duality View)**:
   - Form cho phép chọn quán, khách hàng, địa chỉ, hình thức thanh toán và thêm nhiều món với các biến thể size khác nhau.
   - Ứng dụng tự động đóng gói payload JSON lồng và gửi qua `POST /ords/shipfood/dv_don_hang/`.
   - Oracle tự động bóc tách và chèn vào bảng chính `tbDonHang` cùng bảng con `tbChiTietDonHang` nhờ thuộc tính `WITH INSERT`.
3. **Kiểm thử State Machine Trigger**:
   - Chuyển trạng thái đơn hàng theo đúng chu trình nghiệp vụ: `Chờ xác nhận` -> `Đã đặt` -> `Đang chuẩn bị` -> `Đang giao` -> `Hoàn thành`.
   - **Nút "Chuyển trái phép"**: Thử nhảy cóc trạng thái (ví dụ từ `Đang giao` nhảy ngược về `Chờ xác nhận`) để minh hoạ trực tiếp thông báo lỗi `ORA-20010` do trigger `trg_kiem_soat_trang_thai_don` chặn lại.
4. **Kiểm thử Duality View Boundary (Bảo mật tầng CSDL)**:
   - Thử cập nhật trường `quanAn.tenquanan` lồng trong đơn hàng.
   - Do Duality View cấu hình `quanAn WITH NOUPDATE`, hệ thống sẽ từ chối thao tác, chứng minh tính toàn vẹn dữ liệu.
5. **Chế độ Mock / Live ORDS**:
   - **Mock Mode**: Hoạt động hoàn hảo ngay lập tức không cần database (phục vụ duyệt giao diện, tập dượt thuyết trình).
   - **Live ORDS Mode**: Kết nối trực tiếp tới máy chủ Oracle 23ai và ORDS thật qua cổng 8080 (hoặc URL tuỳ chỉnh).

---

## Hướng dẫn chạy và Demo

### Cách 1: Mở trực tiếp trên trình duyệt
Chỉ cần mở trực tiếp file `index.html` bằng trình duyệt bất kỳ (Google Chrome, Microsoft Edge,...).

### Cách 2: Chạy qua Live Server hoặc Local HTTP Server (khuyến nghị cho Live ORDS)
Nếu gặp hạn chế về CORS khi gọi tới ORDS thật, khởi chạy qua một web server nhẹ:
```powershell
# Chạy nhanh qua PowerShell hoặc Python nếu có:
cd "C:\Users\Administrator\Desktop\work\CHQT CSDL\DB\duality-demo"
# Nếu có Python:
# python -m http.server 3000
```

### Cách kết nối tới Oracle 23ai ORDS thật:
1. Đảm bảo đã chạy script `DB/ords_enable.sql` trên Oracle 23ai.
2. Khởi động ORDS service (thường chạy ở cổng 8080).
3. Tại thanh công cụ trên cùng của ứng dụng:
   - Nhập URL ORDS: `http://localhost:8080/ords/shipfood`
   - Chuyển "Chế độ hoạt động" sang: **Live ORDS (Oracle 23ai Server)**.
   - Bấm **"Kiểm tra kết nối"**.
