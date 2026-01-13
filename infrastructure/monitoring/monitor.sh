#!/bin/bash

# Production Server Monitor with Telegram Alerts
# Server: 57.129.45.30 (Ghost CMS Production)

set -e

# Telegram configuration (from environment variables)
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID}"
HOSTNAME=$(hostname)
SERVER_IP="57.129.45.30"

# Thresholds
DISK_THRESHOLD=80
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
MAX_CONTAINER_RESTARTS=3

# Send Telegram message
send_telegram() {
    local message="$1"
    local parse_mode="${2:-HTML}"
    
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="${message}" \
        -d parse_mode="${parse_mode}" \
        > /dev/null 2>&1
}

# Check disk space
check_disk_space() {
    local usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
        local message="🚨 <b>DISK SPACE ALERT</b>

📍 Server: <code>${SERVER_IP}</code> (${HOSTNAME})
💾 Disk Usage: <b>${usage}%</b>
⚠️ Threshold: ${DISK_THRESHOLD}%

$(df -h / | awk 'NR==2 {print "Free: " $4 " / Total: " $2}')

⏰ Time: $(date '+%Y-%m-%d %H:%M:%S')"
        
        send_telegram "$message"
    fi
}

# Check CPU and Memory
check_resources() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | cut -d. -f1)
    local mem_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        local message="🔥 <b>HIGH CPU USAGE</b>

📍 Server: <code>${SERVER_IP}</code>
🔥 CPU: <b>${cpu_usage}%</b>
⚠️ Threshold: ${CPU_THRESHOLD}%

Top Processes:
<code>$(ps aux --sort=-%cpu | head -6 | awk '{printf "%-20s %5s%%\n", $11, $3}')</code>

⏰ $(date '+%Y-%m-%d %H:%M:%S')"
        
        send_telegram "$message"
    fi
    
    if [ "$mem_usage" -gt "$MEMORY_THRESHOLD" ]; then
        local message="💾 <b>HIGH MEMORY USAGE</b>

📍 Server: <code>${SERVER_IP}</code>
💾 Memory: <b>${mem_usage}%</b>
⚠️ Threshold: ${MEMORY_THRESHOLD}%

$(free -h | grep Mem | awk '{print "Used: " $3 " / Total: " $2}')

⏰ $(date '+%Y-%m-%d %H:%M:%S')"
        
        send_telegram "$message"
    fi
}

# Check Docker containers
check_docker_containers() {
    # Check unhealthy containers
    local unhealthy=$(docker ps --filter health=unhealthy --format '{{.Names}}')
    
    if [ -n "$unhealthy" ]; then
        local message="🐳 <b>UNHEALTHY CONTAINER ALERT</b>

📍 Server: <code>${SERVER_IP}</code>
⚠️ Unhealthy Containers:
<code>${unhealthy}</code>

Status:
<code>$(docker ps --filter health=unhealthy --format 'table {{.Names}}\t{{.Status}}')</code>

⏰ $(date '+%Y-%m-%d %H:%M:%S')"
        
        send_telegram "$message"
    fi
    
    # Check stopped containers (that should be running)
    local stopped=$(docker ps -a --filter status=exited --format '{{.Names}}')
    
    if [ -n "$stopped" ]; then
        local message="⛔ <b>STOPPED CONTAINER ALERT</b>

📍 Server: <code>${SERVER_IP}</code>
⛔ Stopped Containers:
<code>${stopped}</code>

⏰ $(date '+%Y-%m-%d %H:%M:%S')"
        
        send_telegram "$message"
    fi
}

# Check SSH security (fail2ban)
check_ssh_security() {
    # Check banned IPs count (skip systemctl check in container)
    local banned_count=$(fail2ban-client status sshd 2>/dev/null | grep 'Currently banned' | awk '{print $4}')
    
    # If fail2ban-client fails, it means fail2ban is down
    if [ $? -ne 0 ]; then
        local message="🚨 <b>FAIL2BAN ERROR!</b>

📍 Server: <code>${SERVER_IP}</code>
⚠️ Cannot connect to fail2ban!

⏰ $(date '+%Y-%m-%d %H:%M:%S')"
        
        send_telegram "$message"
        return
    fi
    
    if [ -n "$banned_count" ] && [ "$banned_count" -gt 0 ]; then
        # Only alert if there are NEW bans (compare with last count)
        local last_count=0
        if [ -f /tmp/last_banned_count ]; then
            last_count=$(cat /tmp/last_banned_count)
        fi
        
        if [ "$banned_count" -gt "$last_count" ]; then
            local new_bans=$((banned_count - last_count))
            local banned_ips=$(fail2ban-client status sshd | grep 'Banned IP list' | cut -d: -f2 | xargs | head -c 200)
            
            local message="🔒 <b>SSH ATTACK DETECTED</b>

📍 Server: <code>${SERVER_IP}</code>
🚫 Currently Banned: <b>${banned_count}</b> IPs
🆕 New Bans: <b>${new_bans}</b>

Recent Banned IPs:
<code>${banned_ips}</code>

⏰ $(date '+%Y-%m-%d %H:%M:%S')"
            
            send_telegram "$message"
        fi
        
        echo "$banned_count" > /tmp/last_banned_count
    fi
}

# Main monitoring loop
main() {
    echo "[INFO] Starting monitor check at $(date)"
    
    check_disk_space
    check_resources
    check_docker_containers
    check_ssh_security
    
    echo "[INFO] Monitor check completed at $(date)"
}

# Run main function
main
