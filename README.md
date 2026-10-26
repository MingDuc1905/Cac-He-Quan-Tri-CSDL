# Fastship (ShipFood)

Nền tảng đặt món & giao đồ ăn online — ASP.NET Core 8 MVC + PostgreSQL + SignalR + Gemini AI.

> Đồ án môn học (Thương mại điện tử — HUFLIT)

**Live demo:** https://fastship-web.onrender.com/

## Vai trò

| Vai trò | Chức năng chính |
|---|---|
| Khách hàng | Tìm quán, đặt món, thanh toán (COD/MoMo/VNPAY sandbox), theo dõi đơn, đánh giá |
| Quán ăn | Quản lý thực đơn, nhận/xử lý đơn hàng, thống kê doanh thu, khuyến mãi |
| Shipper | Nhận đơn giao, cập nhật trạng thái, theo dõi thu nhập, live location |
| Admin | Quản lý user/danh mục/đơn hàng toàn hệ thống, dashboard thống kê |

## Tech stack

- **Backend:** ASP.NET Core 8 MVC, Entity Framework Core + Npgsql
- **Database:** PostgreSQL 15+
- **Real-time:** SignalR (chat, live order tracking)
- **AI:** Google Gemini API (chatbot hỗ trợ khách hàng)
- **Frontend:** Bootstrap 5, jQuery, Chart.js, Leaflet.js
- **Auth:** Cookie/Session + Google OAuth
- **Deploy:** Docker (multi-stage) → Render

## Chạy local

```bash
git clone https://github.com/MingDuc1905/TMDT.git
cd TMDT/ShipFoodCore
dotnet restore

dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=...;Database=...;Username=...;Password=..."
dotnet user-secrets set "Gemini:ApiKey" "YOUR_GEMINI_KEY"
dotnet user-secrets set "Authentication:Google:ClientId" "YOUR_GOOGLE_CLIENT_ID"
dotnet user-secrets set "Authentication:Google:ClientSecret" "YOUR_GOOGLE_CLIENT_SECRET"

dotnet run
```

Seed dữ liệu mẫu: `seed.sql` (root repo).

Chạy bằng Docker (từ thư mục gốc):
```bash
docker build -t fastship . && docker run -p 8080:8080 fastship
```

## Cấu trúc thư mục

```
ShipFoodCore/
├── Controllers/     # Admin, Restaurant, Shipper, Customer (Home)
├── Models/          # EF Core entities + DbContext
├── Services/        # Gemini AI, MoMo, VNPay, Recommendation
├── Hubs/             # SignalR
├── Views/            # Razor views theo từng role
└── wwwroot/Source/   # Static assets theo theme

tests/ShipFoodCore.Tests/  # Unit test (.NET), chạy trong CI
scripts/                   # Backup DB, tạo index
seed.sql                   # Dữ liệu mẫu PostgreSQL
Dockerfile
```

