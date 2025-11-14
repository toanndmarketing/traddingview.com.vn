# 📝 Hướng dẫn Config Files

## 🔐 Bảo mật Config

### ❌ KHÔNG commit vào Git:
- `config.docker.json` - Config thật cho Docker (có password, AWS keys)
- `config.production.json` - Config thật cho production
- Bất kỳ file `config.*.json` nào (trừ example)

### ✅ Commit vào Git:
- `config.example.json` - Template cho non-Docker
- `config.docker.example.json` - Template cho Docker

---

## 🐳 Setup với Docker

### Lần đầu setup trên server:

```bash
# 1. Tạo config từ template
cp config.docker.example.json config.docker.json

# 2. Sửa config
nano config.docker.json

# Sửa các giá trị:
# - url: "https://tradingview.com.vn"
# - database.connection.password: "password_mạnh"
# - mail.options.auth.user: "AWS_SES_USER"
# - mail.options.auth.pass: "AWS_SES_PASSWORD"
# - storage.s3.accessKeyId: "AWS_ACCESS_KEY"
# - storage.s3.secretAccessKey: "AWS_SECRET_KEY"
# - storage.s3.bucket: "tên-bucket"
# - storage.s3.assetHost: "https://cdn.tradingview.com.vn"

# 3. Bảo mật file
chmod 600 config.docker.json
```

### Khi pull code mới:

```bash
# Pull code
git pull origin main

# Config KHÔNG bị ghi đè vì đã ignore trong .gitignore
# Chỉ cần restart Ghost
docker compose restart ghost
```

---

## 🔧 Setup Non-Docker

### Lần đầu setup:

```bash
# 1. Tạo config từ template
cp config.example.json config.production.json

# 2. Sửa config
nano config.production.json

# 3. Bảo mật file
chmod 600 config.production.json
```

---

## 📋 Checklist Config

### config.docker.json (Docker):

- [ ] `url`: https://tradingview.com.vn
- [ ] `server.port`: 3000
- [ ] `server.host`: 0.0.0.0
- [ ] `database.connection.host`: mysql (tên container)
- [ ] `database.connection.user`: ghost-814
- [ ] `database.connection.password`: ĐỔI PASSWORD MỚI
- [ ] `database.connection.database`: ghostproduction
- [ ] `mail.options.auth.user`: AWS SES user
- [ ] `mail.options.auth.pass`: AWS SES password
- [ ] `storage.s3.accessKeyId`: AWS access key
- [ ] `storage.s3.secretAccessKey`: AWS secret key
- [ ] `storage.s3.bucket`: Tên bucket
- [ ] `storage.s3.assetHost`: CDN URL
- [ ] `paths.contentPath`: /var/lib/ghost/content

### config.production.json (Non-Docker):

- [ ] `url`: https://tradingview.com.vn
- [ ] `server.port`: 2368
- [ ] `database.connection.host`: localhost
- [ ] `database.connection.user`: ghost_user
- [ ] `database.connection.password`: MySQL password
- [ ] `paths.contentPath`: /home/tradingview.com.vn/content
- [ ] Các thông tin AWS giống Docker

---

## 🔄 Quản lý Config trên nhiều môi trường

### Development (local):
```bash
cp config.example.json config.development.json
# Sửa: url = http://localhost:2368
```

### Staging:
```bash
cp config.docker.example.json config.docker.json
# Sửa: url = https://staging.tradingview.com.vn
```

### Production:
```bash
cp config.docker.example.json config.docker.json
# Sửa: url = https://tradingview.com.vn
```

**Lưu ý:** Mỗi môi trường có config riêng, KHÔNG commit vào Git!

---

## 🆘 Troubleshooting

### Config bị ghi đè khi pull code?
```bash
# Kiểm tra .gitignore
cat .gitignore | grep config

# Phải có dòng:
# config.*.json
# !config.example.json
# !config.docker.example.json
```

### Quên backup config trước khi pull?
```bash
# Tạo backup trước khi pull
cp config.docker.json config.docker.json.backup

# Pull code
git pull

# Restore nếu bị mất
cp config.docker.json.backup config.docker.json
```

### Cần sync config giữa các server?
```bash
# KHÔNG dùng git!
# Dùng scp để copy trực tiếp:
scp root@server1:/home/tradingview.com.vn/config.docker.json \
    root@server2:/home/tradingview.com.vn/config.docker.json
```

---

## 📌 Lưu ý quan trọng

1. ✅ **LUÔN** tạo backup config trước khi sửa
2. ✅ **KHÔNG BAO GIỜ** commit config thật vào Git
3. ✅ **LUÔN** set permission 600 cho config files
4. ✅ **SỬ DỤNG** environment variables cho sensitive data (nếu có thể)
5. ✅ **KIỂM TRA** .gitignore trước khi commit

---

**Tóm lại:**
- Template (example) → Commit vào Git ✅
- Config thật → KHÔNG commit, chỉ lưu trên server ❌


