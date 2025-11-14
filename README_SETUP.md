# 📖 Hướng dẫn Setup Ghost CMS - Server 139.180.221.202

Tài liệu hướng dẫn setup Ghost CMS trên server **139.180.221.202** với user **root**.

---

## 🎯 Bắt đầu từ đây

👉 **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Chọn phương án setup phù hợp

---

## 📚 Tài liệu chi tiết

### 🐳 Setup bằng Docker (Khuyến nghị)

- **[SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md)** - Hướng dẫn chi tiết setup bằng Docker
- **[Dockerfile](Dockerfile)** - Docker image cho Ghost
- **[docker-compose.yml](docker-compose.yml)** - Docker Compose config
- **[scripts/docker-setup.sh](scripts/docker-setup.sh)** - Script tự động setup Docker

**Quick Start:**
```bash
ssh root@139.180.221.202
cd /home/tradingview.com.vn
chmod +x scripts/docker-setup.sh
bash scripts/docker-setup.sh
```

---

### 🔧 Setup trực tiếp (Traditional)

- **[SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md)** - Hướng dẫn chi tiết setup trực tiếp
- **[scripts/install.sh](scripts/install.sh)** - Script cài đặt dependencies
- **[scripts/ghost.sh](scripts/ghost.sh)** - Script quản lý Ghost

**Quick Start:**
```bash
ssh root@139.180.221.202
cd /home/tradingview.com.vn
chmod +x scripts/*.sh
bash scripts/install.sh
```

---

## 🗂️ Cấu trúc tài liệu

```
📁 tradingview.com.vn/
│
├── 📄 SETUP_GUIDE.md                      # Chọn phương án setup
├── 📄 SETUP_DOCKER_139.180.221.202.md    # Hướng dẫn Docker
├── 📄 SETUP_SERVER_139.180.221.202.md    # Hướng dẫn Non-Docker
├── 📄 README_SETUP.md                     # File này
│
├── 🐳 Docker files
│   ├── Dockerfile                         # Docker image
│   ├── docker-compose.yml                 # Docker Compose
│   └── config.docker.json                 # Config cho Docker
│
├── 📜 Scripts
│   ├── scripts/docker-setup.sh            # Auto setup Docker
│   ├── scripts/install.sh                 # Install dependencies
│   ├── scripts/ghost.sh                   # Quản lý Ghost
│   ├── scripts/backup-db.sh               # Backup database
│   └── scripts/update.sh                  # Update code
│
├── ⚙️ Config files
│   ├── config.example.json                # Config template
│   ├── config.production.json             # Config production
│   └── ecosystem.config.example.js        # PM2 config
│
└── 📚 Tài liệu khác
    ├── DEPLOYMENT.md                      # Deployment guide
    ├── QUICKSTART.md                      # Quick start
    └── README.md                          # README chính
```

---

## ⚡ Quick Commands

### Docker

```bash
# Setup tự động
bash scripts/docker-setup.sh

# Quản lý containers
docker compose up -d          # Start
docker compose down           # Stop
docker compose restart        # Restart
docker compose logs -f ghost  # Logs
docker compose ps             # Status

# Backup database
docker compose exec mysql mysqldump -u root -prootpassword ghostproduction > backup.sql

# Import database
docker compose exec -T mysql mysql -u root -prootpassword ghostproduction < backup.sql
```

### Non-Docker

```bash
# Setup tự động
bash scripts/install.sh

# Quản lý Ghost
bash scripts/ghost.sh start    # Start
bash scripts/ghost.sh stop     # Stop
bash scripts/ghost.sh restart  # Restart
bash scripts/ghost.sh logs     # Logs
bash scripts/ghost.sh status   # Status

# Backup database
bash scripts/backup-db.sh

# Update code
bash scripts/update.sh
```

---

## 🔍 So sánh 2 phương án

| Tiêu chí | Docker | Non-Docker |
|----------|--------|------------|
| Thời gian setup | 10 phút | 20 phút |
| Độ phức tạp | Đơn giản | Trung bình |
| Quản lý | Rất dễ | Trung bình |
| Resources | Tốt | Rất tốt |
| Isolation | Hoàn toàn | Không có |
| Rollback | Rất dễ | Khó |

**Khuyến nghị:** Dùng Docker nếu server đã có Docker.

---

## 📋 Checklist Setup

### Docker
- [ ] SSH vào server
- [ ] Kiểm tra Docker đã cài
- [ ] Chạy `bash scripts/docker-setup.sh`
- [ ] Cấu hình Nginx reverse proxy
- [ ] Cài đặt SSL
- [ ] Test website

### Non-Docker
- [ ] SSH vào server
- [ ] Cài Node.js 18
- [ ] Cài MySQL
- [ ] Tạo database
- [ ] Chạy `bash scripts/install.sh`
- [ ] Cấu hình config.production.json
- [ ] Start Ghost với PM2
- [ ] Cấu hình Nginx
- [ ] Cài đặt SSL
- [ ] Test website

---

## 🆘 Troubleshooting

### Docker
```bash
# Xem logs
docker compose logs -f ghost

# Restart containers
docker compose restart

# Rebuild images
docker compose up -d --build

# Xóa và tạo lại
docker compose down
docker compose up -d
```

### Non-Docker
```bash
# Xem logs
pm2 logs ghost-tradingview

# Restart Ghost
pm2 restart ghost-tradingview

# Kiểm tra MySQL
systemctl status mysql

# Kiểm tra port
netstat -tulpn | grep 2368
```

---

## 📞 Hỗ trợ

Nếu gặp vấn đề:

1. Đọc phần Troubleshooting trong hướng dẫn chi tiết
2. Kiểm tra logs
3. Kiểm tra config files
4. Liên hệ team support

---

## 🎯 Bước tiếp theo sau khi setup

1. ✅ Truy cập `https://tradingview.com.vn/ghost`
2. ✅ Tạo admin account
3. ✅ Import content (nếu có)
4. ✅ Cấu hình theme
5. ✅ Setup backup tự động
6. ✅ Setup monitoring

---

**Chúc bạn setup thành công! 🎉**


