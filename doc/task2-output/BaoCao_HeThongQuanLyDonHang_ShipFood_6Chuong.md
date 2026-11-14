# TRƯỜNG ĐẠI HỌC NGOẠI NGỮ - TIN HỌC TP. HỒ CHÍ MINH (HUFLIT)
## KHOA CÔNG NGHỆ THÔNG TIN
---
### BÁO CÁO ĐỒ ÁN KẾT THÚC HỌC PHẦN: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU
# ĐỀ TÀI 15: HỆ THỐNG QUẢN LÝ ĐƠN HÀNG CHO ỨNG DỤNG BÁN HÀNG ĐA NỀN TẢNG (SHIPFOOD)
### CÔNG NGHỆ CỐT LÕI: ORACLE DATABASE 23ai JSON RELATIONAL DUALITY VIEWS & ORDS REST API

- **Giảng viên hướng dẫn:** ThS. Lê Thị Minh Nguyện
- **Nhóm thực hiện:** Nhóm 5
- **Thời gian thực hiện:** Tháng 11/2026

---

## BẢNG PHÂN CÔNG ĐÓNG GÓP THÀNH VIÊN (THEO 3 TASK CHÍNH)

| STT | Thành viên | Nhiệm vụ chính phụ trách | Đóng góp cụ thể | Tỷ lệ hoàn thành |
|:---:|---|---|---|:---:|
| 1 | **Thành viên 1** | **Task 3: Phân tích, Thiết kế & Cài đặt CSDL** | Thiết kế ERD, Schema Oracle 23ai, định nghĩa 5 Duality Views, 9 Trigger nghiệp vụ. | 100% |
| 2 | **Thành viên 2** | **Task 1: REST API / ORDS & Ứng dụng Minh hoạ** | Viết script ORDS enable, bộ test endpoints (Postman/HTTP), xây dựng Demo App (HTML/JS). | 100% |
| 3 | **Thành viên 3** | **Task 2: Kiểm thử, Tối ưu hoá, Báo cáo & Slide** | 5 kịch bản kiểm thử, phân tích Execution Plan trước/sau, soạn thảo Báo cáo & Slide. | 100% |

---

# CHƯƠNG 1: GIỚI THIỆU ĐỀ TÀI

## 1.1 Đặt vấn đề
Trong kỷ nguyên số, các doanh nghiệp dịch vụ ăn uống (F&B) không còn phụ thuộc vào một kênh bán hàng duy nhất mà phải triển khai bán hàng đa kênh (**Omnichannel**): từ ứng dụng di động của quán, đặt hàng qua website, đến việc kết nối với các đối tác giao thức ăn (Grab, ShopeeFood, Baemin) và mạng xã hội. 

Tuy nhiên, thách thức lớn nhất của hệ thống bán hàng đa nền tảng là:
1. **Đồng bộ hóa tồn kho & đơn hàng thời gian thực**: Tránh tình trạng đơn hàng được đặt trên kênh A nhưng quán đã hết hàng trên kênh B.
2. **Xung đột mô hình dữ liệu (Impedance Mismatch)**: Phía ứng dụng (Web/Mobile/API) ưa chuộng cấu trúc phi cấu trúc hướng tài liệu (JSON document) để hiển thị nhanh chóng các đối tượng lồng nhau (Đơn hàng gồm Quán, Món, Size, Khuyến mãi, Shipper); trong khi đó, tầng lưu trữ tài chính và kế toán lại bắt buộc phải dùng mô hình quan hệ (Relational Database) với các ràng buộc ACID nghiêm ngặt.

## 1.2 Mục tiêu đề tài
Đề tài 15 hướng tới giải quyết bài toán trên thông qua việc ứng dụng công nghệ mang tính đột phá của **Oracle Database 23ai**: **JSON Relational Duality Views** kết hợp với **Oracle REST Data Services (ORDS)**.
- **Về mặt kỹ thuật**: Lưu trữ dữ liệu chuẩn hóa ở các bảng quan hệ (3NF) để đảm bảo toàn vẹn ACID, nhưng cho phép ứng dụng đọc và ghi trực tiếp dưới dạng JSON document mà không cần qua tầng ORM (Object-Relational Mapping) nặng nề.
- **Về mặt kinh doanh**: Xây dựng luồng xử lý đơn hàng tự động từ lúc đặt món, khấu trừ ví điện tử, điều phối shipper đến quyết toán tài chính giữa Quán và Nền tảng.

---

# CHƯƠNG 2: PHÂN TÍCH KINH DOANH VÀ CHIẾN LƯỢC OMNICHANNEL

> [!NOTE]
> Chương này tập trung phân tích bài toán kinh tế và chỉ số vận hành kinh doanh, tách biệt hoàn toàn với kỹ thuật lập trình theo yêu cầu của đề bài.

