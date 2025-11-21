# Ghost CMS - TradingView Vietnam

This is a **Ghost CMS v5.58.0** deployment for TradingView Vietnam (tradingview.com.vn), running on custom infrastructure with AWS S3 storage and SES email.

## Architecture Overview

### Ghost Core Structure
- **Ghost Core**: Located in `versions/5.58.0/` (gitignored, installed via npm)
- **Content**: Lives in `content/` directory - themes, media, settings, logs
- **Entry Point**: `versions/5.58.0/index.js` started via PM2 or Docker
- **Storage**: AWS S3 adapter (`ghost-storage-adapter-s3`) for media files, not local filesystem

### Deployment Modes
Two distinct deployment approaches coexist:

1. **Docker** (Port 3005 via nginx container):
   - `docker-compose.yml` orchestrates Ghost + MySQL + Redis + Nginx
   - Config: `config.docker.json` (gitignored) with template `config.docker.example.json`
   - Database host: `mysql` (container name), port 3306
   - Ghost runs on port 3000 internally, exposed as 3005 via nginx container

2. **Bare Metal** (Port 2366/2368):
   - Direct Node.js execution via PM2 (`ecosystem.config.js`)
   - Config: `config.production.json` (gitignored) with template `config.example.json`
   - Database host: `127.0.0.1`, port 3306
   - Scripts: `scripts/deploy.sh`, `scripts/update.sh`, `scripts/setup.sh`

## Critical Configuration

### Config Files (NEVER commit actual configs)
- **All `config.*.json` files are gitignored** except `*.example.json` templates
- Database credentials, AWS keys, and secrets live in these configs
- Docker uses `config.docker.json` → copied to container as `config.production.json`
- Bare metal uses `config.production.json` directly

### Storage Configuration
```json
"storage": {
  "active": "s3",
  "s3": {
    "accessKeyId": "...",
    "secretAccessKey": "...",
    "region": "ap-southeast-1",
    "bucket": "...",
    "assetHost": "CDN_URL"
  }
}
```

**Key Point**: S3 adapter must be manually copied to `content/adapters/storage/s3/` from `node_modules/ghost-storage-adapter-s3` (see Dockerfile line 19 or scripts/setup.sh line 196)

### Database
- MySQL 8.0 with `utf8mb4_unicode_ci` collation
- Database name: `ghostproduction` (Docker) or `ghost_production` (bare metal)
- User: `ghost-814` (Docker) or custom (bare metal)

## Development Workflows

### First Time Setup
```bash
# Docker (recommended)
cp config.docker.example.json config.docker.json
# Edit config with real credentials
bash scripts/docker-setup.sh

# Bare Metal
bash scripts/deploy.sh  # All-in-one: setup + nginx + pm2
```

### Daily Development
```bash
# Update code from git
bash scripts/update.sh  # Auto: pull, backup, restart PM2

# Restart only
pm2 restart ghost-tradingview

# View logs
pm2 logs ghost-tradingview
# Docker: docker compose logs -f ghost
```

### Theme Development
- Active theme: `content/themes/tradingview-v6/` (Handlebars templates)
- Build assets: `cd content/themes/tradingview-v6 && yarn dev`
- Theme structure: `default.hbs` (layout), `home.hbs`, `post.hbs`, `page.hbs`, `partials/`
- Assets compiled from `assets/css/` to `assets/built/` via Gulp

### Database Operations
```bash
# Backup
mysqldump -u USER -p ghostproduction > backup.sql

# Import
mysql -u USER -p ghostproduction < backup.sql
```

## Project-Specific Conventions

### File Paths in Config
- **Docker**: `"contentPath": "/var/lib/ghost/content"` (container path)
- **Bare Metal**: `"contentPath": "/home/tradingview.com.vn/content"` (absolute host path)

### PM2 Configuration
- Process name: `ghost-tradingview`
- Script: `versions/5.58.0/index.js` (not a direct npm command)
- Max memory: 1GB restart threshold
- Logs: `content/logs/pm2-error.log`, `content/logs/pm2-out.log`

### Cloudflare Integration
- SSL/TLS: Flexible mode (Cloudflare handles HTTPS, nginx on port 80)
- Real IP: nginx.conf includes `set_real_ip_from` for Cloudflare IPs
- No local SSL certificates needed - Cloudflare proxies everything

### Version Pinning
- Ghost: **v5.58.0** (specific version in Dockerfile, scripts, ecosystem.config.js)
- Node.js: v18 LTS recommended (scripts check for v16.14+ or v18.12+)
- MySQL: 8.0 (docker-compose.yml specifies mysql:8.0)

## Common Tasks

### Adding/Changing Config Values
1. Edit `config.docker.json` or `config.production.json` (never commit)
2. Restart: `docker compose restart ghost` or `pm2 restart ghost-tradingview`
3. No need to rebuild unless changing Dockerfile

### Updating Ghost Core
```bash
# NOT via npm update - requires manual version change
# 1. Edit package.json, Dockerfile, ecosystem.config.js with new version
# 2. npm install ghost@NEW_VERSION
# 3. Copy S3 adapter again
# 4. Restart services
```

### Rollback Deployment
```bash
bash scripts/rollback.sh  # Creates backup, reverts to previous commit
```

### Access Admin Panel
- URL: `https://tradingview.com.vn/ghost`
- First setup creates owner account
- Database stores users, not config files

## Troubleshooting

### "Cannot find module" errors
- Check `versions/5.58.0/` exists (run `npm install ghost@5.58.0`)
- Verify S3 adapter copied to `content/adapters/storage/s3/`

### Database connection failures
- Docker: Ensure `host: "mysql"` matches service name in docker-compose.yml
- Bare metal: Verify MySQL running and credentials in config.production.json

### Images not loading
- Check S3 credentials in config
- Verify `storage.active` is `"s3"` not `"local"`
- S3 adapter must be in `content/adapters/storage/` (not just node_modules)

### Port conflicts
- Docker nginx: 3005 (external) → 80 (container) → 3000 (ghost)
- Bare metal: 2366 or 2368 (ghost) → 80 (nginx)
- Check `docker compose ps` or `pm2 list` for actual ports

## Key Files Reference

- `config.docker.example.json` / `config.example.json` - Configuration templates
- `ecosystem.config.example.js` - PM2 process configuration template
- `docker-compose.yml` - Docker orchestration (mysql, redis, nginx, ghost)
- `Dockerfile` - Ghost container with S3 adapter pre-installed
- `scripts/deploy.sh` - Fresh server deployment automation
- `scripts/update.sh` - Safe code updates with backup/rollback
- `content/themes/tradingview-v6/` - Active custom theme
- `content/settings/routes.yaml` - Custom URL routing (if exists)
