# 📜 Constitution — traddingview.com.vn

> Source of Law cho dự án này. Mọi agent và workflow BẮT BUỘC tuân thủ.

## Core Principles
- **Spec trước Code**: WHAT trước, HOW sau.
- **No Hard-code**: URLs, Tokens, Keys phải dùng ENV vars.
- **Incremental**: Build incrementally, không bao giờ bắt đầu lại từ đầu.

## Tech Stack
<!-- Khai báo stack chính xác tại đây -->
- Framework: 
- Language: 
- Database: 
- ORM: 

## Docker & Infrastructure
- Docker-First: Mọi service chạy trong container.
- Port lấy từ biến môi trường (.env), KHÔNG hard-code.
- Production dùng `docker-compose.prod.yml` với multi-stage builds.
- Bind ports tới `127.0.0.1` (localhost only) cho proxied services.

## Coding Standards
- TypeScript strict mode (nếu dùng TS).
- Functional programming style.
- Không `any` type, không placeholder code.
- File naming: kebab-case.

## Non-Negotiables
- Mọi destructive command (rm -rf, DROP TABLE, docker down -v) phải có user confirm.
- Backup database trước khi migration.
- Không import thư viện chưa được khai báo trong dependencies.