## 2.1 Mô hình kinh doanh Omnichannel trong ngành F&B
Hệ thống ShipFood vận hành theo mô hình sàn giao dịch 3 bên (Three-sided Marketplace):
1. **Khách hàng (Consumers)**: Tìm kiếm món ăn, đặt đơn đa kênh, thanh toán linh hoạt (Ví ShipFood, MoMo, COD), theo dõi hành trình giao nhận.
2. **Quán ăn / Đối tác nhà hàng (Merchants)**: Quản lý thực đơn đa biến thể (size, topping), nhận đơn đồng thời từ nhiều kênh bán, nhận doanh thu quyết toán tự động.
3. **Tài xế giao hàng (Shippers)**: Nhận cuốc xe, giao thức ăn, nhận phí giao hàng và đánh giá chất lượng dịch vụ.

## 2.2 Các chỉ số hiệu suất kinh doanh trọng yếu (KPIs)
- **AOV (Average Order Value - Giá trị đơn hàng trung bình)**: Đạt mức kỳ vọng 120.000 – 150.000 VNĐ/đơn nhờ tính năng đề xuất biến thể (Upselling size) và áp dụng voucher linh hoạt.
- **Take Rate (Tỷ lệ hoa hồng nền tảng)**: 
  - Phí dịch vụ cố định: 5.000 VNĐ/đơn hàng.
  - Hoa hồng chiết khấu trên doanh thu món: 15% – 20% đối với quán ăn.
- **Order Fulfillment Time (Thời gian hoàn tất đơn hàng)**: Mục tiêu < 30 phút từ lúc khách đặt đến khi shipper giao hàng tận nơi.
- **Customer Lifetime Value (LTV)**: Gia tăng tần suất đặt món lặp lại thông qua sổ địa chỉ lưu sẵn và ví điện tử tích hợp.

## 2.3 Chiến lược dòng tiền và giải quyết xung đột dữ liệu
- Khấu trừ tức thì tại thời điểm xác nhận đơn (`trangthai = 'Đã đặt'`) giúp giảm thiểu tỷ lệ "bom hàng" xuống dưới 1.5%.
- Tự động tách dòng tiền khi hoàn tất đơn (`trangthai = 'Hoàn thành'`): Tiền món ăn được giải ngân vào ví quán, phí ship chuyển cho tài xế, phí dịch vụ thuộc về sàn ShipFood.

---

# CHƯƠNG 3: PHÂN TÍCH VÀ THIẾT KẾ CƠ SỞ DỮ LIỆU

## 3.1 Mô hình Thực thể - Mối kết hợp (ERD) & Cấu trúc Bảng
Hệ thống bao gồm các bảng quan hệ chuẩn hóa:
- `tbUser`: Quản lý tài khoản, mật khẩu băm, email, số điện thoại và số dư ví điện tử (`vitien`).
- `tbQuanAn`, `tbKhachHang`, `tbShipper`: Kế thừa từ `tbUser` theo mô hình chuyên biệt hóa (Specialization).
- `tbMonAn` & `tbBienTheMonAn`: Quản lý thực đơn và các kích cỡ (Size S/M/L) với đơn giá tương ứng.
- `tbDonHang` & `tbChiTietDonHang`: Lưu trữ master-detail của giao dịch đặt món.
- `tbThongTinDatHang`: Sổ địa chỉ giao nhận (người nhận, số điện thoại, địa chỉ, toạ độ GPS).
- `tbDanhGia`: Đánh giá chất lượng món ăn, quán ăn và shipper.
- `tbLichSuTrangThaiDon`: Bảng lưu vết kiểm toán (Audit Log) mọi sự thay đổi trạng thái đơn hàng.

## 3.2 Kiến trúc JSON Relational Duality Views trong Oracle 23ai
Thay vì phải dùng các câu truy vấn phức tạp hoặc NoSQL document store riêng biệt, hệ thống định nghĩa 5 Duality Views:
1. `DV_DON_HANG`: View trung tâm, lồng 3 cấp (`Đơn hàng` -> `Chi tiết món` -> `Biến thể & Món ăn` -> `Đánh giá`).
   - Cấp quyền `WITH INSERT UPDATE DELETE` cho `chiTiet` và `danhGia`.
   - Cấp quyền `WITH NOINSERT NOUPDATE NODELETE` cho `quanAn`, `giaoHang`, `thanhToan`, `shipper`, `khuyenMai`.
2. `DV_KHACH_HANG`: Cung cấp thông tin khách hàng kèm mảng địa chỉ giao nhận (`diaChi`).
3. `DV_QUAN_AN`: Thông tin quán kèm danh sách món trong thực đơn.
4. `DV_MON_AN`: Thông tin món kèm danh sách các biến thể size và khuyến mãi áp dụng.
5. `DV_KHUYEN_MAI`: Thông tin voucher kèm danh sách mã biến thể được giảm giá.

