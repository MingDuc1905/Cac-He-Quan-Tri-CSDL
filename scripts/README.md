# Scripts

| File | Chức năng |
|------|-----------|
| `backup-db.sh` | Backup PostgreSQL (dùng `DATABASE_URL`) — `bash scripts/backup-db.sh` |
| `db-indexes.sql` | Tạo index tối ưu truy vấn thường dùng — `psql "$DATABASE_URL" -f scripts/db-indexes.sql` |
