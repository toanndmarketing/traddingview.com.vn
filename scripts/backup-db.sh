#!/bin/bash

###############################################################################
# Ghost CMS - Database Backup Script
# Backup database Ghost CMS
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

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

print_info "Ghost CMS - Database Backup"
echo ""

# Check config file
if [ ! -f "config.production.json" ]; then
    print_error "Không tìm thấy config.production.json"
    exit 1
fi

# Read database config
DB_USER=$(grep -oP '"user":\s*"\K[^"]+' config.production.json | head -1)
DB_PASS=$(grep -oP '"password":\s*"\K[^"]+' config.production.json | head -1)
DB_NAME=$(grep -oP '"database":\s*"\K[^"]+' config.production.json | head -1)
DB_HOST=$(grep -oP '"host":\s*"\K[^"]+' config.production.json | head -1)

if [ -z "$DB_USER" ] || [ -z "$DB_NAME" ]; then
    print_error "Không đọc được thông tin database từ config"
    exit 1
fi

print_info "Database: $DB_NAME"
print_info "Host: $DB_HOST"
print_info "User: $DB_USER"
echo ""

# Create backup directory
BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"

# Generate backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/ghost_backup_${TIMESTAMP}.sql"

# Backup database
print_info "Đang backup database..."

mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    print_success "Đã backup database: $BACKUP_FILE"
    
    # Get file size
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    print_info "Kích thước: $FILE_SIZE"
    
    # Compress backup
    print_info "Đang nén backup..."
    gzip "$BACKUP_FILE"
    
    COMPRESSED_SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
    print_success "Đã nén backup: ${BACKUP_FILE}.gz"
    print_info "Kích thước nén: $COMPRESSED_SIZE"
    
    # Clean old backups (keep last 7)
    print_info "Dọn dẹp backup cũ..."
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/ghost_backup_*.sql.gz 2>/dev/null | wc -l)
    
    if [ "$BACKUP_COUNT" -gt 7 ]; then
        ls -t "$BACKUP_DIR"/ghost_backup_*.sql.gz | tail -n +8 | xargs -r rm
        DELETED=$((BACKUP_COUNT - 7))
        print_success "Đã xóa $DELETED backup cũ (giữ lại 7 bản gần nhất)"
    else
        print_info "Có $BACKUP_COUNT backup (giữ tối đa 7 bản)"
    fi
    
    echo ""
    print_success "BACKUP HOÀN TẤT!"
    echo ""
    print_info "File backup: ${BACKUP_FILE}.gz"
    print_info "Thư mục backup: $BACKUP_DIR"
    
    # List recent backups
    echo ""
    print_info "Các backup gần đây:"
    ls -lht "$BACKUP_DIR"/ghost_backup_*.sql.gz | head -5
    
else
    print_error "Backup database thất bại!"
    print_info "Kiểm tra lại thông tin database trong config.production.json"
    exit 1
fi