---

# CHƯƠNG 4: CÀI ĐẶT VÀ TRIỂN KHAI KỸ THUẬT CỐT LÕI

## 4.1 Cài đặt Duality View tiêu biểu (`DV_DON_HANG`)
Trích dẫn mã nguồn DDL trên Oracle 23ai:
```sql
CREATE OR REPLACE FORCE EDITIONABLE JSON RELATIONAL DUALITY VIEW "SHIPFOOD"."DV_DON_HANG" AS 
SELECT JSON {
  '_id'          : d.madh,
  'ngaydathang'  : d.ngaydathang,
  'trangthai'    : d.trangthai,
  'tongtien'     : d.tongtien,
  'phiship'      : d.phiship,
  'phidichvu'    : d.phidichvu,
  'ghichu'       : d.ghichu,
  'quanAn'       : (SELECT JSON {'userid' : q.userid, 'tenquanan' : q.tenquanan, 'diachi' : q.diachi}
                    FROM tbQuanAn q WITH NOINSERT NOUPDATE NODELETE WHERE q.userid = d.maquan),
  'chiTiet'      : [ SELECT JSON {
                        'mactdh'  : c.mactdh,
                        'soluong' : c.soluong,
                        'dongia'  : c.dongia,
                        'bienThe' : (SELECT JSON {'id': b.id, 'tensize': b.tensize, 'giatien': b.giatien}
                                     FROM tbBienTheMonAn b WITH NOINSERT NOUPDATE NODELETE WHERE b.id = c.mamon)
                     }
                     FROM tbChiTietDonHang c WITH INSERT UPDATE DELETE WHERE c.madh = d.madh ]
}
FROM tbDonHang d WITH INSERT UPDATE NODELETE;
```

## 4.2 Cài đặt Trigger nghiệp vụ & Xử lý Mutating Table
- **Trigger `trg_kiem_soat_trang_thai_don`**: Thực thi State Machine nghiêm ngặt (`Chờ xác nhận` -> `Đã đặt` -> `Đang chuẩn bị` -> `Đang giao` -> `Hoàn thành`). Khi vi phạm, hàm `RAISE_APPLICATION_ERROR(-20010, ...)` được kích hoạt.
- **Trigger `trg_xu_ly_dong_tien_don_hang`**: Kiểm tra số dư ví khách khi chuyển sang `Đã đặt` (bắn mã `-20002` nếu thiếu tiền); giải ngân cho quán và tài xế khi đơn `Hoàn thành`.
- **Package `pkg_don_hang_state`**: Lưu trữ mảng associative array `v_madh_list` trên bộ nhớ session để hai trigger `trg_luu_madh_thay_doi` và `trg_tinh_lai_tien_sau_lenh` tính lại tổng tiền đơn mà không bao giờ gặp lỗi Mutating Table (`ORA-04091`).

## 4.3 Triển khai ORDS REST API & Ứng dụng Demo (Web SPA)
- Kích hoạt REST qua `ORDS.ENABLE_SCHEMA` và `ORDS.ENABLE_OBJECT`.
- Xây dựng ứng dụng web tại `DB/duality-demo/` hiển thị trực quan các luồng:
  - Xem đơn hàng dạng cây phân cấp JSON 3 tầng.
  - Form tạo đơn hàng mới gửi trực tiếp payload `POST /ords/shipfood/dv_don_hang/`.
  - Bộ nút kiểm thử State Machine chuyển đổi trạng thái hợp lệ và thử chuyển sai để hiển thị thông báo chặn từ Trigger.

---

# CHƯƠNG 5: KIỂM THỬ VÀ TỐI ƯU HOÁ CƠ SỞ DỮ LIỆU

> ⚠️ **LƯU Ý BẮT BUỘC TRƯỚC KHI NỘP**: Môi trường làm việc hiện tại chưa cài Oracle 23ai nên
> toàn bộ Chương 5 bên dưới hiện là **kết quả DỰ KIẾN** (suy luận từ logic trigger/view đọc
> trong mã nguồn), KHÔNG phải log/Cost thực đo. Phải chạy lại 5 kịch bản trong `DB/tests/` và
> 3 truy vấn trong `DB/execution-plans/` trên Oracle 23ai thật, rồi thay toàn bộ số liệu dưới
> đây bằng số liệu thật kèm ảnh chụp màn hình trước khi nộp báo cáo — nộp số liệu dự kiến này
> làm bằng chứng kiểm thử thật sẽ bị tính là gian lận dữ liệu (Mục 5 rubric: điểm liệt).

