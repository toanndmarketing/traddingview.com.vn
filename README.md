# TradingView.com.vn - Ghost CMS

Website TradingView Vietnam chạy trên Ghost CMS v5.58.0

## 📋 Yêu cầu hệ thống

- **Node.js**: v16.14.0+ hoặc v18.12.1+ (khuyến nghị v18 LTS)
- **MySQL**: 5.7+ hoặc 8.0+
- **NPM**: 6.0+

## 🚀 Cài đặt

### Cách 1: Deploy tự động (Khuyến nghị)

```bash
# Clone repository
git clone git@github.com:toanndmarketing/traddingview.com.vn.git
cd tradingview.com.vn

# Chạy script deploy tự động
bash scripts/deploy.sh
```

Script sẽ tự động:
- ✅ Cài đặt Node.js, MySQL (nếu cần)
- ✅ Tạo config file
- ✅ Cài đặt dependencies
- ✅ Setup PM2
- ✅ Setup Nginx (optional)
- ✅ Khởi động Ghost

### Cách 2: Cài đặt thủ công

#### 1. Clone repository

```bash
git clone git@github.com:toanndmarketing/traddingview.com.vn.git
cd tradingview.com.vn
```

#### 2. Cài đặt dependencies

```bash
npm install
```

#### 3. Cấu hình

Tạo file `config.production.json` từ template:

```json
{
  "url": "https://tradingview.com.vn",
  "server": {
    "port": 2366,
    "host": "127.0.0.1"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "127.0.0.1",
      "user": "YOUR_DB_USER",
      "password": "YOUR_DB_PASSWORD",
      "port": 3306,
      "database": "ghost_production"
    }
  },
  "storage": {
    "active": "s3",
    "s3": {
      "accessKeyId": "YOUR_AWS_ACCESS_KEY",
      "secretAccessKey": "YOUR_AWS_SECRET_KEY",
      "region": "ap-southeast-1",
      "bucket": "YOUR_BUCKET_NAME",
      "assetHost": "YOUR_CDN_URL"
    }
  }
}
```

### 4. Chạy Ghost

```bash
# Development
NODE_ENV=development node versions/5.58.0/index.js

# Production
NODE_ENV=production node versions/5.58.0/index.js
```

## 📁 Cấu trúc thư mục

```
tradingview.com.vn/
├── content/              # Nội dung Ghost
│   ├── themes/          # Themes tùy chỉnh
│   │   ├── tradingview-v3/
│   │   └── tradingview-v6/
│   ├── data/            # Database backups (gitignored)
│   ├── images/          # Uploaded images (gitignored)
│   └── settings/        # Settings files
├── versions/            # Ghost core (gitignored)
├── node_modules/        # Dependencies (gitignored)
├── config.production.json  # Config (gitignored)
└── package.json         # Package dependencies
```

## 🎨 Themes

- **tradingview-v3**: Theme phiên bản 3
- **tradingview-v6**: Theme phiên bản 6 (hiện tại)

## 🔧 Cấu hình quan trọng

### Storage (AWS S3)
- Ảnh và media được lưu trên AWS S3
- CDN: CloudFront hoặc custom CDN
- Region: ap-southeast-1 (Singapore)

### Email (AWS SES)
- SMTP qua AWS SES
- Region: us-east-1

### Database
- MySQL 8.0
- Database: `ghost_production`

## 📝 Scripts

### Deployment Scripts

```bash
# Deploy lần đầu (fresh server)
bash scripts/deploy.sh

# Update code mới
bash scripts/update.sh

# Rollback về version trước
bash scripts/rollback.sh

# Setup Nginx
sudo bash scripts/setup-nginx.sh
```

### NPM Scripts

```bash
# Cài đặt dependencies
npm install

# Chạy development
npm run dev

# Build assets
npm run build
```

📚 **Chi tiết:** Xem [scripts/README.md](scripts/README.md)

## 🔐 Bảo mật

- **KHÔNG** commit file `config.*.json` (chứa credentials)
- **KHÔNG** commit folder `node_modules/`
- **KHÔNG** commit folder `versions/` (Ghost core)
- **KHÔNG** commit database files

## 📚 Tài liệu

- [Ghost Documentation](https://ghost.org/docs/)
- [Ghost API](https://ghost.org/docs/content-api/)
- [Theme Development](https://ghost.org/docs/themes/)

## 🆘 Hỗ trợ

- Ghost Forum: https://forum.ghost.org/
- Documentation: https://ghost.org/docs/

## 📄 License

MIT License - Ghost CMS

