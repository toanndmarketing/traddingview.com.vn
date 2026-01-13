# Server Monitor Service

Docker-based monitoring service cho production server với Telegram alerts.

## 📋 Tổng quan

Service này chạy trên **production server 57.129.45.30** để theo dõi:

- 💾 Disk space usage
- 🔥 CPU & Memory usage
- 🐳 Docker containers health
- 🔒 SSH security (fail2ban)

Alerts được gửi tự động qua **Telegram** khi phát hiện vấn đề.

## 🚀 Cài đặt trên Production

### 1. Tạo thư mục và files

```bash
ssh root@57.129.45.30 "mkdir -p /root/monitor-service"
```

### 2. Upload files

Cần upload 3 files lên server:

- `Dockerfile` - Container definition
- `docker-compose.yml` - Service configuration
- `monitor.sh` - Main monitoring script

```bash
scp monitor.sh root@57.129.45.30:/root/monitor-service/
scp Dockerfile root@57.129.45.30:/root/monitor-service/
scp docker-compose.yml root@57.129.45.30:/root/monitor-service/
```

### 3. Tạo file .env (chỉ trên server)

```bash
ssh root@57.129.45.30 "cat > /root/monitor-service/.env << 'EOF'
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here
EOF
"
```

**⚠️ QUAN TRỌNG**: File `.env` chỉ tồn tại trên production server, KHÔNG commit vào Git!

### 4. Build và start service

```bash
ssh root@57.129.45.30 "cd /root/monitor-service && docker compose up -d --build"
```

## 📊 Monitoring Features

### Disk Space Alert

- **Threshold**: 80%
- **Alert**: 🚨 DISK SPACE ALERT
- **Info**: Usage %, Free space, Total space

### CPU Usage Alert

- **Threshold**: 80%
- **Alert**: 🔥 HIGH CPU USAGE
- **Info**: CPU %, Top processes

### Memory Usage Alert

- **Threshold**: 85%
- **Alert**: 💾 HIGH MEMORY USAGE
- **Info**: Memory %, Used/Total

### Docker Container Alerts

- **Unhealthy containers**: 🐳 UNHEALTHY CONTAINER ALERT
- **Stopped containers**: ⛔ STOPPED CONTAINER ALERT
- **Info**: Container names, status

### SSH Security Alert

- **New banned IPs**: 🔒 SSH ATTACK DETECTED
- **Info**: Total banned, New bans, IP list
- **Fail2ban down**: 🚨 FAIL2BAN ERROR

## ⚙️ Configuration

### Thresholds (trong monitor.sh)

```bash
DISK_THRESHOLD=80        # Disk usage %
CPU_THRESHOLD=80         # CPU usage %
MEMORY_THRESHOLD=85      # Memory usage %
MAX_CONTAINER_RESTARTS=3 # Container restart count
```

### Check Interval

Monitor chạy mỗi **5 phút** (300 seconds). Có thể thay đổi trong `docker-compose.yml`:

```dockerfile
CMD ["sh", "-c", "while true; do /app/monitor.sh; sleep 300; done"]
```

## 🔧 Quản lý Service

### Xem logs

```bash
ssh root@57.129.45.30 "docker logs server-monitor -f"
```

### Restart service

```bash
ssh root@57.129.45.30 "cd /root/monitor-service && docker compose restart"
```

### Stop service

```bash
ssh root@57.129.45.30 "cd /root/monitor-service && docker compose stop"
```

### Start service

```bash
ssh root@57.129.45.30 "cd /root/monitor-service && docker compose start"
```

### Rebuild sau khi sửa code

```bash
ssh root@57.129.45.30 "cd /root/monitor-service && docker compose up -d --build"
```

### Xem status

```bash
ssh root@57.129.45.30 "docker ps | grep server-monitor"
```

## 📝 File Structure

```
/root/monitor-service/
├── .env                    # Telegram credentials (KHÔNG commit)
├── Dockerfile              # Alpine Linux + monitoring tools
├── docker-compose.yml      # Docker Compose configuration
└── monitor.sh              # Main monitoring script
```

## 🔐 Security

- File `.env` có permissions `600` (chỉ root đọc được)
- Container chạy với `network_mode: host` để access fail2ban socket
- Mounted volumes là **read-only** (`:ro`) trừ Docker socket
- Không cần privileged mode

## 🐛 Troubleshooting

### Monitor không gửi Telegram

1. Kiểm tra env variables:

```bash
ssh root@57.129.45.30 "docker exec server-monitor env | grep TELEGRAM"
```

1. Test Telegram API:

```bash
ssh root@57.129.45.30 "docker exec server-monitor curl -s https://api.telegram.org/bot\${TELEGRAM_BOT_TOKEN}/getMe"
```

### Container bị restart liên tục

```bash
ssh root@57.129.45.30 "docker logs server-monitor --tail 100"
```

### Fail2ban check không hoạt động

Kiểm tra fail2ban socket được mount đúng:

```bash
ssh root@57.129.45.30 "docker exec server-monitor fail2ban-client status"
```

## 📱 Telegram Setup

### Tạo Bot

1. Chat với [@BotFather](https://t.me/BotFather)
2. Gửi `/newbot`
3. Đặt tên và username cho bot
4. Lưu **Bot Token**

### Lấy Chat ID

1. Thêm bot vào group
2. Gửi message bất kỳ trong group
3. Truy cập: `https://api.telegram.org/bot<TOKEN>/getUpdates`
4. Tìm `"chat":{"id":-xxxxxxxxx}` - đó là Chat ID

## 🔄 Auto-start on Reboot

Service tự động start khi server reboot nhờ:

```yaml
restart: unless-stopped
```

## 📊 Example Alerts

### Disk Space Alert

```
🚨 DISK SPACE ALERT

📍 Server: 57.129.45.30 (vps-2f2551be)
💾 Disk Usage: 85%
⚠️ Threshold: 80%

Free: 15G / Total: 100G

⏰ Time: 2026-01-13 14:30:00
```

### SSH Attack Alert

```
🔒 SSH ATTACK DETECTED

📍 Server: 57.129.45.30
🚫 Currently Banned: 45 IPs
🆕 New Bans: 3

Recent Banned IPs:
103.160.107.245 104.248.201.223 106.75.153.165

⏰ 2026-01-13 14:30:00
```

## 📅 Changelog

### 2026-01-13

- ✅ Initial release
- ✅ Disk, CPU, Memory monitoring
- ✅ Docker container health checks
- ✅ SSH security monitoring (fail2ban)
- ✅ Telegram alerts integration
- ✅ Auto-restart on failure

## 🤝 Contributing

Để cập nhật monitor:

1. Sửa `monitor.sh` hoặc `Dockerfile` local
2. Upload lên server
3. Rebuild container: `docker compose up -d --build`

## 📄 License

Internal use only - Production server monitoring
