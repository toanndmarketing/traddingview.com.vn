# Configuration Setup Guide

## 🔐 Security Notice

**IMPORTANT:** Never commit real AWS credentials to Git!

## 📝 Setup Instructions

### 1. Copy the production config template

```bash
cp config.docker.json config.production.json
```

### 2. Edit `config.production.json` with your real credentials

Replace the following placeholders:

- `PLACEHOLDER_SES_USER` → Your AWS SES Access Key
- `PLACEHOLDER_SES_PASSWORD` → Your AWS SES Secret Key
- `PLACEHOLDER_S3_ACCESS_KEY` → Your AWS S3 Access Key
- `PLACEHOLDER_S3_SECRET_KEY` → Your AWS S3 Secret Key

### 3. Update docker-compose.yml to use production config

In `docker-compose.yml`, change the volume mount:

```yaml
volumes:
  - ./config.production.json:/var/lib/ghost/config.docker.json
```

## 📂 File Structure

- `config.docker.json` - Template with placeholders (committed to Git)
- `config.production.json` - Real credentials (ignored by Git)
- `.env.example` - Environment variables template
- `.gitignore` - Ensures sensitive files are not committed

## ⚠️ Important

The file `config.production.json` is automatically ignored by Git and will NOT be pushed to the repository.

