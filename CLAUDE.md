# AI Agent Rules

Quy tắc cơ bản khi dùng AI agent (bất kỳ công cụ nào) để sửa code trong repo này.
Thông tin tech stack / cách chạy dự án xem ở [README.md](README.md).

- Không commit secrets, API key, connection string thật (dùng `dotnet user-secrets` hoặc biến môi trường).
- Không force-push lên `master`.
- Không tự ý xóa/ghi đè migration hoặc dữ liệu production.
- Luôn `dotnet build` thành công trước khi commit.
- Giữ `./seed.sql` (root) là file seed duy nhất — không tạo bản sao khác.
