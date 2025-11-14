# 🚀 BẮT ĐẦU TỪ ĐÂY - Setup Ghost CMS

**Server:** 139.180.221.202
**User:** root
**Code path:** /home/tradingview.com.vn
**Domain:** tradingview.com.vn (Cloudflare SSL đã bật)
**OS:** Ubuntu (Server trắng)

---

## 👋 Chào mừng!

Đây là hướng dẫn setup Ghost CMS cho server **139.180.221.202**.
Code đã được clone về `/home/tradingview.com.vn`.

**Lưu ý:** Domain đã dùng Cloudflare SSL nên **KHÔNG CẦN cài SSL trên server**!

---

## ⚡ Setup nhanh nhất (Khuyến nghị)

### 👉 Đọc ngay: [SETUP_NHANH.md](SETUP_NHANH.md) - 10 lệnh, 10 phút!

### Hoặc làm theo đây:

```bash
# 1. SSH vào server
ssh root@139.180.221.202

# 2. Update & cài Docker
apt-get update && apt-get upgrade -y
curl -fsSL https://get.docker.com | sh

# 3. Vào thư mục code
cd /home/tradingview.com.vn

# 4. Sửa config
nano config.docker.json
# Sửa: url, database password, AWS credentials

# 5. Chạy script tự động
chmod +x scripts/docker-setup.sh
bash scripts/docker-setup.sh

# 6. Cài Nginx (KHÔNG CẦN SSL vì đã có Cloudflare)
apt-get install -y nginx
# Copy Nginx config từ SETUP_NHANH.md

# 7. Cấu hình Cloudflare
# DNS: A record -> 139.180.221.202 (Proxied ON)
# SSL/TLS: Full mode
```

---

## 📚 Tài liệu đầy đủ

### 🎯 Chọn tài liệu phù hợp

| Bạn muốn | Đọc file này |
|----------|--------------|
| **⚡ Setup nhanh nhất (10 phút)** | [SETUP_NHANH.md](SETUP_NHANH.md) ⭐ |
| **☁️ Setup với Cloudflare SSL** | [SETUP_CLOUDFLARE_139.180.221.202.md](SETUP_CLOUDFLARE_139.180.221.202.md) ⭐ |
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

👉 **Bước tiếp theo:** Đọc [SETUP_NHANH.md](SETUP_NHANH.md) - 10 lệnh, 10 phút!

**Chúc bạn setup thành công!** 🚀

---

## 📌 Lưu ý quan trọng

- ✅ Domain đã dùng **Cloudflare SSL** → KHÔNG cần cài SSL trên server
- ✅ Server Ubuntu trắng → Chỉ cài: Docker, Nginx, UFW
- ✅ Nginx chỉ làm **reverse proxy** (port 80)
- ✅ Cloudflare sẽ lo phần SSL/HTTPS


