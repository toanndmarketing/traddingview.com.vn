# TradingView.com.vn - Ghost CMS (Docker)

Website TradingView Vietnam chạy trên Ghost CMS v5.x (Docker).

## 📋 Server Information

- **IP:** `57.129.45.30`
- **User:** `root`
- **Path:** `/home/tradingview.com.vn`
- **Domain:** `tradingview.com.vn` (SSL by Let's Encrypt)

## 🐳 Deployment (Docker Compose)

Hệ thống hoạt động hoàn toàn trên Docker.

### 1. Kết nối Server

```bash
ssh root@57.129.45.30
cd /home/tradingview.com.vn
```

### 2. Các lệnh thường dùng

```bash
# Khởi động lại toàn bộ services
docker compose restart

# Xem logs (Realtime)
docker compose logs -f

# Xem trạng thái containers
docker compose ps

# Stop toàn bộ
docker compose down

# Rebuild và khởi động lại
docker compose up -d --build
```

### 3. Cấu trúc Services

| Service | Container Name | Port | Chức năng |
|---------|----------------|------|-----------|
| **Ghost** | `ghost-tradingview` | 3000 | CMS Core |
| **MySQL** | `ghost-mysql` | 3306 | Database |
| **Redis** | `ghost-redis` | 6379 | Caching |
| **Nginx** | `ghost-nginx` | 3005 | Reverse Proxy & Static Cache |
| **Cache Purge** | `ghost-cache-purge` | 9000 | API xóa cache tự động |

## 📁 Cấu trúc thư mục

```
tradingview.com.vn/
├── content/              # Dữ liệu Ghost (Images, Themes)
├── config.docker.json    # Config Production
├── docker-compose.yml    # Định nghĩa Services
├── nginx.conf            # Cấu hình Nginx (Docker)
├── scripts/              # Các script tiện ích
└── .env                  # Biến môi trường
```

## 🔧 Maintenance

### Backup Database

Tự động chạy script backup (hoặc chạy tay):

```bash
docker exec ghost-mysql mysqldump -u root -prootpassword ghostproduction > backup.sql
```

### Update Theme

Upload file theme mới vào `content/themes/` và restart Ghost:

```bash
docker compose restart ghost
```

## 🔐 Security

- **Fail2Ban:** Đã kích hoạt (bảo vệ SSH & Nginx)
- **UFW Firewall:** Chỉ mở port 80, 443, 22.
- **SSL:** Let's Encrypt (Auto Renew).

---
**Last Updated:** 2025-12-29
