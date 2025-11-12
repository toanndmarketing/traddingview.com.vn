#!/bin/bash

###############################################################################
# Ghost CMS - Install Script for CloudPanel
# Cài đặt dependencies và setup Ghost trên CloudPanel Ubuntu 24
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

print_header "GHOST CMS - CLOUDPANEL INSTALL SCRIPT"

# Step 1: Check Node.js
print_info "Bước 1: Kiểm tra Node.js..."
if ! command -v node &> /dev/null; then
    print_error "Node.js chưa được cài đặt!"
    exit 1
else
    NODE_VERSION=$(node -v)
    print_success "Node.js: $NODE_VERSION"
fi

# Check npm
if ! command -v npm &> /dev/null; then
    print_error "npm chưa được cài đặt!"
    exit 1
else
    NPM_VERSION=$(npm -v)
    print_success "npm: $NPM_VERSION"
fi

# Step 2: Install dependencies
print_info "Bước 2: Cài đặt dependencies..."
npm install --production
print_success "Đã cài đặt dependencies"

# Step 3: Download Ghost core
print_info "Bước 3: Download Ghost core..."
if [ ! -d "versions/5.58.0" ]; then
    print_info "Downloading Ghost v5.58.0..."
    mkdir -p versions
    cd versions
    
    # Download Ghost package
    npm pack ghost@5.58.0
    
    # Extract
    tar -xzf ghost-5.58.0.tgz
    mv package 5.58.0
    rm ghost-5.58.0.tgz
    
    cd ..
    print_success "Đã download Ghost core v5.58.0"
else
    print_success "Ghost core đã tồn tại"
fi

# Step 4: Setup S3 storage adapter
print_info "Bước 4: Setup S3 storage adapter..."
if [ -d "node_modules/ghost-storage-adapter-s3" ]; then
    mkdir -p content/adapters/storage
    
    # Remove old adapter if exists
    rm -rf content/adapters/storage/s3
    
    # Copy new adapter
    cp -r node_modules/ghost-storage-adapter-s3 content/adapters/storage/s3
    
    print_success "Đã setup S3 storage adapter"
else
    print_warning "ghost-storage-adapter-s3 không tìm thấy trong node_modules"
    print_info "Cài đặt S3 adapter..."
    npm install ghost-storage-adapter-s3
    
    mkdir -p content/adapters/storage
    cp -r node_modules/ghost-storage-adapter-s3 content/adapters/storage/s3
    print_success "Đã cài đặt và setup S3 adapter"
fi

# Step 5: Create necessary directories
print_info "Bước 5: Tạo thư mục cần thiết..."
mkdir -p content/data
mkdir -p content/images
mkdir -p content/media
mkdir -p content/logs
mkdir -p content/files
mkdir -p backups

# Set permissions
chmod -R 755 content
chmod -R 755 backups

print_success "Đã tạo thư mục"

# Step 6: Check config file
print_info "Bước 6: Kiểm tra config file..."
if [ ! -f "config.production.json" ]; then
    print_warning "Chưa có config.production.json"
    
    if [ -f "config.example.json" ]; then
        print_info "Tạo config.production.json từ template..."
        cp config.example.json config.production.json
        chmod 600 config.production.json
        print_success "Đã tạo config.production.json"
        print_warning "⚠️  VUI LÒNG CHỈNH SỬA config.production.json với thông tin thật!"
    else
        print_error "Không tìm thấy config.example.json"
    fi
else
    print_success "config.production.json đã tồn tại"
fi

# Step 7: Install PM2 globally (if not exists)
print_info "Bước 7: Kiểm tra PM2..."
if ! command -v pm2 &> /dev/null; then
    print_warning "PM2 chưa được cài đặt"
    print_info "Cài đặt PM2 globally..."
    npm install -g pm2
    print_success "Đã cài đặt PM2"
else
    PM2_VERSION=$(pm2 -v)
    print_success "PM2 đã cài đặt: v$PM2_VERSION"
fi

# Step 8: Create PM2 ecosystem file
print_info "Bước 8: Tạo PM2 ecosystem file..."
if [ ! -f "ecosystem.config.js" ]; then
    if [ -f "ecosystem.config.example.js" ]; then
        cp ecosystem.config.example.js ecosystem.config.js
        print_success "Đã tạo ecosystem.config.js"
    else
        # Create basic ecosystem file
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
else
    print_success "ecosystem.config.js đã tồn tại"
fi

# Final summary
print_header "CÀI ĐẶT HOÀN TẤT!"
echo -e "${GREEN}Ghost CMS đã được cài đặt thành công!${NC}\n"

echo -e "${YELLOW}📋 CHECKLIST TIẾP THEO:${NC}\n"
echo -e "1. ${BLUE}Chỉnh sửa config.production.json${NC}"
echo -e "   - Database credentials"
echo -e "   - AWS S3 credentials"
echo -e "   - Domain và port"
echo -e ""
echo -e "2. ${BLUE}Khởi động Ghost:${NC}"
echo -e "   ${GREEN}pm2 start ecosystem.config.js${NC}"
echo -e ""
echo -e "3. ${BLUE}Xem logs:${NC}"
echo -e "   ${GREEN}pm2 logs ghost-tradingview${NC}"
echo -e ""
echo -e "4. ${BLUE}Lưu PM2 process:${NC}"
echo -e "   ${GREEN}pm2 save${NC}"
echo -e ""
echo -e "5. ${BLUE}Setup PM2 startup (chạy khi reboot):${NC}"
echo -e "   ${GREEN}pm2 startup${NC}"
echo -e ""

echo -e "${YELLOW}📁 CẤU TRÚC THƯ MỤC:${NC}"
echo -e "✓ versions/5.58.0/          - Ghost core"
echo -e "✓ content/adapters/storage/ - S3 adapter"
echo -e "✓ content/themes/           - Custom themes"
echo -e "✓ node_modules/             - Dependencies"
echo -e "✓ config.production.json    - Config file (cần chỉnh sửa)"
echo -e "✓ ecosystem.config.js       - PM2 config"
echo -e ""

echo -e "${YELLOW}🔧 CÁC LỆNH HỮU ÍCH:${NC}"
echo -e "- Start:   ${GREEN}pm2 start ecosystem.config.js${NC}"
echo -e "- Stop:    ${GREEN}pm2 stop ghost-tradingview${NC}"
echo -e "- Restart: ${GREEN}pm2 restart ghost-tradingview${NC}"
echo -e "- Logs:    ${GREEN}pm2 logs ghost-tradingview${NC}"
echo -e "- Status:  ${GREEN}pm2 status${NC}"
echo -e "- Update:  ${GREEN}bash scripts/update.sh${NC}"
echo -e ""

