#!/bin/bash

###############################################################################
# Ghost CMS - Nginx Setup Script
# Tự động cấu hình Nginx cho Ghost CMS
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

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Script này cần chạy với quyền root (sudo)"
    exit 1
fi

print_header "NGINX SETUP FOR GHOST CMS"

# Get project directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Read config
if [ -f "$PROJECT_DIR/config.production.json" ]; then
    DOMAIN=$(grep -oP '"url":\s*"https?://\K[^"]+' "$PROJECT_DIR/config.production.json")
    PORT=$(grep -oP '"port":\s*\K[0-9]+' "$PROJECT_DIR/config.production.json" | head -1)
else
    read -p "Nhập domain (vd: tradingview.com.vn): " DOMAIN
    read -p "Nhập Ghost port (mặc định: 2368): " PORT
    PORT=${PORT:-2368}
fi

print_info "Domain: $DOMAIN"
print_info "Ghost Port: $PORT"

# Install Nginx
print_info "Kiểm tra Nginx..."
if ! command -v nginx &> /dev/null; then
    print_info "Cài đặt Nginx..."
    apt-get update
    apt-get install -y nginx
    print_success "Đã cài đặt Nginx"
else
    print_success "Nginx đã cài đặt"
fi

# Create Nginx config
print_info "Tạo cấu hình Nginx..."
cat > /etc/nginx/sites-available/$DOMAIN << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN www.$DOMAIN;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Logging
    access_log /var/log/nginx/${DOMAIN}_access.log;
    error_log /var/log/nginx/${DOMAIN}_error.log;

    # Max upload size
    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF

print_success "Đã tạo cấu hình Nginx"

# Enable site
print_info "Kích hoạt site..."
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
print_success "Đã kích hoạt site"

# Test Nginx config
print_info "Kiểm tra cấu hình Nginx..."
nginx -t
if [ $? -eq 0 ]; then
    print_success "Cấu hình Nginx hợp lệ"
else
    print_error "Cấu hình Nginx không hợp lệ!"
    exit 1
fi

# Reload Nginx
print_info "Reload Nginx..."
systemctl reload nginx
print_success "Đã reload Nginx"

# Setup SSL with Certbot
print_info "Cài đặt SSL certificate..."
read -p "Bạn có muốn cài đặt SSL với Let's Encrypt không? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! command -v certbot &> /dev/null; then
        print_info "Cài đặt Certbot..."
        apt-get install -y certbot python3-certbot-nginx
    fi
    
    read -p "Nhập email cho Let's Encrypt: " EMAIL
    certbot --nginx -d $DOMAIN -d www.$DOMAIN --email $EMAIL --agree-tos --no-eff-email --redirect
    
    if [ $? -eq 0 ]; then
        print_success "Đã cài đặt SSL certificate"
        
        # Setup auto-renewal
        systemctl enable certbot.timer
        systemctl start certbot.timer
        print_success "Đã setup auto-renewal cho SSL"
    fi
fi

print_header "NGINX SETUP HOÀN TẤT!"
echo -e "${GREEN}Nginx đã được cấu hình thành công!${NC}\n"
echo -e "${YELLOW}Thông tin:${NC}"
echo -e "- Domain: ${BLUE}$DOMAIN${NC}"
echo -e "- Config: ${BLUE}/etc/nginx/sites-available/$DOMAIN${NC}"
echo -e "- Logs: ${BLUE}/var/log/nginx/${DOMAIN}_*.log${NC}\n"
echo -e "${YELLOW}Các lệnh hữu ích:${NC}"
echo -e "- Test config: ${BLUE}sudo nginx -t${NC}"
echo -e "- Reload: ${BLUE}sudo systemctl reload nginx${NC}"
echo -e "- Restart: ${BLUE}sudo systemctl restart nginx${NC}"
echo -e "- Xem logs: ${BLUE}sudo tail -f /var/log/nginx/${DOMAIN}_error.log${NC}\n"

