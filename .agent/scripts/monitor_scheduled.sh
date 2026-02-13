#!/bin/bash

echo "=== Kiểm tra các bài viết Scheduled ==="
# Lấy danh sách các bài đang scheduled, sắp xếp theo thời gian publish cũ nhất trước
docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e "
SELECT id, title, status, published_at, created_at, 
       TIMESTAMPDIFF(MINUTE, published_at, NOW()) as minutes_overdue 
FROM posts 
WHERE status='scheduled' 
ORDER BY published_at ASC;
"

echo ""
echo "=== Kiểm tra thời gian hiện tại ==="
# Server time
echo "Server Plan Time: $(date)"
# DB time
echo "DB Time:"
docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e "SELECT NOW();"
