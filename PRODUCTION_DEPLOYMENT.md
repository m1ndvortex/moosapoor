# 🚀 Production Deployment Guide - VPS Setup
# راهنمای استقرار Production - VPS

## 📋 Server Information / اطلاعات سرور

- **Domain:** mosaporgold.ir
- **IP Address:** 45.156.186.85
- **Architecture:** Docker + Nginx + MySQL + Node.js

---

## 🎯 Complete One-Command Deployment

After DNS is configured and server is ready:

```bash
docker compose up -d
```

That's it! Everything will start automatically:
- ✅ MySQL Database (initialized with your data)
- ✅ Node.js Application
- ✅ Nginx Reverse Proxy
- ✅ Certbot for SSL renewal

---

## 📝 Pre-Deployment Checklist

### 1. DNS Configuration
Make sure your domain points to the server:

```bash
# Check DNS (run from your local machine or online tool)
dig mosaporgold.ir
nslookup mosaporgold.ir

# Should show: 45.156.186.85
```

**DNS Records Required:**
- A Record: `mosaporgold.ir` → `45.156.186.85`
- A Record: `www.mosaporgold.ir` → `45.156.186.85`

### 2. Server Preparation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Verify Docker
docker --version
docker compose version
```

### 3. Firewall Configuration

```bash
# Install UFW if not installed
sudo apt install ufw -y

# Configure firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# Check status
sudo ufw status
```

---

## 🚀 Deployment Steps

### Step 1: Upload Project to VPS

```bash
# Option A: Using SCP
scp -r /path/to/moosapourgold root@45.156.186.85:/var/www/

# Option B: Using Git
ssh root@45.156.186.85
cd /var/www
git clone YOUR_REPO_URL moosapourgold
cd moosapourgold
```

### Step 2: Configure Environment

```bash
# Go to project directory
cd /var/www/moosapourgold

# Create .env file
cp .env.example .env
nano .env
```

**Edit these values in `.env`:**
```env
# Production Server
DOMAIN=mosaporgold.ir
SERVER_IP=45.156.186.85
BASE_URL=https://mosaporgold.ir

# Database (CHANGE THESE!)
MYSQL_ROOT_PASSWORD=YOUR_STRONG_PASSWORD_HERE
MYSQL_PASSWORD=YOUR_DB_PASSWORD_HERE

# Session (GENERATE NEW!)
SESSION_SECRET=GENERATE_WITH_COMMAND_BELOW

# Environment
NODE_ENV=production
```

**Generate secure session secret:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Step 3: Launch Everything

```bash
# Start all services
docker compose up -d --build

# Check status
docker compose ps

# View logs
docker compose logs -f
```

**Expected Output:**
```
✅ goldshop_mysql   - healthy
✅ goldshop_app     - healthy
✅ goldshop_nginx   - healthy
✅ goldshop_certbot - running
```

### Step 4: Verify HTTP Access

```bash
# Test from server
curl http://localhost
curl http://mosaporgold.ir

# Test from browser
http://mosaporgold.ir
http://45.156.186.85
```

You should see the login page!

### Step 5: Setup SSL Certificate

```bash
# Edit the SSL setup script first
nano setup-ssl.sh
# Change EMAIL to your real email address

# Run SSL setup
./setup-ssl.sh
```

Follow the prompts. The script will:
1. Request certificate from Let's Encrypt
2. Verify domain ownership
3. Install certificate

### Step 6: Enable HTTPS

```bash
# After SSL certificate is obtained
./enable-ssl.sh

# This will:
# - Update Nginx config to use SSL
# - Enable HTTPS server block
# - Redirect HTTP to HTTPS
# - Restart Nginx
```

### Step 7: Verify HTTPS

```bash
# Test HTTPS
curl https://mosaporgold.ir

# Check SSL
openssl s_client -connect mosaporgold.ir:443 -servername mosaporgold.ir
```

Visit: **https://mosaporgold.ir** 🎉

---

## 🔐 Post-Deployment Security

### 1. Change Default Admin Password

```
1. Login to https://mosaporgold.ir
2. Username: admin
3. Password: admin123
4. Go to Settings → Change Password
5. Set a strong password
```

### 2. Secure MySQL Access

MySQL is NOT exposed externally. Access only through Docker:

```bash
# Access MySQL
docker compose exec mysql mysql -u root -p

# Or from app container
docker compose exec app sh
```

### 3. Setup Automated Backups

```bash
# Create backup script
nano /usr/local/bin/backup-goldshop.sh
```

Add this content:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/goldshop"
mkdir -p $BACKUP_DIR

# Backup database
docker compose exec -T mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} gold_shop_db > $BACKUP_DIR/db_$DATE.sql

# Backup uploads
docker run --rm -v goldshop_uploads:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/uploads_$DATE.tar.gz /data

# Keep last 30 days
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
```

```bash
# Make executable
chmod +x /usr/local/bin/backup-goldshop.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /usr/local/bin/backup-goldshop.sh
```

