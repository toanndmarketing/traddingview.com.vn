#!/bin/bash

###############################################################################
# Ghost CMS - Docker Setup Script
# Tự động setup Ghost CMS bằng Docker
###############################################################################

set -e  # Exit on error

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

print_header "GHOST CMS - DOCKER SETUP SCRIPT"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Step 1: Check Docker
print_info "Bước 1: Kiểm tra Docker..."
if ! command -v docker &> /dev/null; then
    print_warning "Docker chưa được cài đặt!"
    read -p "Bạn có muốn cài Docker không? (y/n): " INSTALL_DOCKER
    
    if [[ $INSTALL_DOCKER =~ ^[Yy]$ ]]; then
        print_info "Cài đặt Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        print_success "Đã cài đặt Docker"
    else
        print_error "Cần Docker để tiếp tục!"
        exit 1
    fi
else
    DOCKER_VERSION=$(docker --version)
    print_success "Docker: $DOCKER_VERSION"
fi

# Step 2: Check Docker Compose
print_info "Bước 2: Kiểm tra Docker Compose..."
if ! docker compose version &> /dev/null; then
    print_warning "Docker Compose chưa được cài đặt!"
    print_info "Cài đặt Docker Compose..."
    
    apt-get update
    apt-get install -y docker-compose-plugin
    
    print_success "Đã cài đặt Docker Compose"
else
    COMPOSE_VERSION=$(docker compose version)
    print_success "Docker Compose: $COMPOSE_VERSION"
fi

# Step 3: Check Dockerfile
print_info "Bước 3: Kiểm tra Dockerfile..."
if [ ! -f "Dockerfile" ]; then
    print_error "Không tìm thấy Dockerfile!"
    exit 1
else
    print_success "Dockerfile đã tồn tại"
fi

# Step 4: Check docker-compose.yml
print_info "Bước 4: Kiểm tra docker-compose.yml..."
if [ ! -f "docker-compose.yml" ]; then
    print_error "Không tìm thấy docker-compose.yml!"
    exit 1
else
    print_success "docker-compose.yml đã tồn tại"
fi

# Step 5: Check config.docker.json
print_info "Bước 5: Kiểm tra config.docker.json..."
if [ ! -f "config.docker.json" ]; then
    print_warning "Chưa có config.docker.json"
    
    if [ -f "config.example.json" ]; then
        print_info "Tạo config.docker.json từ template..."
        cp config.example.json config.docker.json
        print_success "Đã tạo config.docker.json"
        print_warning "⚠️  VUI LÒNG CHỈNH SỬA config.docker.json với thông tin thật!"
        print_info "Nhấn Enter để tiếp tục sau khi đã chỉnh sửa..."
        read
    else
        print_error "Không tìm thấy config.example.json"
        exit 1
    fi
else
    print_success "config.docker.json đã tồn tại"
fi

# Step 6: Stop existing containers (if any)
print_info "Bước 6: Dừng containers cũ (nếu có)..."
if docker compose ps | grep -q "Up"; then
    print_info "Dừng containers đang chạy..."
    docker compose down
    print_success "Đã dừng containers"
else
    print_success "Không có containers đang chạy"
fi

# Step 7: Build images
print_info "Bước 7: Build Docker images..."
print_info "Quá trình này có thể mất vài phút..."
docker compose build
print_success "Đã build images"

# Step 8: Start containers
print_info "Bước 8: Khởi động containers..."
docker compose up -d
print_success "Đã khởi động containers"

# Wait for containers to be ready
print_info "Đợi containers khởi động..."
sleep 10

# Step 9: Check containers status
print_info "Bước 9: Kiểm tra containers..."
docker compose ps

if docker compose ps | grep -q "ghost-tradingview.*Up"; then
    print_success "Ghost container đang chạy"
else
    print_error "Ghost container không chạy!"
    print_info "Xem logs: docker compose logs ghost"
    exit 1
fi

if docker compose ps | grep -q "ghost-mysql.*Up"; then
    print_success "MySQL container đang chạy"
else
    print_error "MySQL container không chạy!"
    print_info "Xem logs: docker compose logs mysql"
    exit 1
fi

# Step 10: Import database (optional)
print_info "Bước 10: Import database..."
if [ -f "database_new.sql" ] || [ -f "database_new.sql.gz" ]; then
    read -p "Bạn có muốn import database không? (y/n): " IMPORT_DB
    
    if [[ $IMPORT_DB =~ ^[Yy]$ ]]; then
        if [ -f "database_new.sql.gz" ]; then
            print_info "Giải nén database..."
            gunzip -k database_new.sql.gz
        fi
        
        if [ -f "database_new.sql" ]; then
            print_info "Import database..."
            docker compose exec -T mysql mysql -u root -prootpassword ghostproduction < database_new.sql
            print_success "Đã import database"
            
            print_info "Restart Ghost..."
            docker compose restart ghost
            sleep 5
        fi
    fi
else
    print_warning "Không tìm thấy file database backup"
fi

# Final summary
print_header "CÀI ĐẶT HOÀN TẤT!"
echo -e "${GREEN}Ghost CMS đã được setup thành công với Docker!${NC}\n"

echo -e "${YELLOW}📋 THÔNG TIN:${NC}\n"
echo -e "- Ghost URL: ${BLUE}http://localhost:3005${NC}"
echo -e "- MySQL Port: ${BLUE}3306${NC}"
echo -e "- Redis: ${BLUE}Running${NC}"
echo -e ""

echo -e "${YELLOW}📋 CHECKLIST TIẾP THEO:${NC}\n"
echo -e "1. ${BLUE}Kiểm tra Ghost:${NC}"
echo -e "   ${GREEN}curl http://localhost:3005${NC}"
echo -e ""
echo -e "2. ${BLUE}Xem logs:${NC}"
echo -e "   ${GREEN}docker compose logs -f ghost${NC}"
echo -e ""
echo -e "3. ${BLUE}Cài Nginx:${NC}"
echo -e "   ${GREEN}apt-get install -y nginx${NC}"
echo -e ""
echo -e "4. ${BLUE}Setup Nginx reverse proxy (KHÔNG CẦN SSL):${NC}"
echo -e "   ${YELLOW}Domain đã dùng Cloudflare SSL${NC}"
echo -e "   (Xem hướng dẫn trong SETUP_CLOUDFLARE_139.180.221.202.md)"
echo -e ""
echo -e "5. ${BLUE}Cấu hình Cloudflare:${NC}"
echo -e "   - DNS: A record -> 139.180.221.202 (Proxied)"
echo -e "   - SSL/TLS: Full mode"
echo -e ""

echo -e "${YELLOW}🔧 CÁC LỆNH HỮU ÍCH:${NC}"
echo -e "- Start:   ${GREEN}docker compose up -d${NC}"
echo -e "- Stop:    ${GREEN}docker compose down${NC}"
echo -e "- Restart: ${GREEN}docker compose restart${NC}"
echo -e "- Logs:    ${GREEN}docker compose logs -f ghost${NC}"
echo -e "- Status:  ${GREEN}docker compose ps${NC}"
echo -e "- Shell:   ${GREEN}docker compose exec ghost sh${NC}"
echo -e ""


