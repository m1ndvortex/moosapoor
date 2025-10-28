# 🔄 VPS Auto-Restart Configuration Guide

## ✅ Current Status: ALREADY CONFIGURED!

Your Docker setup is **already configured** to automatically restart after VPS reboot! 

All services have `restart: unless-stopped` policy:
- ✅ MySQL Database
- ✅ Node.js Application
- ✅ Nginx Reverse Proxy
- ✅ Certbot SSL

---

## 🚀 How It Works

### What `restart: unless-stopped` Means:

1. **Container crashes** → Docker automatically restarts it
2. **VPS reboots** → Docker automatically starts containers
3. **Manual stop** (`docker compose down`) → Containers stay stopped (won't auto-start)

### Other Restart Policies:

- `no`: Never restart (default)
- `always`: Always restart, even after manual stop
- `on-failure`: Only restart if container exits with error
- `unless-stopped`: Restart unless manually stopped (BEST for production)

---

## 🔧 VPS Setup Requirements

For Docker containers to auto-start after VPS reboot, you need:

### 1️⃣ Enable Docker Service to Start on Boot

On your VPS, run these commands **once**:

```bash
# Enable Docker to start on boot
sudo systemctl enable docker

# Enable Docker Compose plugin (if using Docker Compose V2)
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Verify status
sudo systemctl status docker
```

Expected output:
```
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; ...)
   Active: active (running) since ...
```

### 2️⃣ Test Auto-Restart

```bash
# Method 1: Reboot VPS
sudo reboot

# After reboot, check containers (wait 2-3 minutes)
docker ps

# You should see all 4 containers running:
# - goldshop_mysql
# - goldshop_app
# - goldshop_nginx
# - goldshop_certbot
```

```bash
# Method 2: Restart Docker service
sudo systemctl restart docker

# Check containers
docker ps
```

---

## 📋 Deployment Checklist on VPS

When you first deploy to VPS (45.156.186.85), follow these steps:

### Step 1: Initial Setup

```bash
# SSH into VPS
ssh root@45.156.186.85

# Install Docker (if not installed)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Enable Docker on boot
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker is running
docker --version
docker compose version
```

### Step 2: Deploy Application

```bash
# Clone repository
cd /opt
git clone https://github.com/m1ndvortex/moosapoor.git
cd moosapoor

# Copy and configure environment
cp .env.production .env
nano .env

# Update these values:
# - CERTBOT_EMAIL=your-email@example.com
# - SESSION_SECRET=<generate-with-openssl>
# - DB_PASSWORD=<strong-password>

# Start containers
docker compose up -d

# Check logs
docker compose logs -f
```

### Step 3: Verify Auto-Restart

```bash
# Test 1: Stop a container manually
docker stop goldshop_app

# Wait 10 seconds, check if it restarted
docker ps | grep goldshop_app
# Should be running again!

# Test 2: Reboot VPS
sudo reboot

# After reboot (SSH back in)
ssh root@45.156.186.85
docker ps
# All containers should be running!
```

---

## 🛡️ Additional Reliability Features

### 1. Health Checks (Already Configured)

Your containers have health checks:

```yaml
# MySQL health check
healthcheck:
  test: ["CMD", "mysqladmin", "ping"]
  interval: 10s
  retries: 5

# App health check  
healthcheck:
  test: ["CMD", "node", "-e", "require('http').get(...)"]
  interval: 30s
  retries: 3

# Nginx health check
healthcheck:
  test: ["CMD", "wget", "--spider", "http://localhost/health"]
  interval: 30s
  retries: 3
```

**Benefits:**
- Docker knows if containers are truly healthy
- Dependencies wait for services to be ready
- Automatic restart if health checks fail

### 2. Monitoring Auto-Restart

```bash
# View restart count
docker ps --format "table {{.Names}}\t{{.Status}}"

# Example output:
# NAMES             STATUS
# goldshop_nginx    Up 2 hours
# goldshop_app      Up 2 hours (healthy)
# goldshop_mysql    Up 2 hours (healthy)

# If you see "Restarting", check logs:
docker logs goldshop_app --tail 100
```

### 3. Set Up System Monitoring (Optional)

Create a cron job to check containers:

```bash
# Edit crontab
crontab -e

# Add this line (checks every 5 minutes)
*/5 * * * * /usr/local/bin/docker-health-check.sh >> /var/log/docker-health.log 2>&1
```

Create the health check script:

```bash
cat > /usr/local/bin/docker-health-check.sh << 'EOF'
#!/bin/bash

CONTAINERS="goldshop_mysql goldshop_app goldshop_nginx goldshop_certbot"

for container in $CONTAINERS; do
    if [ ! $(docker ps -q -f name=$container) ]; then
        echo "[$(date)] WARNING: $container is not running!"
        echo "[$(date)] Attempting to start $container..."
        cd /opt/moosapoor
        docker compose up -d $container
    fi
done
EOF

chmod +x /usr/local/bin/docker-health-check.sh
```

---

## 🔍 Troubleshooting Auto-Restart

### Problem: Containers don't start after reboot

**Solution 1: Check Docker service**
```bash
sudo systemctl status docker

# If not running:
sudo systemctl start docker
sudo systemctl enable docker
```

**Solution 2: Check container logs**
```bash
docker logs goldshop_app --tail 50
docker logs goldshop_mysql --tail 50
```

**Solution 3: Manually start containers**
```bash
cd /opt/moosapoor
docker compose up -d
```

### Problem: MySQL fails to start

**Check disk space:**
```bash
df -h
```

**Check MySQL logs:**
```bash
docker logs goldshop_mysql --tail 100
```

**Solution:**
```bash
# If MySQL data corrupted, restore from backup
docker compose down
docker volume rm goldshop_mysql_data
docker compose up -d
```

### Problem: App fails but MySQL is running

**Check environment variables:**
```bash
docker exec goldshop_app env | grep DB_
```

**Restart app only:**
```bash
docker compose restart app
```

---

## 📊 Monitoring Commands

### Check all containers status:
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Check restart count:
```bash
docker inspect goldshop_app --format='{{.RestartCount}}'
```

### Check uptime:
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Check resource usage:
```bash
docker stats --no-stream
```

### View recent restarts:
```bash
docker events --since '24h' --filter 'event=restart'
```

---

## 🎯 Summary

✅ **Your setup is READY for auto-restart!**

**What happens when VPS reboots:**

1. VPS starts → Docker service starts (enabled on boot)
2. Docker reads `docker-compose.yml`
3. Containers start in order:
   - MySQL starts first
   - App waits for MySQL to be healthy
   - Nginx waits for App to be healthy
   - Certbot starts
4. All services are available at **https://mosaporgold.ir**

**No manual intervention needed!** 🎉

---

## 🚨 Important Notes

### DO NOT run these (will prevent auto-start):
```bash
# ❌ This removes volumes and restart policies
docker compose down -v

# ❌ This stops Docker service
sudo systemctl disable docker
```

### DO run these safely:
```bash
# ✅ Stop containers but keep restart policies
docker compose stop

# ✅ Restart containers
docker compose restart

# ✅ Update and restart
docker compose up -d --build

# ✅ View logs
docker compose logs -f
```

---

## 📞 Support Checklist

After VPS reboot, if containers don't start:

1. ✅ Check Docker service: `sudo systemctl status docker`
2. ✅ Check Docker is enabled: `sudo systemctl is-enabled docker`
3. ✅ Check containers exist: `docker ps -a`
4. ✅ Check restart policy: `docker inspect goldshop_app | grep -A 3 RestartPolicy`
5. ✅ Check logs: `docker compose logs`
6. ✅ Manual start: `cd /opt/moosapoor && docker compose up -d`

---

## 🎉 Testing Scenario

```bash
# Current state: All running
docker ps

# Simulate VPS reboot
sudo reboot

# Wait 2-3 minutes for VPS to come back online

# SSH back in
ssh root@45.156.186.85

# Check containers (should all be running)
docker ps

# Check website
curl -I https://mosaporgold.ir

# Expected: HTTP/2 200
```

**Your Gold Shop Management System will be back online automatically! 🏆**
