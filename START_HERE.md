# 🚀 BẮT ĐẦU TỪ ĐÂY - Setup Ghost CMS

**Server:** 139.180.221.202  
**User:** root  
**Code path:** /home/tradingview.com.vn

---

## 👋 Chào mừng!

Đây là hướng dẫn setup Ghost CMS cho server **139.180.221.202**.  
Code đã được clone về `/home/tradingview.com.vn`.

---

## ⚡ Setup nhanh nhất (Khuyến nghị)

### Bước 1: SSH vào server
```bash
ssh root@139.180.221.202
cd /home/tradingview.com.vn
```

### Bước 2: Chọn 1 trong 2 phương án

#### 🐳 Phương án A: Docker (10 phút - Đơn giản nhất)
```bash
# Chỉnh sửa config
nano config.docker.json
# Sửa: url, AWS credentials, database password

# Chạy script tự động
chmod +x scripts/docker-setup.sh
bash scripts/docker-setup.sh
```

#### 🔧 Phương án B: Non-Docker (20 phút - Tối ưu hơn)
```bash
# Chạy script install
chmod +x scripts/*.sh
bash scripts/install.sh

# Chỉnh sửa config
nano config.production.json
# Sửa: url, database, AWS credentials

# Start Ghost
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Bước 3: Setup Nginx + SSL
```bash
# Xem hướng dẫn chi tiết trong:
# - QUICK_SETUP_139.180.221.202.md
```

---

## 📚 Tài liệu đầy đủ

### 🎯 Chọn tài liệu phù hợp

| Bạn muốn | Đọc file này |
|----------|--------------|
| **Setup nhanh nhất** | [QUICK_SETUP_139.180.221.202.md](QUICK_SETUP_139.180.221.202.md) |
| **Chọn phương án** | [SETUP_GUIDE.md](SETUP_GUIDE.md) |
| **Hướng dẫn Docker chi tiết** | [SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md) |
| **Hướng dẫn Non-Docker chi tiết** | [SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md) |
| **Xem tất cả tài liệu** | [INDEX_SETUP.md](INDEX_SETUP.md) |
| **Checklist theo dõi** | [CHECKLIST_SETUP.md](CHECKLIST_SETUP.md) |

---

## 🤔 Chưa biết chọn Docker hay Non-Docker?

### Dùng Docker nếu:
- ✅ Server đã có Docker
- ✅ Muốn setup nhanh (10 phút)
- ✅ Ưu tiên sự đơn giản
- ✅ Dễ quản lý và backup

### Dùng Non-Docker nếu:
- ✅ Server không có Docker
- ✅ Muốn tối ưu resources
- ✅ Đã quen với Node.js, MySQL, PM2

👉 **Khuyến nghị:** Dùng Docker nếu server đã có Docker!

---

## 📋 Checklist nhanh

### Docker
- [ ] SSH vào server
- [ ] Sửa `config.docker.json`
- [ ] Chạy `bash scripts/docker-setup.sh`
- [ ] Setup Nginx + SSL
- [ ] Truy cập website

### Non-Docker
- [ ] SSH vào server
- [ ] Chạy `bash scripts/install.sh`
- [ ] Sửa `config.production.json`
- [ ] Start Ghost với PM2
- [ ] Setup Nginx + SSL
- [ ] Truy cập website

---

## 🆘 Cần hỗ trợ?

### Lỗi thường gặp
- **Ghost không start:** Xem logs
- **MySQL connection error:** Kiểm tra credentials
- **Port đã được sử dụng:** Kill process hoặc đổi port

### Xem logs
```bash
# Docker
docker compose logs -f ghost

# Non-Docker
pm2 logs ghost-tradingview
```

### Tìm hướng dẫn troubleshooting
- Docker: Xem [SETUP_DOCKER_139.180.221.202.md](SETUP_DOCKER_139.180.221.202.md) phần Troubleshooting
- Non-Docker: Xem [SETUP_SERVER_139.180.221.202.md](SETUP_SERVER_139.180.221.202.md) phần Troubleshooting

---

## 🎯 Lộ trình khuyến nghị

```
1. Đọc file này (START_HERE.md) ✅
   ↓
2. Chọn phương án (Docker hoặc Non-Docker)
   ↓
3. Đọc QUICK_SETUP_139.180.221.202.md
   ↓
4. Thực hiện setup theo hướng dẫn
   ↓
5. Kiểm tra website hoạt động
   ↓
6. Hoàn tất! 🎉
```

---

## 📞 Liên hệ

Nếu gặp vấn đề:
1. Kiểm tra logs
2. Đọc phần Troubleshooting
3. Liên hệ team support

---

## 🎉 Sẵn sàng bắt đầu?

👉 **Bước tiếp theo:** Đọc [QUICK_SETUP_139.180.221.202.md](QUICK_SETUP_139.180.221.202.md)

**Chúc bạn setup thành công!** 🚀


