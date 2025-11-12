#!/bin/bash

###############################################################################
# Ghost CMS - Setup Script
# Tự động setup Ghost CMS trên server mới
###############################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Không nên chạy script này với quyền root!"
    exit 1
fi

print_header "GHOST CMS - AUTO SETUP SCRIPT"

# Step 1: Check Node.js
print_info "Bước 1: Kiểm tra Node.js..."
if ! command -v node &> /dev/null; then
    print_error "Node.js chưa được cài đặt!"
    print_info "Cài đặt Node.js v18 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Đã cài đặt Node.js"
else
    NODE_VERSION=$(node -v)
    print_success "Node.js đã cài đặt: $NODE_VERSION"
fi

# Step 2: Check npm
print_info "Bước 2: Kiểm tra npm..."
if ! command -v npm &> /dev/null; then
    print_error "npm chưa được cài đặt!"
    exit 1
else
    NPM_VERSION=$(npm -v)
    print_success "npm đã cài đặt: $NPM_VERSION"
fi

# Step 3: Check MySQL
print_info "Bước 3: Kiểm tra MySQL..."
if ! command -v mysql &> /dev/null; then
    print_warning "MySQL chưa được cài đặt!"
    read -p "Bạn có muốn cài đặt MySQL không? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get update
        sudo apt-get install -y mysql-server
        sudo mysql_secure_installation
        print_success "Đã cài đặt MySQL"
    fi
else
    print_success "MySQL đã cài đặt"
fi

# Step 4: Create config file
print_info "Bước 4: Tạo file cấu hình..."
if [ ! -f "config.production.json" ]; then
    print_info "Tạo config.production.json từ template..."
    
    # Prompt for configuration
    read -p "Nhập domain (vd: tradingview.com.vn): " DOMAIN
    read -p "Nhập port (mặc định: 2368): " PORT
    PORT=${PORT:-2368}
    
    read -p "Nhập MySQL host (mặc định: 127.0.0.1): " DB_HOST
    DB_HOST=${DB_HOST:-127.0.0.1}
    
    read -p "Nhập MySQL user: " DB_USER
    read -sp "Nhập MySQL password: " DB_PASS
    echo
    read -p "Nhập MySQL database name: " DB_NAME
    
    read -p "Sử dụng S3 storage? (y/n): " USE_S3
    
    if [[ $USE_S3 =~ ^[Yy]$ ]]; then
        read -p "AWS Access Key ID: " AWS_KEY
        read -sp "AWS Secret Access Key: " AWS_SECRET
        echo
        read -p "AWS Region (mặc định: ap-southeast-1): " AWS_REGION
        AWS_REGION=${AWS_REGION:-ap-southeast-1}
        read -p "S3 Bucket name: " S3_BUCKET
        read -p "CDN URL (optional): " CDN_URL
    fi
    
    # Create config file
    cat > config.production.json << EOF
{
  "url": "https://${DOMAIN}",
  "server": {
    "port": ${PORT},
    "host": "127.0.0.1"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "${DB_HOST}",
      "user": "${DB_USER}",
      "password": "${DB_PASS}",
      "port": 3306,
      "database": "${DB_NAME}"
    }
  },
  "logging": {
    "transports": ["file", "stdout"]
  },
  "process": "systemd",
  "paths": {
    "contentPath": "$(pwd)/content"
  }
EOF

    if [[ $USE_S3 =~ ^[Yy]$ ]]; then
        cat >> config.production.json << EOF
,
  "storage": {
    "active": "s3",
    "s3": {
      "accessKeyId": "${AWS_KEY}",
      "secretAccessKey": "${AWS_SECRET}",
      "region": "${AWS_REGION}",
      "bucket": "${S3_BUCKET}",
      "assetHost": "${CDN_URL}",
      "forcePathStyle": true,
      "signatureVersion": "v4",
      "acl": "private"
    }
  }
EOF
    fi

    echo "}" >> config.production.json

    chmod 600 config.production.json
    print_success "Đã tạo config.production.json"
else
    print_warning "config.production.json đã tồn tại, bỏ qua..."
fi

# Step 5: Install dependencies
print_info "Bước 5: Cài đặt dependencies..."
npm install
print_success "Đã cài đặt dependencies"

# Step 6: Download Ghost core
print_info "Bước 6: Kiểm tra Ghost core..."
if [ ! -d "versions/5.58.0" ]; then
    print_info "Download Ghost v5.58.0..."
    mkdir -p versions
    cd versions
    npm pack ghost@5.58.0
    tar -xzf ghost-5.58.0.tgz
    mv package 5.58.0
    rm ghost-5.58.0.tgz
    cd ..
    print_success "Đã download Ghost core"
else
    print_success "Ghost core đã tồn tại"
fi

# Step 7: Setup S3 adapter
print_info "Bước 7: Setup S3 storage adapter..."
if [ -d "node_modules/ghost-storage-adapter-s3" ]; then
    mkdir -p content/adapters/storage
    cp -r node_modules/ghost-storage-adapter-s3 content/adapters/storage/s3
    print_success "Đã setup S3 adapter"
else
    print_warning "S3 adapter không tìm thấy, bỏ qua..."
fi

# Step 8: Create necessary directories
print_info "Bước 8: Tạo thư mục cần thiết..."
mkdir -p content/data
mkdir -p content/images
mkdir -p content/media
mkdir -p content/logs
mkdir -p content/files
chmod -R 755 content
print_success "Đã tạo thư mục"

# Step 9: Setup PM2
print_info "Bước 9: Setup PM2..."
if ! command -v pm2 &> /dev/null; then
    print_info "Cài đặt PM2..."
    sudo npm install -g pm2
    print_success "Đã cài đặt PM2"
else
    print_success "PM2 đã cài đặt"
fi

# Create PM2 ecosystem file
if [ ! -f "ecosystem.config.js" ]; then
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'ghost-tradingview',
      script: 'versions/5.58.0/index.js',
      cwd: process.cwd(),
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production'
      },
      error_file: './content/logs/pm2-error.log',
      out_file: './content/logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 4000
    }
  ]
};
EOF
    print_success "Đã tạo ecosystem.config.js"
fi

# Step 10: Test database connection
print_info "Bước 10: Test kết nối database..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "Kết nối database thành công"
else
    print_error "Không thể kết nối database!"
    print_info "Tạo database..."
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    print_success "Đã tạo database"
fi

# Final message
print_header "SETUP HOÀN TẤT!"
echo -e "${GREEN}Ghost CMS đã được setup thành công!${NC}\n"
echo -e "${YELLOW}Các bước tiếp theo:${NC}"
echo -e "1. Khởi động Ghost: ${BLUE}pm2 start ecosystem.config.js${NC}"
echo -e "2. Xem logs: ${BLUE}pm2 logs ghost-tradingview${NC}"
echo -e "3. Lưu PM2: ${BLUE}pm2 save && pm2 startup${NC}"
echo -e "4. Truy cập: ${BLUE}http://localhost:${PORT}${NC}\n"
echo -e "${YELLOW}Cấu hình Nginx (nếu cần):${NC}"
echo -e "Chạy: ${BLUE}sudo bash scripts/setup-nginx.sh${NC}\n"