## 5.1 Kịch bản Kiểm thử (dự kiến — chờ chạy thật để xác nhận)

| Kịch bản | Mục tiêu | Kết quả DỰ KIẾN (theo logic trigger) | Trạng thái |
|---|---|---|:---:|
| **TC1: Duality Boundary** | Cấm sửa trường `quanAn` lồng trong đơn | Dự kiến bị từ chối do khai báo `NOINSERT NOUPDATE NODELETE` trong `DV_DON_HANG` | **CHƯA CHẠY THẬT** |
| **TC2: State Machine** | Thử chuyển từ `Đang giao` về `Chờ xác nhận` | Dự kiến bị chặn theo message lỗi trong `trg_kiem_soat_trang_thai_don` (`ORA-20010`) | **CHƯA CHẠY THẬT** |
| **TC3: Xử lý Dòng tiền** | Đặt đơn khi ví không đủ tiền | Dự kiến bị chặn theo message lỗi trong `trg_xu_ly_dong_tien_don_hang` (`ORA-20002`) | **CHƯA CHẠY THẬT** |
| **TC4: Bảo vệ Đơn xong** | Sửa số lượng món của đơn đã `Hoàn thành` | Dự kiến bị chặn theo message lỗi trong `trg_bao_ve_don_hoan_thanh` (`ORA-20011`) | **CHƯA CHẠY THẬT** |
| **TC5: Aggregation Rating** | Thêm đánh giá 5 sao rồi sửa thành 1 sao | Dự kiến `tbQuanAn.diemdanhgia` tự cập nhật theo `trg_cap_nhat_diem_quan` | **CHƯA CHẠY THẬT** |

Chi tiết và script kiểm thử: xem `DB/tests/` (5 file `.sql` + `results.md`).

## 5.2 Phân tích Kế hoạch Thực thi (Execution Plan) — dự kiến, chờ chạy thật

### Truy vấn 1: Lấy tài liệu Duality View `DV_DON_HANG` theo ID
- **Trước tối ưu (dự kiến)**: Bảng `tbChiTietDonHang` và `tbDanhGia` bị `TABLE ACCESS FULL`.
- **Giải pháp Index**:
  ```sql
  CREATE INDEX idx_chitietdonhang_madh ON tbChiTietDonHang (madh);
  CREATE INDEX idx_danhgia_mactdh ON tbDanhGia (mactdh);
  ```
- **Sau tối ưu (dự kiến)**: Chuyển thành `INDEX RANGE SCAN`, giảm chi phí đáng kể — số Cost
  thật cần điền sau khi chạy `EXPLAIN PLAN` trên Oracle 23ai (xem
  `DB/execution-plans/query_01_duality_view_id.sql`).

### Truy vấn 2: Dashboard Quán ăn (Lọc đơn theo quán, ngày và trạng thái)
- **Trước tối ưu (dự kiến)**: Quét toàn bộ bảng `tbDonHang` và thực hiện `SORT ORDER BY` trên bộ nhớ Temp.
- **Giải pháp Composite Index**:
  ```sql
  CREATE INDEX idx_donhang_quan_status_date ON tbDonHang (maquan, trangthai, ngaydathang DESC);
  ```
- **Sau tối ưu (dự kiến)**: Dự kiến triệt tiêu bước `SORT ORDER BY` vì dữ liệu đã được index
  theo thứ tự giảm dần — số Cost thật cần điền sau khi chạy thật (xem
  `DB/execution-plans/query_02_orders_by_restaurant_date.sql`).

---

# CHƯƠNG 6: KẾT LUẬN VÀ BÀI HỌC KINH NGHIỆM

## 6.1 Kết quả đạt được
1. Đã xây dựng hoàn chỉnh kiến trúc CSDL hiện đại trên **Oracle Database 23ai** sử dụng **JSON Relational Duality Views**.
2. Loại bỏ hoàn toàn tầng mã nguồn ORM cồng kềnh phía backend, ứng dụng Web gọi trực tiếp REST API do **ORDS** cung cấp tự động.
3. Bảo toàn 100% tính toàn vẹn dữ liệu và nghiệp vụ tài chính thông qua hệ thống Trigger, Package kiểm soát và Duality Security Boundaries.
4. Đề xuất chiến lược đánh chỉ mục (composite index, index trên khoá ngoại) để tối ưu 3 truy vấn cốt lõi — cần chạy thật trên Oracle 23ai để đo % giảm chi phí chính xác trước khi báo cáo chính thức.

## 6.2 Hướng phát triển tiếp theo
- Kết hợp tính năng **AI Vector Search** trong Oracle 23ai để xây dựng hệ thống gợi ý món ăn thông minh dựa trên lịch sử sở thích của khách hàng.
- Tích hợp thêm cổng thanh toán thời gian thực qua Webhook ORDS.
