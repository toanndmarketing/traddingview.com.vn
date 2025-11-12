#!/bin/bash

###############################################################################
# Ghost CMS - Rollback Script
# Rollback về version trước khi có lỗi
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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

print_header "GHOST CMS - ROLLBACK SCRIPT"

# Check if there are backups
BACKUP_DIR="backups"
if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    print_error "Không tìm thấy backup nào!"
    exit 1
fi

# List available backups
print_info "Các backup có sẵn:"
echo ""
ls -lht "$BACKUP_DIR"/ghost_backup_*.sql.gz | head -10 | nl
echo ""

# Select backup
read -p "Chọn số thứ tự backup để restore (hoặc Enter để chọn backup mới nhất): " BACKUP_NUM

if [ -z "$BACKUP_NUM" ]; then
    BACKUP_NUM=1
fi

BACKUP_FILE=$(ls -t "$BACKUP_DIR"/ghost_backup_*.sql.gz | sed -n "${BACKUP_NUM}p")

if [ -z "$BACKUP_FILE" ]; then
    print_error "Backup không tồn tại!"
    exit 1
fi

print_info "Backup được chọn: $BACKUP_FILE"

# Confirm
read -p "Bạn có chắc chắn muốn rollback không? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    print_warning "Đã hủy rollback"
    exit 0
fi

# Stop Ghost
print_info "Dừng Ghost..."
if pm2 list | grep -q "ghost-tradingview"; then
    pm2 stop ghost-tradingview
    print_success "Đã dừng Ghost"
fi

# Backup current database before rollback
print_info "Backup database hiện tại trước khi rollback..."
if [ -f "config.production.json" ]; then
    DB_USER=$(grep -oP '"user":\s*"\K[^"]+' config.production.json | head -1)
    DB_PASS=$(grep -oP '"password":\s*"\K[^"]+' config.production.json | head -1)
    DB_NAME=$(grep -oP '"database":\s*"\K[^"]+' config.production.json | head -1)
    DB_HOST=$(grep -oP '"host":\s*"\K[^"]+' config.production.json | head -1)
    
    CURRENT_BACKUP="$BACKUP_DIR/ghost_before_rollback_$(date +%Y%m%d_%H%M%S).sql"
    mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$CURRENT_BACKUP" 2>/dev/null
    gzip "$CURRENT_BACKUP"
    print_success "Đã backup database hiện tại: ${CURRENT_BACKUP}.gz"
fi

# Restore database
print_info "Restore database từ backup..."
gunzip -c "$BACKUP_FILE" > /tmp/restore.sql
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /tmp/restore.sql
rm /tmp/restore.sql

if [ $? -eq 0 ]; then
    print_success "Đã restore database"
else
    print_error "Restore database thất bại!"
    exit 1
fi

# Rollback Git
print_info "Rollback Git..."
read -p "Bạn có muốn rollback code về commit trước không? (y/n): " ROLLBACK_GIT
if [[ $ROLLBACK_GIT =~ ^[Yy]$ ]]; then
    git log --oneline -10
    echo ""
    read -p "Nhập commit hash để rollback (hoặc Enter để bỏ qua): " COMMIT_HASH
    
    if [ ! -z "$COMMIT_HASH" ]; then
        git reset --hard "$COMMIT_HASH"
        print_success "Đã rollback code về commit $COMMIT_HASH"
        
        # Reinstall dependencies
        print_info "Cài đặt lại dependencies..."
        npm install
        print_success "Đã cài đặt dependencies"
    fi
fi

# Restart Ghost
print_info "Khởi động lại Ghost..."
pm2 restart ghost-tradingview

sleep 5

if pm2 list | grep -q "online.*ghost-tradingview"; then
    print_success "Ghost đã khởi động lại"
else
    print_error "Ghost không khởi động được!"
    print_info "Xem logs: pm2 logs ghost-tradingview"
    exit 1
fi

print_header "ROLLBACK HOÀN TẤT!"
echo -e "${GREEN}Đã rollback thành công!${NC}\n"
echo -e "${YELLOW}Thông tin:${NC}"
echo -e "- Database restored từ: ${BLUE}$BACKUP_FILE${NC}"
echo -e "- Backup hiện tại: ${BLUE}${CURRENT_BACKUP}.gz${NC}\n"

