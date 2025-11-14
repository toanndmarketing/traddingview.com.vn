# 📚 Index - Tài liệu Setup Ghost CMS

**Server:** 139.180.221.202 | **User:** root | **Path:** /home/tradingview.com.vn

---

## 🎯 Bắt đầu từ đây

| File | Mô tả | Dành cho |
|------|-------|----------|
| **[QUICK_SETUP_139.180.221.202.md](QUICK_SETUP_139.180.221.202.md)** | ⚡ Setup nhanh nhất (5-10 lệnh) | Người muốn setup nhanh |
| **[SETUP_GUIDE.md](SETUP_GUIDE.md)** | 🎯 Chọn phương án phù hợp | Người chưa biết chọn Docker hay Non-Docker |
| **[README_SETUP.md](README_SETUP.md)** | 📖 Tổng quan tất cả tài liệu | Người muốn xem toàn bộ |

---

## 🐳 Hướng dẫn Docker

| File | Mô tả | Thời gian |
|------|-------|-----------|
| **[SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md)** | Hướng dẫn chi tiết setup bằng Docker | 10 phút |
| **[Dockerfile](Dockerfile)** | Docker image cho Ghost | - |
| **[docker-compose.yml](docker-compose.yml)** | Docker Compose config | - |
| **[config.docker.json](config.docker.json)** | Config cho Docker | - |
| **[scripts/docker-setup.sh](scripts/docker-setup.sh)** | Script tự động setup Docker | 5 phút |

**Ưu điểm:**
- ✅ Đơn giản, nhanh chóng
- ✅ Không cần cài Node.js, MySQL thủ công
- ✅ Dễ quản lý, dễ backup

---

## 🔧 Hướng dẫn Non-Docker

| File | Mô tả | Thời gian |
|------|-------|-----------|
| **[SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md)** | Hướng dẫn chi tiết setup trực tiếp | 20 phút |
| **[scripts/install.sh](scripts/install.sh)** | Script cài đặt dependencies | 5 phút |
| **[scripts/ghost.sh](scripts/ghost.sh)** | Script quản lý Ghost | - |
| **[config.production.json](config.production.json)** | Config production | - |
| **[ecosystem.config.example.js](ecosystem.config.example.js)** | PM2 config template | - |

**Ưu điểm:**
- ✅ Tối ưu resources
- ✅ Kiểm soát chi tiết
- ✅ Không cần Docker

---

## 📜 Scripts hỗ trợ

| Script | Mô tả | Sử dụng |
|--------|-------|---------|
| **[scripts/docker-setup.sh](scripts/docker-setup.sh)** | Setup tự động bằng Docker | `bash scripts/docker-setup.sh` |
| **[scripts/install.sh](scripts/install.sh)** | Cài đặt dependencies | `bash scripts/install.sh` |
| **[scripts/ghost.sh](scripts/ghost.sh)** | Quản lý Ghost (start/stop/restart) | `bash scripts/ghost.sh start` |
| **[scripts/backup-db.sh](scripts/backup-db.sh)** | Backup database | `bash scripts/backup-db.sh` |
| **[scripts/update.sh](scripts/update.sh)** | Update code | `bash scripts/update.sh` |
| **[scripts/deploy.sh](scripts/deploy.sh)** | Deploy tự động | `bash scripts/deploy.sh` |

---

## 📚 Tài liệu khác

| File | Mô tả |
|------|-------|
| **[DEPLOYMENT.md](DEPLOYMENT.md)** | Hướng dẫn deployment tổng quát |
| **[QUICKSTART.md](QUICKSTART.md)** | Quick start cho CloudPanel |
| **[CLOUDPANEL.md](CLOUDPANEL.md)** | Hướng dẫn cho CloudPanel |
| **[CONFIG_SETUP.md](CONFIG_SETUP.md)** | Hướng dẫn cấu hình |
| **[README.md](README.md)** | README chính của project |

---

## 🚀 Quick Commands

### Setup

```bash
# Docker (Khuyến nghị)
ssh root@139.180.221.202
cd /home/tradingview.com.vn
bash scripts/docker-setup.sh

# Non-Docker
ssh root@139.180.221.202
cd /home/tradingview.com.vn
bash scripts/install.sh
```

### Quản lý

```bash
# Docker
docker compose up -d          # Start
docker compose down           # Stop
docker compose restart        # Restart
docker compose logs -f ghost  # Logs

# Non-Docker
bash scripts/ghost.sh start    # Start
bash scripts/ghost.sh stop     # Stop
bash scripts/ghost.sh restart  # Restart
bash scripts/ghost.sh logs     # Logs
```

### Backup

```bash
# Docker
docker compose exec mysql mysqldump -u root -prootpassword ghostproduction > backup.sql

# Non-Docker
bash scripts/backup-db.sh
```

---

## 🎯 Lộ trình Setup

### Bước 1: Chọn phương án
👉 Đọc [SETUP_GUIDE.md](SETUP_GUIDE.md) để chọn Docker hoặc Non-Docker

### Bước 2: Setup nhanh
👉 Đọc [QUICK_SETUP_139.180.221.202.md](QUICK_SETUP_139.180.221.202.md) để setup nhanh

### Bước 3: Setup chi tiết (nếu cần)
👉 Docker: [SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md)  
👉 Non-Docker: [SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md)

### Bước 4: Hoàn tất
- ✅ Truy cập website
- ✅ Tạo admin account
- ✅ Setup backup tự động

---

## 📊 So sánh phương án

| Tiêu chí | Docker | Non-Docker |
|----------|--------|------------|
| **Thời gian** | ⭐⭐⭐⭐⭐ 10 phút | ⭐⭐⭐ 20 phút |
| **Độ dễ** | ⭐⭐⭐⭐⭐ Rất dễ | ⭐⭐⭐ Trung bình |
| **Quản lý** | ⭐⭐⭐⭐⭐ Rất dễ | ⭐⭐⭐ Trung bình |
| **Resources** | ⭐⭐⭐⭐ Tốt | ⭐⭐⭐⭐⭐ Rất tốt |
| **Rollback** | ⭐⭐⭐⭐⭐ Rất dễ | ⭐⭐ Khó |

**Khuyến nghị:** Dùng Docker nếu server đã có Docker!

---

## 🆘 Troubleshooting

### Tìm hướng dẫn troubleshooting:
- Docker: Xem phần "Troubleshooting" trong [SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md)
- Non-Docker: Xem phần "Troubleshooting" trong [SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md)

### Lỗi thường gặp:
- Ghost không start → Xem logs
- MySQL connection error → Kiểm tra credentials
- Port đã được sử dụng → Kill process hoặc đổi port
- Permission denied → Fix permissions

---

## 📞 Hỗ trợ

1. Đọc tài liệu phù hợp
2. Kiểm tra logs
3. Xem phần Troubleshooting
4. Liên hệ team support

---

**Chúc bạn setup thành công! 🎉**


