#!/bin/bash

echo "=== 5 Bài viết mới được Published gần đây ==="
docker exec ghost-mysql mysql -u ghost-814 -p'Tr@dingV!ew_User_2025!' ghostproduction -e "
SELECT id, title, status, published_at, updated_at 
FROM posts 
WHERE status='published' 
ORDER BY published_at DESC 
LIMIT 5;
"
