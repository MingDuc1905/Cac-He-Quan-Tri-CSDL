# Hướng Dẫn Chạy Bộ Test ORDS REST API (ShipFood)

Tài liệu này hướng dẫn cách chạy kiểm thử 5 kịch bản REST API phục vụ đồ án Hệ Quản Trị CSDL HUFLIT.

## Cấu trúc thư mục
- `ShipFood_ORDS.postman_collection.json`: Bộ sưu tập Postman chứa sẵn 6 request kiểm thử.
- `ords_tests.http`: File định dạng RFC 7230 tương thích với extension **REST Client** (VS Code) hoặc HTTP Client (IntelliJ/WebStorm).
- `run_tests.ps1`: Script PowerShell chạy tự động toàn bộ kịch bản và in báo cáo Pass/Fail.

## Các kịch bản kiểm thử trọng tâm
1. **TC1: GET Danh sách & Chi tiết đơn hàng**
   - Kiểm tra khả năng serialize tự động của Oracle 23ai Duality View (`DV_DON_HANG`) ra đối tượng JSON lồng 3 cấp (`chiTiet` -> `bienThe` -> `monAn`, `danhGia`).
2. **TC2: POST Tạo mới đơn hàng kèm chi tiết lồng**
   - Kiểm tra quyền `WITH INSERT` trên view và bảng con `tbChiTietDonHang`.
3. **TC3: PUT Chuyển đổi trạng thái đơn hàng (State Machine)**
   - Case 3.1: Chuyển hợp lệ `Chờ xác nhận` -> `Đã đặt` (Trigger tự sinh timestamp `ngaythanhtoan`).
   - Case 3.2: Chuyển sai quy tắc (Ví dụ từ `Đang giao` quay ngược về `Chờ xác nhận`) -> Trigger `trg_kiem_soat_trang_thai_don` trả về mã lỗi `ORA-20010`.
4. **TC4: PUT Vi phạm quyền Duality View Boundary**
   - Cố tình sửa trường `tenquanan` của `quanAn` lồng trong đơn hàng.
   - Do view được định nghĩa `quanAn ... WITH NOINSERT NOUPDATE NODELETE`, Oracle từ chối cập nhật và trả về lỗi.
5. **TC5: Kiểm thử Package `pkg_don_hang_state`**
   - Xác nhận trigger `trg_luu_madh_thay_doi` và `trg_tinh_lai_tien_sau_lenh` không bị lỗi ORA-04091 (Mutating Table) khi thêm/sửa chi tiết đơn.

## Hướng dẫn chạy nhanh bằng PowerShell
```powershell
# Chạy với Base URL mặc định (localhost:8080)
.\run_tests.ps1

# Hoặc chỉ định IP / Port của máy chủ Oracle ORDS:
.\run_tests.ps1 -BaseUrl "http://192.168.1.100:8080/ords/shipfood"
```
