# 🚀 QUICK START - Production Deployment
# راهنمای سریع - استقرار Production

## For VPS at 45.156.186.85 with domain mosaporgold.ir

---

## 📋 Prerequisites Check

✅ DNS: mosaporgold.ir → 45.156.186.85  
✅ Ports 22, 80, 443 open  
✅ Docker installed  

---

## 🎯 Deploy in 5 Steps

### Step 1: Configure Environment
```bash
cp .env.example .env
nano .env
```

Change these values:
- `MYSQL_ROOT_PASSWORD` → strong password
- `MYSQL_PASSWORD` → strong password  
- `SESSION_SECRET` → generate with: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`

### Step 2: Start Everything
```bash
docker compose up -d
```

Wait 30 seconds for services to start.

### Step 3: Verify HTTP Access
```bash
curl http://localhost
# Or visit: http://mosaporgold.ir
```

### Step 4: Setup SSL (Important!)
```bash
# Edit email first
nano setup-ssl.sh  # Change EMAIL variable

# Run SSL setup
./setup-ssl.sh
```

### Step 5: Enable HTTPS
```bash
./enable-ssl.sh
```

---

## ✅ Done!

Access your application:
- **URL:** https://mosaporgold.ir
- **Login:** admin / admin123

**⚠️ Change admin password immediately!**

---

## 🔧 Useful Commands

```bash
# View logs
docker compose logs -f

# Restart
docker compose restart

# Stop
docker compose stop

# Start
docker compose start

# Interactive menu
./docker-manager.sh
```

---

## 📚 Full Documentation

- `PRODUCTION_READY.md` - Complete overview
- `PRODUCTION_DEPLOYMENT.md` - Detailed guide
- `README_DOCKER.md` - Docker commands

---

**That's it! Your system is live! 🎉**
