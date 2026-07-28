# 🧠 Master Identity — traddingview.com.vn

> **Generated**: 2026-07-25 | **Type**: Full-stack (Web + API) | **wb-agent**: v2.0

## Tên Dự Án
traddingview.com.vn

## Loại Dự Án
Full-stack (Web + API)

## Tech Stack
<!-- Liệt kê tech stack chính: Next.js 15, Prisma, PostgreSQL, Docker... -->

## Port Registry
<!-- Quy định ports cho project này -->
| Service | Port | Ghi chú |
|---------|------|---------|
| Frontend | | |
| Admin | | |
| API | | |
| Database | | |

## Server / Deploy
<!-- IP, SSH port, deploy path -->
- **Server**: 
- **Deploy Path**: 
- **SSH**: 

## Credentials Mapping
<!-- Chỉ ghi KEY NAME, không ghi giá trị thật -->
- `DATABASE_URL`: PostgreSQL connection string
- `NEXT_PUBLIC_API_URL`: API base URL

## 🔬 Auto-Detected Context
- **Language**: JavaScript
- **Tech Stack**: Docker
- **Package Manager**: npm
- **Docker Services**: mysql, redis, nginx, cache-purge, mailpit, ghost, mysql_data, redis_data, nginx_cache
- **Port Mapping**:
  - nginx: 1:3005
  - cache-purge: 9000:9000
  - mailpit: 1:8025
  - mailpit: 1:1025
- **ENV Variables**: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, REDIS_HOST, REDIS_PORT, REDIS_TTL, GHOST_NODE_ENV, S3_ACCESS_KEY_ID, S3_SECRET_ACCESS_KEY
- **Structure**:
  - 📄 .env.example
  - 📄 Dockerfile
  - 📄 README.md
  - 📄 TEMPLATE_DIEM_TIN_SIMPLE.html
  - 📄 config.docker.json
  - 📄 config.example.json
  - 📁 content/ (10 items)
  - 📄 docker-compose.dev.yml
  - 📄 docker-compose.yml
  - 📄 ecosystem.config.example.js
  - 📁 infrastructure/ (2 items)
  - 📄 jail.local
  - 📄 nginx.conf
  - 📄 package.json
  - 📄 query.sql

---
*Source of truth cho toàn bộ cấu hình dự án. AI agent BẮT BUỘC đọc file này trước khi làm bất kỳ task nào.*