---

## 📊 Monitoring & Management

### Check Service Status

```bash
# Container status
docker compose ps

# Resource usage
docker stats

# Disk usage
docker system df
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app
docker compose logs -f nginx
docker compose logs -f mysql

# Last 100 lines
docker compose logs --tail=100 app
```

### Restart Services

```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart nginx
docker compose restart app

# Stop all
docker compose stop

# Start all
docker compose start
```

### Database Management

```bash
# Access MySQL shell
docker compose exec mysql mysql -u root -p

# Create database backup
docker compose exec mysql mysqldump -u root -p gold_shop_db > backup.sql

# Restore database
docker compose exec -T mysql mysql -u root -p gold_shop_db < backup.sql

# Check database size
docker compose exec mysql mysql -u root -p -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.tables WHERE table_schema='gold_shop_db';"
```

---

## 🔄 Updates & Maintenance

### Update Application Code

```bash
# Pull latest changes
cd /var/www/moosapourgold
git pull origin main

# Rebuild and restart
docker compose down
docker compose up -d --build

# Check logs
docker compose logs -f app
```

### Update Docker Images

```bash
# Pull latest images
docker compose pull

# Recreate containers
docker compose up -d --force-recreate
```

### SSL Certificate Renewal

Certbot runs automatically every 12 hours to check for renewal.

Manual renewal:
```bash
docker compose run --rm certbot renew
docker compose restart nginx
```

---

## 🛠 Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs

# Check specific container
docker compose logs mysql
docker compose logs app
docker compose logs nginx

# Remove and recreate
docker compose down
docker compose up -d --build
```

### Database Connection Failed

```bash
# Check MySQL is healthy
docker compose ps

# Access MySQL
docker compose exec mysql mysql -u root -p

# Check database exists
docker compose exec mysql mysql -u root -p -e "SHOW DATABASES;"
```

### Nginx 502 Bad Gateway

```bash
# Check app is running
docker compose ps app

# Check app logs
docker compose logs app

# Restart app
docker compose restart app
```

### SSL Certificate Issues

```bash
# Check certificate expiry
docker compose run --rm certbot certificates

# Renew manually
docker compose run --rm certbot renew --force-renewal

# Restart nginx
docker compose restart nginx
```

### Port Already in Use

```bash
# Check what's using port 80/443
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Stop conflicting service
sudo systemctl stop apache2  # if Apache is running
sudo systemctl stop nginx    # if system Nginx is running
```

### Out of Disk Space

```bash
# Check disk usage
df -h
docker system df

# Clean up Docker
docker system prune -a
docker volume prune

# Remove old backups
find /var/backups/goldshop -name "*.sql" -mtime +30 -delete
```

---

## 📱 Access Information

### Web Access
- **URL:** https://mosaporgold.ir
- **IP:** http://45.156.186.85 (redirects to HTTPS)
- **Default Login:** admin / admin123

### SSH Access
```bash
ssh root@45.156.186.85
cd /var/www/moosapourgold
```

### Database Access
```bash
# From VPS
docker compose exec mysql mysql -u root -p

# Cannot access from outside (for security)
```

---

## 🔒 Security Recommendations

1. ✅ Change default admin password
2. ✅ Use strong MySQL passwords
3. ✅ Keep system updated: `sudo apt update && sudo apt upgrade`
4. ✅ Regular backups (automated)
5. ✅ Monitor logs: `docker compose logs -f`
6. ✅ Use SSH keys instead of password
7. ✅ Enable fail2ban for SSH protection
8. ✅ Keep Docker updated

---

## 📞 Quick Commands Reference

```bash
# Start everything
docker compose up -d

# Stop everything
docker compose down

# Restart
docker compose restart

# View logs
docker compose logs -f

# Check status
docker compose ps

# Backup database
docker compose exec mysql mysqldump -u root -p gold_shop_db > backup.sql

# Update app
git pull && docker compose up -d --build
```

---

## ✅ Deployment Checklist

- [ ] DNS configured (mosaporgold.ir → 45.156.186.85)
- [ ] Docker installed on VPS
- [ ] Firewall configured (ports 22, 80, 443)
- [ ] Project uploaded to /var/www/moosapourgold
- [ ] .env file created and configured
- [ ] Passwords changed from defaults
- [ ] `docker compose up -d` executed successfully
- [ ] HTTP access working (http://mosaporgold.ir)
- [ ] SSL certificate obtained (./setup-ssl.sh)
- [ ] HTTPS enabled (./enable-ssl.sh)
- [ ] HTTPS access working (https://mosaporgold.ir)
- [ ] Admin password changed in app
- [ ] Automated backups configured
- [ ] Monitoring setup verified

---

## 🎉 Success!

Your Gold Shop Management System is now live at:
**https://mosaporgold.ir**

Everything runs with a single command: `docker compose up -d`

**موفق باشید! 🚀**
