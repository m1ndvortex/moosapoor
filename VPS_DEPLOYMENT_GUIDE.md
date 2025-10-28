# 🚀 VPS Production Deployment Guide
## Gold Shop Management System - mosaporgold.ir

### 📋 Server Information
- **Domain:** mosaporgold.ir
- **IP Address:** 45.156.186.85
- **OS:** Ubuntu/Debian (recommended)

---

## 🛠️ Prerequisites on VPS

### 1. Install Docker & Docker Compose
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Verify installation
docker --version
docker compose version
```

### 2. Install Git
```bash
sudo apt install git -y
```

---

## 📦 Deployment Steps

### Step 1: Clone Your Repository
```bash
# Navigate to your projects directory
cd /home/your-username/

# Clone your repository
git clone https://github.com/m1ndvortex/moosapoor.git
cd moosapoor
```

### Step 2: Configure Environment
```bash
# Copy production environment file
cp .env.production .env

# Edit the .env file with your settings
nano .env
```

**⚠️ IMPORTANT: Update these values in .env:**
1. `CERTBOT_EMAIL` - Your actual email for SSL certificates
2. `SESSION_SECRET` - Generate a random 64-character string:
   ```bash
   openssl rand -base64 48
   ```
3. `DB_PASSWORD` - Change to a strong password

### Step 3: Configure DNS
Make sure your domain points to your VPS:
```
A Record: mosaporgold.ir → 45.156.186.85
A Record: www.mosaporgold.ir → 45.156.186.85
```

Verify DNS propagation:
```bash
ping mosaporgold.ir
```

### Step 4: Start the Application (HTTP Only - First Time)
```bash
# Start with HTTP only (for SSL certificate generation)
docker compose up -d
```

Wait 2-3 minutes for all containers to start and database to initialize.

### Step 5: Check Application Status
```bash
# Check if containers are running
docker compose ps

# Check logs
docker compose logs -f app

# Test the application
curl http://mosaporgold.ir
```

### Step 6: Setup SSL Certificate
```bash
# Run SSL setup script
chmod +x setup-ssl.sh
./setup-ssl.sh

# This will:
# 1. Request Let's Encrypt SSL certificate
# 2. Configure automatic renewal
```

### Step 7: Enable HTTPS
```bash
# Enable HTTPS in nginx
chmod +x enable-ssl.sh
./enable-ssl.sh

# Restart nginx to apply changes
docker compose restart nginx
```

### Step 8: Verify HTTPS
```bash
# Test HTTPS
curl https://mosaporgold.ir

# Visit in browser
# https://mosaporgold.ir
```

---

## 🔐 Default Login Credentials

**Username:** `admin`  
**Password:** `admin123`

**⚠️ CHANGE IMMEDIATELY AFTER FIRST LOGIN!**

---

## 🎯 Quick Management Commands

### Start Application
```bash
cd /home/your-username/moosapoor
docker compose up -d
```

### Stop Application
```bash
docker compose down
```

### View Logs
```bash
# All containers
docker compose logs -f

# Specific container
docker compose logs -f app
docker compose logs -f mysql
docker compose logs -f nginx
```

### Restart Services
```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart app
docker compose restart nginx
```

### Update Application
```bash
# Pull latest changes
git pull

# Rebuild and restart
docker compose down
docker compose up -d --build
```

### Backup Database
```bash
# Manual backup
docker exec goldshop_mysql mysqldump -u goldshop_user -p'GoldShop2024!SecurePass#789' gold_shop_db > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
# Restore from backup
docker exec -i goldshop_mysql mysql -u goldshop_user -p'GoldShop2024!SecurePass#789' gold_shop_db < backup_20241028.sql
```

---

## 🔥 Firewall Configuration

```bash
# Allow SSH (if not already allowed)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

---

## 📊 Monitoring

### Check System Resources
```bash
# Disk usage
df -h

# Memory usage
free -h

# Docker containers resource usage
docker stats
```

### Check Container Health
```bash
docker compose ps
```

---

## 🔄 Automatic Updates & Backups

### Setup Automatic Database Backups
```bash
# Create backup script
sudo nano /usr/local/bin/backup-goldshop.sh
```

Add this content:
```bash
#!/bin/bash
BACKUP_DIR="/home/your-username/moosapoor/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

docker exec goldshop_mysql mysqldump -u goldshop_user -p'GoldShop2024!SecurePass#789' gold_shop_db > $BACKUP_DIR/backup_$DATE.sql

# Keep only last 30 days of backups
find $BACKUP_DIR -name "backup_*.sql" -mtime +30 -delete

echo "Backup completed: backup_$DATE.sql"
```

Make it executable and schedule:
```bash
sudo chmod +x /usr/local/bin/backup-goldshop.sh

# Add to crontab (runs daily at 2 AM)
crontab -e
```

Add this line:
```
0 2 * * * /usr/local/bin/backup-goldshop.sh >> /var/log/goldshop-backup.log 2>&1
```

---

## 🆘 Troubleshooting

### Application won't start
```bash
# Check logs
docker compose logs -f

# Check if ports are in use
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Remove and restart
docker compose down
docker compose up -d --build
```

### Database connection issues
```bash
# Check MySQL container
docker compose logs mysql

# Restart MySQL
docker compose restart mysql

# Wait 30 seconds and check again
docker compose ps
```

### SSL Certificate issues
```bash
# Check certbot logs
docker compose logs certbot

# Manually renew certificate
docker compose run --rm certbot renew

# Check nginx logs
docker compose logs nginx
```

### Can't access from domain
```bash
# Check DNS
nslookup mosaporgold.ir

# Check nginx is listening
docker compose ps nginx

# Check firewall
sudo ufw status
```

---

## 📱 Mobile Access

The application is responsive and works on:
- ✅ Desktop browsers
- ✅ Mobile phones
- ✅ Tablets

Access from anywhere: **https://mosaporgold.ir**

---

## 🔒 Security Best Practices

1. ✅ Change default admin password immediately
2. ✅ Use strong database passwords
3. ✅ Keep SESSION_SECRET secure and unique
4. ✅ Regularly update the application: `git pull && docker compose up -d --build`
5. ✅ Monitor logs regularly: `docker compose logs -f`
6. ✅ Keep backups in a separate location
7. ✅ Enable firewall (ufw)
8. ✅ Keep SSH key-based authentication only (disable password auth)

---

## 📞 Support

For issues or questions:
- Check logs: `docker compose logs -f`
- Review this guide carefully
- Check Docker status: `docker compose ps`

---

## ✅ Deployment Checklist

- [ ] Docker & Docker Compose installed
- [ ] Repository cloned
- [ ] .env file configured (email, session secret, passwords)
- [ ] DNS configured (A records pointing to VPS)
- [ ] Firewall configured (ports 80, 443 open)
- [ ] Application started with `docker compose up -d`
- [ ] SSL certificate obtained with `./setup-ssl.sh`
- [ ] HTTPS enabled with `./enable-ssl.sh`
- [ ] Admin password changed
- [ ] Automatic backups configured
- [ ] Application accessible at https://mosaporgold.ir

---

**🎉 Congratulations! Your Gold Shop Management System is now live!**

Access your application at: **https://mosaporgold.ir**
