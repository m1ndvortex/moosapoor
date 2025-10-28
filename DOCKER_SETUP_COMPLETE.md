# 🎉 Dockerization Complete!
# تبریک! Docker شدن با موفقیت انجام شد!

## ✅ Created Files / فایل‌های ایجاد شده

```
moosapourgold/
├── Dockerfile                    # تعریف ایمیج Node.js
├── docker-compose.yml            # تنظیمات کامل سرویس‌ها
├── .dockerignore                 # فایل‌های نادیده گرفته شده
├── .env.example                  # نمونه تنظیمات محیطی
├── docker-start.sh               # اسکریپت راه‌اندازی آسان
├── README_DOCKER.md              # راهنمای کامل Docker
└── docker/
    └── mysql/
        └── custom.cnf            # تنظیمات MySQL برای فارسی
```

## 🚀 How to Run / نحوه اجرا

### روش 1: استفاده از اسکریپت (آسان‌ترین)

```bash
./docker-start.sh
```

### روش 2: دستی (Manual)

```bash
# 1. ساخت فایل .env
cp .env.example .env
nano .env  # تغییر رمزها

# 2. اجرای Docker Compose
docker compose up -d --build

# 3. مشاهده لاگ‌ها
docker compose logs -f
```

## 📋 What You Get / چه چیزی دریافت می‌کنید

### ✅ Services / سرویس‌ها
- **Node.js Application** (Port 3000)
- **MySQL 8.0 Database** (Port 3307)

### ✅ Features / ویژگی‌ها
- ✅ Auto-initialize database from `last.sql`
- ✅ Persistent data storage (Docker volumes)
- ✅ Health checks for all services
- ✅ Persian/UTF8MB4 support
- ✅ Puppeteer for PDF generation
- ✅ Automatic restart on failure
- ✅ Isolated network
- ✅ Environment-based configuration

### ✅ Data Volumes / فضای ذخیره‌سازی
- `goldshop_mysql_data` - Database files
- `goldshop_uploads` - Uploaded images
- `goldshop_backups` - Backup files
- `goldshop_temp_uploads` - Temporary files

## 🔑 Important Configuration / تنظیمات مهم

### Before First Run / قبل از اجرای اول

**حتماً این کارها را انجام دهید:**

1. **Create .env file:**
```bash
cp .env.example .env
```

2. **Edit .env and change:**
- `MYSQL_ROOT_PASSWORD` - رمز root دیتابیس
- `MYSQL_PASSWORD` - رمز کاربر دیتابیس
- `SESSION_SECRET` - کلید جلسه (generate random)

3. **Generate secure session secret:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## 🌐 Access Points / نقاط دسترسی

After starting containers:

- **Web Application:** http://localhost:3000
- **MySQL Database:** localhost:3307
- **Default Login:**
  - Username: `admin`
  - Password: `admin123`

## 📊 Common Commands / دستورات رایج

```bash
# Start containers / شروع
docker compose up -d

# Stop containers / توقف
docker compose stop

# View logs / مشاهده لاگ
docker compose logs -f

# Restart / ری‌استارت
docker compose restart

# Check status / بررسی وضعیت
docker compose ps

# Remove everything / حذف همه چیز
docker compose down -v
```

## 🔧 Troubleshooting / عیب‌یابی

### Container won't start / کانتینر شروع نمی‌شود
```bash
docker compose logs
```

### Database connection failed / اتصال به دیتابیس ناموفق
```bash
docker compose exec mysql mysqladmin ping -u root -p
```

### Need to rebuild / نیاز به rebuild
```bash
docker compose down
docker compose up -d --build
```

## 📦 Backup & Restore / پشتیبان‌گیری و بازیابی

### Backup Database / پشتیبان دیتابیس
```bash
docker compose exec mysql mysqldump -u root -p gold_shop_db > backup_$(date +%Y%m%d).sql
```

### Restore Database / بازیابی دیتابیس
```bash
docker compose exec -T mysql mysql -u root -p gold_shop_db < backup_20250128.sql
```

### Backup Uploads / پشتیبان فایل‌ها
```bash
docker run --rm -v goldshop_uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads_backup.tar.gz /data
```

## 🛡️ Security Notes / نکات امنیتی

### ⚠️ IMPORTANT - Before Production:

1. ✅ Change all default passwords in `.env`
2. ✅ Generate strong `SESSION_SECRET`
3. ✅ Don't commit `.env` to Git
4. ✅ Use firewall to restrict ports
5. ✅ Use Nginx reverse proxy in production
6. ✅ Enable HTTPS with SSL certificate
7. ✅ Change admin password in application
8. ✅ Regular backups

## 🌍 VPS Deployment / استقرار روی سرور

### Quick VPS Setup:

```bash
# 1. Install Docker on VPS
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Copy project to VPS
scp -r /path/to/project user@vps-ip:/var/www/goldshop

# 3. SSH to VPS and run
cd /var/www/goldshop
cp .env.example .env
nano .env  # Edit passwords
./docker-start.sh

# 4. Setup firewall
sudo ufw allow 3000/tcp
sudo ufw enable
```

## 📚 Documentation / مستندات

For detailed instructions, read:
- **README_DOCKER.md** - Complete Docker guide
- **COMPLETE_INSTALLATION_GUIDE.md** - Full installation manual

## ✅ Testing Checklist / چک‌لیست تست

- [ ] Docker & Docker Compose installed
- [ ] `.env` file created and configured
- [ ] Passwords changed from defaults
- [ ] Containers started successfully
- [ ] Application accessible at http://localhost:3000
- [ ] Can login with admin/admin123
- [ ] Database initialized with data
- [ ] File uploads working
- [ ] PDF generation working (invoices)
- [ ] Backup system functioning

## 🎯 What's Different from Regular Installation?

### Advantages of Docker Version:
✅ No need to install Node.js or MySQL on host
✅ Isolated environment - no conflicts
✅ Easy to deploy on any server
✅ Consistent environment everywhere
✅ Easy backup and restore
✅ Auto-restart on failure
✅ Scalable architecture

### Key Differences:
- Database runs in container (not on host)
- Application runs in container
- Data persists in Docker volumes
- All configuration through `.env` file
- Port 3307 instead of 3306 (to avoid conflicts)

## 🔄 Updating the Application

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker compose down
docker compose up -d --build

# Check logs
docker compose logs -f app
```

## 💡 Tips / نکته‌ها

1. **Development Mode:** Uncomment volume mounts in `docker-compose.yml` for hot-reload
2. **Production Mode:** Use Nginx reverse proxy for better performance
3. **Monitoring:** Use `docker stats` to monitor resource usage
4. **Logs:** Check logs regularly with `docker compose logs`
5. **Backups:** Automate backups with cron jobs
6. **Security:** Keep Docker and images updated

## 📞 Need Help? / کمک نیاز دارید؟

1. Check logs: `docker compose logs -f`
2. Check container status: `docker compose ps`
3. Read troubleshooting section in README_DOCKER.md
4. Verify environment variables in `.env`

---

## 🎉 Ready to Go! / آماده استفاده!

Your Gold Shop Management System is now fully dockerized and ready to deploy anywhere!

سیستم مدیریت طلافروشی شما حالا به طور کامل Docker شده و آماده استقرار در هر جایی است!

**Next Steps:**
1. Run `./docker-start.sh`
2. Access http://localhost:3000
3. Login and change admin password
4. Start using your application!

**موفق باشید! 🚀**
