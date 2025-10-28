# 🔄 Data Management & Persistence Guide

## 📦 Docker Volumes Status

Your application has **5 persistent volumes** configured:

1. ✅ **goldshop_mysql_data** - MySQL database
2. ✅ **goldshop_uploads** - User uploaded files
3. ✅ **goldshop_backups** - Database backups
4. ✅ **goldshop_temp_uploads** - Temporary files
5. ✅ **goldshop_certbot_data** - SSL certificates

**All your data is persistent and survives container restarts/rebuilds!**

---

## 🎯 Deployment Scenarios

### Scenario 1: Fresh Start on VPS (No Existing Data)

This is for your VPS deployment at **mosaporgold.ir**.

#### What Happens:
- ✅ MySQL starts with empty volume
- ✅ `last.sql` automatically initializes database
- ✅ You get a clean system with test data from `last.sql`
- ✅ All volumes are created fresh

#### Commands:
```bash
# On VPS (first time deployment)
git clone https://github.com/m1ndvortex/moosapoor.git
cd moosapoor
cp .env.production .env
nano .env  # Configure

# Start fresh
docker compose up -d

# That's it! Database is auto-initialized from last.sql
```

---

### Scenario 2: You Want to Start Fresh (Clean All Data)

This removes ALL existing data and starts completely fresh.

#### ⚠️ WARNING: This deletes EVERYTHING!

```bash
# Stop all containers
docker compose down

# Remove ALL volumes (deletes all data)
docker volume rm goldshop_mysql_data
docker volume rm goldshop_uploads
docker volume rm goldshop_backups
docker volume rm goldshop_temp_uploads
docker volume rm goldshop_certbot_data
docker volume rm goldshop_certbot_www

# OR remove all at once
docker volume rm $(docker volume ls -q | grep goldshop)

# Start fresh (database will auto-initialize from last.sql)
docker compose up -d
```

---

### Scenario 3: Keep Data, Just Restart Containers

This preserves all your data.

```bash
# Restart without losing data
docker compose restart

# OR rebuild application code but keep data
docker compose down
docker compose up -d --build
```

---

### Scenario 4: Backup Data Before Fresh Start

Always backup before cleaning!

```bash
# 1. Backup database
docker exec goldshop_mysql mysqldump -u goldshop_user -p'GoldShop2024!SecurePass#789' gold_shop_db > backup_$(date +%Y%m%d).sql

# 2. Backup uploads folder
docker cp goldshop_app:/usr/src/app/public/uploads ./uploads_backup_$(date +%Y%m%d)

# 3. Now you can safely clean and restart
docker compose down
docker volume rm goldshop_mysql_data goldshop_uploads
docker compose up -d
```

---

## 🔍 Check Current Data Status

### Check if volumes exist and their size:
```bash
# List all volumes
docker volume ls | grep goldshop

# Inspect volume details
docker volume inspect goldshop_mysql_data

# Check volume size
docker system df -v
```

### Check if database has data:
```bash
# Connect to MySQL
docker exec -it goldshop_mysql mysql -u goldshop_user -p'GoldShop2024!SecurePass#789' gold_shop_db

# Inside MySQL:
SHOW TABLES;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM customer_gold_transactions;
EXIT;
```

---

## 📍 Volume Locations on Host

Docker stores volumes in:
```
/var/lib/docker/volumes/goldshop_mysql_data/_data
/var/lib/docker/volumes/goldshop_uploads/_data
/var/lib/docker/volumes/goldshop_backups/_data
```

You can check these with:
```bash
sudo ls -lah /var/lib/docker/volumes/ | grep goldshop
```

---

## 🚀 Recommended: VPS Deployment Strategy

### For Your VPS (45.156.186.85):

**Option A: Start with Your Test Data (Recommended for Testing)**
```bash
# Just deploy as-is
# last.sql will initialize database with your current test data
git clone ...
docker compose up -d
```

**Option B: Start Completely Empty (Recommended for Production)**

1. First, remove or replace `last.sql`:

```bash
# On your VPS after cloning
cd moosapoor

# Option 1: Remove the test data initialization
rm last.sql

# Option 2: Replace with empty database
# Create a minimal init file
cat > last.sql << 'EOF'
-- Empty initialization - database will use schema.sql
-- Add your initial admin user here if needed
EOF

# Then start
docker compose up -d
```

---

## 🔐 Security Note: `last.sql` Contains Data!

Your `last.sql` file has:
- ✅ Database schema
- ✅ Test customers
- ✅ Test transactions
- ✅ Admin user (admin/admin123)

**For Production VPS:**
- Keep `last.sql` for initial structure
- Change admin password immediately after first login
- The test data is minimal and safe for production start

---

## 🎯 Quick Decision Guide

**For VPS Production Deployment:**
```bash
# Recommended: Keep last.sql (it has minimal test data)
# Just change admin password after login
docker compose up -d
```

**Want completely empty database?**
```bash
# Remove last.sql or replace with empty version
rm last.sql
docker compose up -d
```

**Already deployed and want fresh start?**
```bash
# Backup first!
docker exec goldshop_mysql mysqldump [...] > backup.sql

# Then clean
docker compose down
docker volume rm goldshop_mysql_data
docker compose up -d
```

---

## 📊 Data Persistence Verification

After deployment, verify persistence:

```bash
# 1. Add some test data through the web interface

# 2. Restart containers
docker compose restart

# 3. Check if data is still there (it should be!)
# Visit your website and check

# 4. Even rebuild works
docker compose down
docker compose up -d --build

# Data is still there! ✅
```

---

## 🆘 Troubleshooting

### Database won't initialize
```bash
# Check if volume already exists with data
docker volume inspect goldshop_mysql_data

# If it exists and has data, it won't reinitialize
# Solution: Remove volume and restart
docker compose down
docker volume rm goldshop_mysql_data
docker compose up -d
```

### Lost all data after restart
```bash
# This shouldn't happen with named volumes!
# Check if volumes exist:
docker volume ls | grep goldshop

# If missing, they were accidentally removed
# Restore from backup:
docker exec -i goldshop_mysql mysql -u root -p < backup.sql
```

---

## ✅ Summary for Your VPS

Your setup is **already perfect** for VPS deployment:

1. ✅ All data is persistent (survives restarts)
2. ✅ Database auto-initializes from `last.sql` on first run
3. ✅ Uploads, backups, SSL certificates all persistent
4. ✅ Safe to restart/rebuild containers anytime
5. ✅ Data only deleted if you explicitly remove volumes

**You can deploy to VPS as-is!** Your data will persist through:
- Container restarts
- Container rebuilds
- System reboots
- Application updates

**Data is ONLY lost if:**
- You run `docker volume rm`
- You run `docker compose down -v` (the `-v` flag removes volumes)
- You manually delete `/var/lib/docker/volumes/goldshop_*`

**Your system is production-ready! 🎉**
