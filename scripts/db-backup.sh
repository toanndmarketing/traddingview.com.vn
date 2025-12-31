#!/bin/bash

# Configuration
BACKUP_DIR="/home/tradingview.com.vn/backups"
MYSQL_USER="root"
MYSQL_PASSWORD="Tr@dingV!ew_Root_2025!"
DATABASE="ghostproduction"
RETENTION_DAYS=2

# Creates directory if not exists
mkdir -p "$BACKUP_DIR"

# Timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="$BACKUP_DIR/db_backup_$TIMESTAMP.sql.gz"

# Perform Backup
echo "[$(date)] Starting backup..."
docker exec ghost-mysql mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h 127.0.0.1 --no-tablespaces --single-transaction "$DATABASE" | gzip > "$FILENAME"

# Check if backup succeeded
if [ -f "$FILENAME" ] && [ -s "$FILENAME" ]; then
    echo "[$(date)] Backup success: $FILENAME ($(du -h "$FILENAME" | cut -f1))"
    
    # Cleanup old backups (older than 2 days = 48 hours)
    echo "[$(date)] Cleaning up old backups..."
    find "$BACKUP_DIR" -name "db_backup_*.sql.gz" -mmin +2880 -delete
    
    # Alternative: Keep exactly last 48 backups
    # ls -tp "$BACKUP_DIR"/db_backup_*.sql.gz | grep -v '/$' | tail -n +49 | xargs -I {} rm -- {}
else
    echo "[$(date)] Backup FAILED!"
    # Remove empty file if exists
    [ -f "$FILENAME" ] && rm "$FILENAME"
    exit 1
fi
