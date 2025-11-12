#!/bin/bash

###############################################################################
# Ghost CMS - Control Script
# Quản lý Ghost CMS: start, stop, restart, status, logs
###############################################################################

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

APP_NAME="ghost-tradingview"

# Function to check if Ghost is running
is_running() {
    pm2 list | grep -q "$APP_NAME"
}

# Function to check if Ghost is online
is_online() {
    pm2 list | grep -q "online.*$APP_NAME"
}

# Show usage
usage() {
    echo -e "${BLUE}Ghost CMS Control Script${NC}\n"
    echo "Usage: $0 {start|stop|restart|status|logs|reload}"
    echo ""
    echo "Commands:"
    echo "  start   - Khởi động Ghost"
    echo "  stop    - Dừng Ghost"
    echo "  restart - Khởi động lại Ghost"
    echo "  reload  - Reload Ghost (zero-downtime)"
    echo "  status  - Xem trạng thái Ghost"
    echo "  logs    - Xem logs realtime"
    echo "  info    - Xem thông tin chi tiết"
    echo ""
    exit 1
}

# Start Ghost
start_ghost() {
    print_info "Khởi động Ghost..."
    
    if is_online; then
        print_warning "Ghost đang chạy rồi!"
        pm2 list | grep "$APP_NAME"
        return
    fi
    
    if [ ! -f "ecosystem.config.js" ]; then
        print_error "Không tìm thấy ecosystem.config.js"
        exit 1
    fi
    
    pm2 start ecosystem.config.js
    
    sleep 3
    
    if is_online; then
        print_success "Ghost đã khởi động thành công!"
        pm2 list | grep "$APP_NAME"
    else
        print_error "Ghost không khởi động được!"
        print_info "Xem logs: pm2 logs $APP_NAME"
        exit 1
    fi
}

# Stop Ghost
stop_ghost() {
    print_info "Dừng Ghost..."
    
    if ! is_running; then
        print_warning "Ghost không chạy!"
        return
    fi
    
    pm2 stop "$APP_NAME"
    print_success "Đã dừng Ghost"
}

# Restart Ghost
restart_ghost() {
    print_info "Khởi động lại Ghost..."
    
    if ! is_running; then
        print_warning "Ghost không chạy, khởi động mới..."
        start_ghost
        return
    fi
    
    pm2 restart "$APP_NAME"
    
    sleep 3
    
    if is_online; then
        print_success "Ghost đã khởi động lại thành công!"
        pm2 list | grep "$APP_NAME"
    else
        print_error "Ghost không khởi động được!"
        print_info "Xem logs: pm2 logs $APP_NAME"
        exit 1
    fi
}

# Reload Ghost (zero-downtime)
reload_ghost() {
    print_info "Reload Ghost (zero-downtime)..."
    
    if ! is_running; then
        print_warning "Ghost không chạy, khởi động mới..."
        start_ghost
        return
    fi
    
    pm2 reload "$APP_NAME"
    
    sleep 3
    
    if is_online; then
        print_success "Ghost đã reload thành công!"
        pm2 list | grep "$APP_NAME"
    else
        print_error "Ghost reload thất bại!"
        print_info "Xem logs: pm2 logs $APP_NAME"
        exit 1
    fi
}

# Show status
show_status() {
    echo -e "${BLUE}=== Ghost Status ===${NC}\n"
    
    if is_running; then
        pm2 list | grep "$APP_NAME"
        echo ""
        
        if is_online; then
            print_success "Ghost đang chạy bình thường"
        else
            print_error "Ghost có vấn đề!"
        fi
    else
        print_warning "Ghost không chạy"
    fi
    
    echo ""
    echo -e "${YELLOW}Thông tin:${NC}"
    
    if [ -f "config.production.json" ]; then
        DOMAIN=$(grep -oP '"url":\s*"https?://\K[^"]+' config.production.json 2>/dev/null || echo "N/A")
        PORT=$(grep -oP '"port":\s*\K[0-9]+' config.production.json 2>/dev/null | head -1 || echo "N/A")
        echo -e "- Domain: ${BLUE}$DOMAIN${NC}"
        echo -e "- Port: ${BLUE}$PORT${NC}"
    fi
    
    if [ -d "versions" ]; then
        GHOST_VERSION=$(ls -1 versions/ | head -1)
        echo -e "- Ghost Version: ${BLUE}$GHOST_VERSION${NC}"
    fi
}

# Show logs
show_logs() {
    print_info "Xem logs realtime (Ctrl+C để thoát)..."
    pm2 logs "$APP_NAME"
}

# Show info
show_info() {
    echo -e "${BLUE}=== Ghost Information ===${NC}\n"
    pm2 describe "$APP_NAME"
}

# Main
case "$1" in
    start)
        start_ghost
        ;;
    stop)
        stop_ghost
        ;;
    restart)
        restart_ghost
        ;;
    reload)
        reload_ghost
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    info)
        show_info
        ;;
    *)
        usage
        ;;
esac

