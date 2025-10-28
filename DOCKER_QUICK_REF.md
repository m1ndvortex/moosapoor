# 🚀 Docker Quick Reference
# راهنمای سریع Docker

## ⚡ Quick Start / شروع سریع

```bash
# Method 1: Use helper script (easiest)
./docker-start.sh

# Method 2: Manual
cp .env.example .env
docker compose up -d --build
```

## 🌐 Access / دسترسی

- **Web:** http://localhost:3000
- **Login:** admin / admin123
- **MySQL:** localhost:3307

## 📋 Common Commands / دستورات رایج

```bash
# Interactive menu
./docker-manager.sh

# Start
docker compose up -d

# Stop
docker compose stop

# Logs
docker compose logs -f

# Status
docker compose ps

# Restart
docker compose restart

# Remove all
docker compose down -v
```

## 💾 Backup / پشتیبان

```bash
# Database
docker compose exec mysql mysqldump -u root -p gold_shop_db > backup.sql

# Restore
docker compose exec -T mysql mysql -u root -p gold_shop_db < backup.sql
```

## 🔧 Troubleshooting / عیب‌یابی

```bash
# Check logs
docker compose logs app
docker compose logs mysql

# Restart services
docker compose restart

# Rebuild
docker compose down
docker compose up -d --build

# Clean start
docker compose down -v
docker system prune -a
docker compose up -d --build
```

## 📁 Files Created / فایل‌های ایجاد شده

- `Dockerfile` - App image definition
- `docker-compose.yml` - Services configuration
- `.dockerignore` - Excluded files
- `.env.example` - Environment template
- `docker-start.sh` - Quick start script
- `docker-manager.sh` - Management menu
- `README_DOCKER.md` - Full documentation
- `DOCKER_SETUP_COMPLETE.md` - Setup summary
- `docker/mysql/custom.cnf` - MySQL config

## ⚙️ Environment Variables / متغیرهای محیطی

Edit `.env` file:
```env
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_PASSWORD=your_db_password
SESSION_SECRET=generate_random_string
APP_PORT=3000
MYSQL_PORT=3307
```

## 🛡️ Security Checklist / چک‌لیست امنیتی

- [ ] Change MYSQL_ROOT_PASSWORD
- [ ] Change MYSQL_PASSWORD
- [ ] Generate random SESSION_SECRET
- [ ] Change admin password in app
- [ ] Don't commit .env to Git
- [ ] Use HTTPS in production
- [ ] Setup firewall rules

## 📦 Docker Volumes / فضای ذخیره

- `goldshop_mysql_data` - Database
- `goldshop_uploads` - Images
- `goldshop_backups` - Backups
- `goldshop_temp_uploads` - Temp files

## 🌍 VPS Deployment / استقرار VPS

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Copy project
scp -r project/ user@vps:/var/www/goldshop

# Deploy
cd /var/www/goldshop
./docker-start.sh

# Enable firewall
sudo ufw allow 3000/tcp
```

## 📞 Help / کمک

Read: `README_DOCKER.md` for detailed guide

**موفق باشید! 🎉**
