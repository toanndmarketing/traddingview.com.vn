#!/bin/bash

###############################################################################
# Ghost CMS - One-Click Deploy Script
# Deploy Ghost CMS lên server mới chỉ với 1 lệnh
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_header "GHOST CMS - ONE-CLICK DEPLOY"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Make scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Step 1: Run setup
print_header "BƯỚC 1: SETUP GHOST CMS"
bash "$SCRIPT_DIR/setup.sh"

# Step 2: Setup Nginx
print_header "BƯỚC 2: SETUP NGINX"
read -p "Bạn có muốn setup Nginx không? (y/n): " SETUP_NGINX
if [[ $SETUP_NGINX =~ ^[Yy]$ ]]; then
    sudo bash "$SCRIPT_DIR/setup-nginx.sh"
fi

# Step 3: Start Ghost
print_header "BƯỚC 3: KHỞI ĐỘNG GHOST"
cd "$PROJECT_DIR"

if pm2 list | grep -q "ghost-tradingview"; then
    print_info "Ghost đang chạy, restart..."
    pm2 restart ghost-tradingview
else
    print_info "Khởi động Ghost..."
    pm2 start ecosystem.config.js
fi

# Save PM2 process
pm2 save

# Setup PM2 startup
print_info "Setup PM2 auto-start..."
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u $USER --hp $HOME

print_success "Ghost đã được khởi động"

# Step 4: Show status
print_header "TRẠNG THÁI HỆ THỐNG"
pm2 list

# Final message
print_header "DEPLOY HOÀN TẤT!"
echo -e "${GREEN}Ghost CMS đã được deploy thành công!${NC}\n"

# Get domain and port from config
if [ -f "$PROJECT_DIR/config.production.json" ]; then
    DOMAIN=$(grep -oP '"url":\s*"https?://\K[^"]+' "$PROJECT_DIR/config.production.json")
    PORT=$(grep -oP '"port":\s*\K[0-9]+' "$PROJECT_DIR/config.production.json" | head -1)
    
    echo -e "${YELLOW}Thông tin truy cập:${NC}"
    if [[ $SETUP_NGINX =~ ^[Yy]$ ]]; then
        echo -e "- URL: ${BLUE}http://$DOMAIN${NC}"
        echo -e "- Admin: ${BLUE}http://$DOMAIN/ghost${NC}"
    else
        echo -e "- URL: ${BLUE}http://localhost:$PORT${NC}"
        echo -e "- Admin: ${BLUE}http://localhost:$PORT/ghost${NC}"
    fi
fi

echo -e "\n${YELLOW}Các lệnh hữu ích:${NC}"
echo -e "- Xem logs: ${BLUE}pm2 logs ghost-tradingview${NC}"
echo -e "- Restart: ${BLUE}pm2 restart ghost-tradingview${NC}"
echo -e "- Stop: ${BLUE}pm2 stop ghost-tradingview${NC}"
echo -e "- Status: ${BLUE}pm2 status${NC}"
echo -e "- Update: ${BLUE}bash scripts/update.sh${NC}"
echo -e "- Rollback: ${BLUE}bash scripts/rollback.sh${NC}\n"

echo -e "${YELLOW}Bước tiếp theo:${NC}"
echo -e "1. Truy cập ${BLUE}http://$DOMAIN/ghost${NC} để setup admin"
echo -e "2. Tạo tài khoản admin đầu tiên"
echo -e "3. Cấu hình theme và settings\n"

