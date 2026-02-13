#!/bin/bash
# Script: /root/auto_publish_scheduled.sh
# Tự động publish các bài viết scheduled bị quá hạn
# Chạy định kỳ bởi Cronjob

LOG_FILE="/var/log/ghost_auto_publish.log"

echo "[$(date)] Checking for stuck scheduled posts..." >> $LOG_FILE

# Đếm số bài quá hạn
COUNT=$(docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -N -e "SELECT COUNT(*) FROM posts WHERE status='scheduled' AND published_at <= NOW();")

if [ "$COUNT" -gt "0" ]; then
    echo "[$(date)] Found $COUNT stuck posts. Publishing..." >> $LOG_FILE
    
    # Update status
    docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e "
        UPDATE posts 
        SET status='published', updated_at=NOW() 
        WHERE status='scheduled' AND published_at <= NOW();
    "
    
    # Clear Nginx Cache (Optional - but recommended)
    echo "[$(date)] Clearing Nginx cache..." >> $LOG_FILE
    docker exec ghost-nginx rm -rf /var/cache/nginx/* 
    docker exec ghost-nginx nginx -s reload
    
    echo "[$(date)] Done." >> $LOG_FILE
else
    echo "[$(date)] No stuck posts found." >> $LOG_FILE
fi
