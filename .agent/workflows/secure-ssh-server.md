---
description: Bảo mật SSH Server - Tắt Password Login & Tăng cường Fail2ban
---

# Workflow: Bảo mật SSH Server (57.129.45.30)

## Mục tiêu

- ✅ Tắt password authentication cho tất cả users
- ✅ Chỉ cho phép SSH key authentication
- ✅ Tăng cường fail2ban configuration
- ✅ Thêm monitoring và alerting

## ⚠️ QUAN TRỌNG: Kiểm tra trước khi thực hiện

### 1. Xác nhận SSH Key hoạt động

```bash
# Test SSH key connection
ssh root@57.129.45.30 "echo 'SSH Key works!'"
```

**DỪNG LẠI nếu lệnh trên KHÔNG hoạt động!** Bạn sẽ bị khóa ngoài server.

## Bước thực hiện

### 2. Backup cấu hình SSH hiện tại

```bash
ssh root@57.129.45.30 "cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)"
```

### 3. Cấu hình SSH - Tắt Password Authentication

```bash
ssh root@57.129.45.30 "cat > /etc/ssh/sshd_config.d/99-security-hardening.conf << 'EOF'
# Security Hardening - Disable Password Authentication
# Created: $(date)

# Disable password authentication
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no

# Only allow public key authentication
PubkeyAuthentication yes

# Disable root login with password (allow with key only)
PermitRootLogin prohibit-password

# Additional security settings
MaxAuthTries 3
LoginGraceTime 30s
ClientAliveInterval 300
ClientAliveCountMax 2

# Disable unused authentication methods
HostbasedAuthentication no
IgnoreRhosts yes
PermitUserEnvironment no
EOF
"
```

### 4. Kiểm tra cấu hình SSH syntax

```bash
ssh root@57.129.45.30 "sshd -t"
```

**DỪNG LẠI nếu có lỗi!** Sửa lỗi trước khi restart.

### 5. Restart SSH service (AN TOÀN)

```bash
# Restart SSH trong background để tránh bị disconnect
ssh root@57.129.45.30 "nohup bash -c 'sleep 2 && systemctl restart sshd' > /dev/null 2>&1 &"
```

### 6. Test kết nối SSH ngay lập tức (trong 10 giây)

```bash
# Đợi 3 giây cho SSH restart
sleep 3

# Test connection
ssh root@57.129.45.30 "echo 'SSH restart successful!'"
```

**NẾU BƯỚC NÀY THẤT BẠI:**

- Bạn có 2-3 phút để SSH vào bằng password (nếu session cũ còn)
- Hoặc cần truy cập console từ VPS provider để rollback

### 7. Tăng cường Fail2ban cho SSH

```bash
ssh root@57.129.45.30 "cat > /etc/fail2ban/jail.d/sshd-custom.conf << 'EOF'
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 600
bantime = 3600
ignoreip = 127.0.0.1/8 ::1

# Ban for 1 hour after 3 failed attempts in 10 minutes
# Increase ban time for repeat offenders
bantime.increment = true
bantime.factor = 2
bantime.maxtime = 86400
EOF
"
```

### 8. Restart Fail2ban

```bash
ssh root@57.129.45.30 "systemctl restart fail2ban"
```

### 9. Kiểm tra trạng thái Fail2ban

```bash
ssh root@57.129.45.30 "fail2ban-client status sshd"
```

### 10. Kiểm tra logs SSH gần đây

```bash
ssh root@57.129.45.30 "journalctl -u sshd -n 50 --no-pager"
```

### 11. Xem danh sách IP bị ban

```bash
ssh root@57.129.45.30 "fail2ban-client status sshd | grep 'Banned IP'"
```

## Verification Checklist

- [ ] SSH key authentication hoạt động
- [ ] Password authentication đã bị tắt
- [ ] Fail2ban đang chạy và ban IP
- [ ] Có thể SSH vào server bình thường
- [ ] Logs không có lỗi bất thường

## Rollback (Nếu cần)

```bash
# Restore backup config
ssh root@57.129.45.30 "cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config && systemctl restart sshd"

# Hoặc xóa file hardening
ssh root@57.129.45.30 "rm /etc/ssh/sshd_config.d/99-security-hardening.conf && systemctl restart sshd"
```

## Monitoring sau khi áp dụng

### Xem failed login attempts

```bash
ssh root@57.129.45.30 "grep 'Failed password' /var/log/auth.log | tail -20"
```

### Xem successful logins

```bash
ssh root@57.129.45.30 "grep 'Accepted publickey' /var/log/auth.log | tail -20"
```

### Kiểm tra tổng số IP bị ban

```bash
ssh root@57.129.45.30 "fail2ban-client status sshd"
```
