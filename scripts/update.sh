#!/bin/bash

###############################################################################
# Ghost CMS - Update Script
# Tự động pull code mới và update Ghost CMS
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

# Get current directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

print_header "GHOST CMS - AUTO UPDATE SCRIPT"

# Step 1: Check if PM2 is running
print_info "Bước 1: Kiểm tra Ghost đang chạy..."
if pm2 list | grep -q "ghost-tradingview"; then
    GHOST_RUNNING=true
    print_success "Ghost đang chạy"
else
    GHOST_RUNNING=false
    print_warning "Ghost không chạy"
fi

# Step 2: Backup database
print_info "Bước 2: Backup database..."
if [ -f "config.production.json" ]; then
    DB_USER=$(grep -oP '"user":\s*"\K[^"]+' config.production.json | head -1)
    DB_PASS=$(grep -oP '"password":\s*"\K[^"]+' config.production.json | head -1)
    DB_NAME=$(grep -oP '"database":\s*"\K[^"]+' config.production.json | head -1)
    DB_HOST=$(grep -oP '"host":\s*"\K[^"]+' config.production.json | head -1)
    
    BACKUP_DIR="backups"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/ghost_backup_$(date +%Y%m%d_%H%M%S).sql"
    
    mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Đã backup database: $BACKUP_FILE"
        # Compress backup
        gzip "$BACKUP_FILE"
        print_success "Đã nén backup: ${BACKUP_FILE}.gz"
        
        # Keep only last 7 backups
        ls -t "$BACKUP_DIR"/ghost_backup_*.sql.gz | tail -n +8 | xargs -r rm
        print_info "Đã xóa backup cũ (giữ lại 7 bản gần nhất)"
    else
        print_error "Backup database thất bại!"
        read -p "Bạn có muốn tiếp tục không? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    print_warning "Không tìm thấy config.production.json, bỏ qua backup"
fi

# Step 3: Backup config files
print_info "Bước 3: Backup config files..."
if [ -f "config.production.json" ]; then
    cp config.production.json config.production.json.backup
    print_success "Đã backup config.production.json"
fi

# Step 4: Stop Ghost
if [ "$GHOST_RUNNING" = true ]; then
    print_info "Bước 4: Dừng Ghost..."
    pm2 stop ghost-tradingview
    print_success "Đã dừng Ghost"
fi

# Step 5: Stash local changes
print_info "Bước 5: Lưu thay đổi local..."
git stash push -m "Auto stash before update $(date +%Y%m%d_%H%M%S)"
print_success "Đã stash local changes"

# Step 6: Pull latest code
print_info "Bước 6: Pull code mới từ Git..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
print_info "Branch hiện tại: $CURRENT_BRANCH"

git fetch origin
git pull origin "$CURRENT_BRANCH"

if [ $? -eq 0 ]; then
    print_success "Đã pull code mới"
else
    print_error "Pull code thất bại!"
    git stash pop
    exit 1
fi

# Step 7: Install/Update dependencies
print_info "Bước 7: Update dependencies..."
npm install
print_success "Đã update dependencies"

# Step 8: Update S3 adapter
print_info "Bước 8: Update S3 adapter..."
if [ -d "node_modules/ghost-storage-adapter-s3" ]; then
    rm -rf content/adapters/storage/s3
    mkdir -p content/adapters/storage
    cp -r node_modules/ghost-storage-adapter-s3 content/adapters/storage/s3
    print_success "Đã update S3 adapter"
fi

# Step 9: Restore config if needed
print_info "Bước 9: Kiểm tra config..."
if [ ! -f "config.production.json" ] && [ -f "config.production.json.backup" ]; then
    cp config.production.json.backup config.production.json
    print_success "Đã restore config từ backup"
fi

# Step 10: Run database migrations (if any)
print_info "Bước 10: Chạy database migrations..."
if [ -f "versions/5.58.0/index.js" ]; then
    NODE_ENV=production node versions/5.58.0/index.js --migrate || true
    print_success "Đã chạy migrations"
fi

# Step 11: Restart Ghost
if [ "$GHOST_RUNNING" = true ]; then
    print_info "Bước 11: Khởi động lại Ghost..."
    pm2 restart ghost-tradingview
    print_success "Đã khởi động lại Ghost"

    # Wait for Ghost to start
    sleep 5

    # Check if Ghost is running
    if pm2 list | grep -q "online.*ghost-tradingview"; then
        print_success "Ghost đang chạy bình thường"
    else
        print_error "Ghost không khởi động được!"
        print_info "Xem logs: pm2 logs ghost-tradingview"
        exit 1
    fi
else
    print_warning "Ghost không tự động khởi động"
    print_info "Chạy: pm2 start ecosystem.config.js"
fi

# Step 12: Show status
print_info "Bước 12: Kiểm tra status..."
pm2 list | grep ghost-tradingview || true

# Final message
print_header "UPDATE HOÀN TẤT!"
echo -e "${GREEN}Ghost CMS đã được update thành công!${NC}\n"
echo -e "${YELLOW}Thông tin:${NC}"
echo -e "- Branch: ${BLUE}$CURRENT_BRANCH${NC}"
echo -e "- Commit: ${BLUE}$(git log -1 --pretty=format:'%h - %s')${NC}"
echo -e "- Backup: ${BLUE}$BACKUP_FILE.gz${NC}\n"
echo -e "${YELLOW}Các lệnh hữu ích:${NC}"
echo -e "- Xem logs: ${BLUE}pm2 logs ghost-tradingview${NC}"
echo -e "- Restart: ${BLUE}pm2 restart ghost-tradingview${NC}"
echo -e "- Status: ${BLUE}pm2 status${NC}"
echo -e "- Rollback: ${BLUE}bash scripts/rollback.sh${NC}\n"

