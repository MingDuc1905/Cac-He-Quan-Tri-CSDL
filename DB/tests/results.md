# Báo Cáo Kết Quả Kiểm Thử Nghiệp Vụ & Duality Boundary (ShipFood)

> ⚠️ **CHƯA CHẠY TRÊN INSTANCE ORACLE THẬT.** Máy hiện tại chưa cài Oracle 23ai. Toàn bộ "kết
> quả" bên dưới là **kết quả DỰ KIẾN** suy ra từ việc đọc logic trigger/Duality View trong mã
> nguồn, dùng để chuẩn bị test case trước — KHÔNG phải log thực thi thật. Phải chạy lại 5 script
> trong thư mục này trên Oracle 23ai thật và thay số liệu ở đây bằng kết quả thực tế trước khi
> đưa vào báo cáo/slide hoặc trả lời vấn đáp. Không dùng các con số dưới đây làm bằng chứng đã
> kiểm thử.

Tài liệu này tổng hợp 5 kịch bản kiểm thử dự kiến cho cơ sở dữ liệu Oracle Database 23ai của đề
tài 15 (ShipFood), dựa trên phân tích logic trigger/view trong mã nguồn.

## Bảng tổng hợp kịch bản kiểm thử

| Mã TC | Tên kịch bản | Đối tượng kiểm tra | Kết quả kỳ vọng | Trạng thái |
|:---:|---|---|---|:---:|
| **TC1** | Duality View Boundary & Permission | `DV_DON_HANG`, `tbChiTietDonHang`, `tbQuanAn` | Cho phép thêm/sửa món; Chặn sửa trực tiếp bảng lồng `NOUPDATE` (`ORA-42399`). | **CHƯA CHẠY THẬT** |
| **TC2** | State Machine & Audit Tracking | `trg_kiem_soat_trang_thai_don`, `tbLichSuTrangThaiDon` | Chuyển trạng thái tuần tự thành công; Chuyển nhảy cóc/ngược bị chặn (`ORA-20010`). | **CHƯA CHẠY THẬT** |
| **TC3** | Xử lý Dòng tiền ví & Quyết toán | `trg_xu_ly_dong_tien_don_hang`, `tbUser.vitien` | Chặn `ORA-20002` nếu ví khách không đủ tiền; Trừ tiền khách và cộng tiền quán/shipper khi xong đơn. | **CHƯA CHẠY THẬT** |
| **TC4** | Bảo vệ Toàn vẹn Đơn hoàn tất | `trg_bao_ve_don_hoan_thanh`, `tbChiTietDonHang` | Chặn tuyệt đối hành vi sửa/xoá chi tiết món của đơn đã `Hoàn thành` hoặc `Hủy đơn` (`ORA-20011`). | **CHƯA CHẠY THẬT** |
| **TC5** | Tự động tính Điểm đánh giá | `trg_cap_nhat_diem_quan`, `trg_cap_nhat_diem_shipper` | Tự động tính toán lại `diemdanhgia` và `soluotdanhgia` khi có đánh giá mới hoặc cập nhật. | **CHƯA CHẠY THẬT** |

---

## Chi tiết từng kịch bản (kết quả DỰ KIẾN, suy luận từ mã nguồn — chưa thực thi)

### 1. TC1 — Duality View Boundary
- **Input dự kiến**:
  - Ghi bổ sung 1 dòng `tbChiTietDonHang` vào đơn #1.
  - Cập nhật số lượng qua Duality View.
  - Cố tình gửi lệnh cập nhật thuộc tính `quanAn.tenquanan` trong tài liệu JSON của đơn hàng #1.
- **Kết quả DỰ KIẾN (dựa trên khai báo `WITH NOINSERT NOUPDATE NODELETE` trong
  `DV_DON_HANG`)**:
  - INSERT và UPDATE chi tiết món nên thành công (khai báo `WITH INSERT UPDATE DELETE`).
  - Cập nhật `quanAn` lồng bên trong nên bị Oracle từ chối — cần chạy thật để lấy đúng mã lỗi
    (dự đoán dạng `ORA-42399` theo tài liệu Oracle, nhưng **phải xác nhận lại bằng log thật**).
- **Cần làm**: chạy `DB/tests/test_01_duality_boundary.sql` trên Oracle 23ai thật, dán nguyên
  văn lỗi/kết quả vào đây.

### 2. TC2 — State Machine
- **Input dự kiến**: Đơn hàng test ở trạng thái `Chờ xác nhận`.
  - Bước 1: `Chờ xác nhận` → `Đã đặt` (hợp lệ theo `trg_kiem_soat_trang_thai_don`).
  - Bước 2: `Đã đặt` → `Đang giao` (hợp lệ).
  - Bước 3: `Đang giao` → `Chờ xác nhận` (không nằm trong danh sách chuyển hợp lệ trong code).
- **Kết quả DỰ KIẾN**: Bước 1–2 thành công, ghi audit vào `tbLichSuTrangThaiDon`; Bước 3 bị
  chặn với `ORA-20010` theo đúng message trong trigger.
- **Cần làm**: chạy `test_02_state_machine.sql` thật, dán log lỗi/kết quả thật vào đây.

### 3. TC3 — Dòng tiền ví & Quyết toán
- **Input dự kiến**: Khách hàng có số dư ví thấp hơn tổng tiền đơn.
- **Kết quả DỰ KIẾN (theo logic `trg_xu_ly_dong_tien_don_hang`)**: chuyển đơn sang `Đã đặt` khi
  số dư không đủ → `ORA-20002`; khi đủ tiền → trừ đúng số tiền; khi đơn `Hoàn thành` → tiền
  chia cho quán (trừ phí ship/dịch vụ) và shipper (phần phí ship).
- **Cần làm**: chạy `test_03_money_flow.sql` thật với số liệu cụ thể, ghi số dư trước/sau thật.

### 4. TC4 — Bảo vệ Đơn hàng Hoàn tất
- **Input dự kiến**: Đơn đã `Hoàn thành`, thử `UPDATE`/`DELETE` trên `tbChiTietDonHang`.
- **Kết quả DỰ KIẾN**: bị chặn bởi `trg_bao_ve_don_hoan_thanh` với `ORA-20011` (đúng message
  trong trigger).
- **Cần làm**: chạy `test_04_protect_completed_order.sql` thật, dán log lỗi thật.

### 5. TC5 — Aggregation Đánh giá
- **Input dự kiến**: Thêm rồi sửa một đánh giá.
- **Kết quả DỰ KIẾN**: điểm trung bình/số lượt của quán và shipper tự cập nhật theo
  `trg_cap_nhat_diem_quan`/`trg_cap_nhat_diem_shipper`.
- **Cần làm**: chạy `test_05_rating_aggregation.sql` thật, dán số liệu trước/sau thật.
