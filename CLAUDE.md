# traddingview.com.vn

## Context
- Đọc `.agents/identity/master-identity.md` trước mọi task.
- Tuân thủ `.agents/memory/constitution.md`.

## Rules
- Phản hồi bằng Tiếng Việt.
- No hard-coded URLs, Tokens, Keys — dùng ENV vars.
- Docker-First: chạy app trong container. KHÔNG chạy node/python trên host.
- KHÔNG chạy destructive commands mà không có user confirm.
- SDD flow: Specify → Plan → Tasks → Implement.

## Project Structure
- `.agents/identity/master-identity.md` — Project config (Source of Truth)
- `.agents/memory/constitution.md` — Project Law
- `.agents/specs/` — Feature specifications
- `.agents/skills/` — Project-specific automation skills
