# 🐳 Docker Deployment Guide
# راهنمای استقرار Docker - سیستم مدیریت طلافروشی زرین

## 📋 مقدمه (Introduction)

این راهنما نحوه اجرای سیستم مدیریت طلافروشی زرین با استفاده از Docker را توضیح می‌دهد.

This guide explains how to run the Gold Shop Management System using Docker.

---

## 🎯 مزایای استفاده از Docker

✅ **نصب آسان**: بدون نیاز به نصب Node.js و MySQL روی سیستم  
✅ **محیط یکسان**: در همه سیستم‌ها به یک شکل اجرا می‌شود  
✅ **جداسازی**: مشکلات نرم‌افزاری روی یکدیگر تاثیر نمی‌گذارند  
✅ **قابل حمل**: به راحتی روی هر سروری قابل نصب است  
✅ **پشتیبان‌گیری آسان**: داده‌ها در volumeها ذخیره می‌شوند  

---

## 📦 پیش‌نیازها (Prerequisites)

### نصب Docker

#### Windows:
```powershell
# دانلود و نصب Docker Desktop از:
# https://www.docker.com/products/docker-desktop
```

#### Ubuntu/Debian:
```bash
# بروزرسانی سیستم
sudo apt update

# نصب Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# نصب Docker Compose
sudo apt install docker-compose-plugin

# افزودن کاربر به گروه docker
sudo usermod -aG docker $USER
newgrp docker

# بررسی نصب
docker --version
docker compose version
```

#### CentOS/RHEL:
```bash
# نصب Docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# فعال‌سازی Docker
sudo systemctl start docker
sudo systemctl enable docker

# افزودن کاربر به گروه docker
sudo usermod -aG docker $USER
```

---

## 🚀 راه‌اندازی سریع (Quick Start)

### مرحله 1: آماده‌سازی محیط

```bash
# رفتن به پوشه پروژه
cd /home/crystalah/kiro/moosapourgold

# کپی فایل تنظیمات محیطی
cp .env.example .env

# ویرایش فایل .env و تغییر رمزهای عبور
nano .env
```

**مهم**: حتما این موارد را تغییر دهید:
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_PASSWORD`
- `SESSION_SECRET`

### مرحله 2: ساخت و اجرای کانتینرها

```bash
# ساخت و اجرای کانتینرها (اولین بار)
docker compose up -d --build

# مشاهده لاگ‌ها
docker compose logs -f

# بررسی وضعیت کانتینرها
docker compose ps
```

### مرحله 3: دسترسی به برنامه

🌐 **برنامه**: http://localhost:3000  
🔐 **ورود پیش‌فرض**:
- نام کاربری: `admin`
- رمز عبور: `admin123`

📊 **دیتابیس**: 
- هاست: `localhost`
- پورت: `3307` (از خارج کانتینر)
- نام دیتابیس: `gold_shop_db`

---

## 📋 دستورات مفید Docker

### مدیریت کانتینرها

```bash
# شروع کانتینرها
docker compose start

# توقف کانتینرها
docker compose stop

# ری‌استارت کانتینرها
docker compose restart

# توقف و حذف کانتینرها
docker compose down

# توقف و حذف همه چیز (شامل volumeها)
docker compose down -v
```

### مشاهده لاگ‌ها

```bash
# تمام لاگ‌ها
docker compose logs

# لاگ برنامه
docker compose logs app

# لاگ دیتابیس
docker compose logs mysql

# دنبال کردن لاگ‌ها (live)
docker compose logs -f app
```

### دسترسی به کانتینرها

```bash
# دسترسی به shell برنامه
docker compose exec app sh

# دسترسی به MySQL
docker compose exec mysql mysql -u root -p

# اجرای دستور در کانتینر
docker compose exec app node -v
```

---

## 💾 مدیریت داده‌ها و پشتیبان‌گیری

### Docker Volumes

داده‌های زیر در volumeهای Docker ذخیره می‌شوند:

- `goldshop_mysql_data` - دیتابیس MySQL
- `goldshop_uploads` - تصاویر آپلود شده
- `goldshop_backups` - فایل‌های بک‌آپ
- `goldshop_temp_uploads` - فایل‌های موقت

### پشتیبان‌گیری از Volume

```bash
# پشتیبان از دیتابیس
docker compose exec mysql mysqldump -u root -p gold_shop_db > backup_$(date +%Y%m%d).sql

# پشتیبان از volume (روش پیشرفته)
docker run --rm -v goldshop_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_data_backup.tar.gz /data

# پشتیبان از تصاویر
docker run --rm -v goldshop_uploads:/data -v $(pwd):/backup alpine tar czf /backup/uploads_backup.tar.gz /data
```

### بازیابی Volume

```bash
# بازیابی دیتابیس از فایل SQL
docker compose exec -T mysql mysql -u root -p gold_shop_db < backup_20250128.sql

# بازیابی volume
docker run --rm -v goldshop_mysql_data:/data -v $(pwd):/backup alpine tar xzf /backup/mysql_data_backup.tar.gz -C /
```

---

## 🔧 تنظیمات پیشرفته

### تغییر پورت‌ها

فایل `.env` را ویرایش کنید:

```env
APP_PORT=8080      # تغییر پورت برنامه
MYSQL_PORT=3308    # تغییر پورت MySQL
```

سپس:
```bash
docker compose down
docker compose up -d
```

### حالت توسعه (Development Mode)

برای فعال کردن hot-reload در حالت توسعه:

1. فایل `docker-compose.yml` را باز کنید
2. خطوط کامنت شده در بخش `volumes` سرویس `app` را uncomment کنید
3. در `.env` تنظیم کنید: `NODE_ENV=development`
4. ری‌استارت کنید: `docker compose restart app`

### اتصال از بیرون (Production)

برای دسترسی از طریق domain یا IP خارجی:

1. پورت 3000 را در فایروال باز کنید:
```bash
sudo ufw allow 3000/tcp
```

2. یا از Nginx به عنوان reverse proxy استفاده کنید (توصیه می‌شود)

---

## 🔍 عیب‌یابی (Troubleshooting)

### کانتینر شروع نمی‌شود

```bash
# بررسی لاگ‌ها
docker compose logs

# بررسی وضعیت health
docker compose ps
```

### دیتابیس آماده نیست

```bash
# چک کردن آماده بودن MySQL
docker compose exec mysql mysqladmin ping -h localhost -u root -p

# restart کردن سرویس MySQL
docker compose restart mysql
```

### مشکل با تصاویر/uploads

```bash
# بررسی دسترسی‌ها
docker compose exec app ls -la public/uploads/

# ایجاد مجدد پوشه
docker compose exec app mkdir -p public/uploads
docker compose exec app chmod 755 public/uploads
```

### مشکل با Puppeteer/PDF

```bash
# بررسی نصب Chromium
docker compose exec app which chromium-browser

# تست Puppeteer
docker compose exec app node -e "const puppeteer = require('puppeteer'); console.log('OK')"
```

### پاک کردن کامل و شروع مجدد

```bash
# حذف همه چیز
docker compose down -v
docker system prune -a

# شروع مجدد
docker compose up -d --build
```

---

## 📊 مانیتورینگ

### مصرف منابع

```bash
# مشاهده مصرف CPU و RAM
docker stats

# مشاهده فضای استفاده شده
docker system df

# بررسی volumeها
docker volume ls
```

### Health Check

```bash
# بررسی سلامت کانتینرها
docker compose ps

# تست دسترسی به برنامه
curl http://localhost:3000
```

---

## 🔄 به‌روزرسانی (Updates)

```bash
# دریافت آخرین تغییرات
git pull origin main

# ری‌بیلد کردن با تغییرات جدید
docker compose down
docker compose up -d --build

# بررسی لاگ‌ها
docker compose logs -f app
```

---

## 🌐 استقرار روی VPS

### روش 1: استفاده از Docker (توصیه می‌شود)

```bash
# 1. نصب Docker روی VPS
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. کپی پروژه به VPS
scp -r /path/to/project user@vps-ip:/var/www/goldshop

# 3. اجرای Docker Compose
cd /var/www/goldshop
docker compose up -d --build
```

### روش 2: با Nginx Reverse Proxy

فایل Nginx config نمونه (`/etc/nginx/sites-available/goldshop`):

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

فعال‌سازی:
```bash
sudo ln -s /etc/nginx/sites-available/goldshop /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 📱 دسترسی از موبایل/تبلت

اگر می‌خواهید از شبکه محلی به برنامه دسترسی داشته باشید:

1. IP سرور را پیدا کنید:
```bash
hostname -I
```

2. از موبایل/تبلت به آدرس زیر بروید:
```
http://[IP-SERVER]:3000
```

مثال: `http://192.168.1.100:3000`

---

## 🛡️ نکات امنیتی

1. ✅ **حتما** رمزهای عبور پیش‌فرض را تغییر دهید
2. ✅ `SESSION_SECRET` را به یک رشته تصادفی تغییر دهید
3. ✅ فایل `.env` را به git اضافه نکنید
4. ✅ در production از HTTPS استفاده کنید
5. ✅ پورت‌های غیرضروری را در فایروال ببندید
6. ✅ به‌طور منظم backup بگیرید
7. ✅ رمز عبور admin را در برنامه تغییر دهید

---

## 📞 پشتیبانی و کمک

اگر مشکلی داشتید:

1. لاگ‌ها را بررسی کنید: `docker compose logs`
2. وضعیت کانتینرها را چک کنید: `docker compose ps`
3. دستورات عیب‌یابی بالا را امتحان کنید

---

## 📝 یادداشت‌های مهم

- **پورت پیش‌فرض برنامه**: 3000
- **پورت پیش‌فرض MySQL**: 3307 (از خارج)
- **دیتابیس از `last.sql` مقداردهی اولیه می‌شود**
- **تمام داده‌ها در Docker volumes ذخیره می‌شوند**
- **برای production حتما از Nginx reverse proxy استفاده کنید**

---

## ✅ چک‌لیست نصب

- [ ] Docker و Docker Compose نصب شده
- [ ] فایل `.env` ساخته و تنظیم شده
- [ ] رمزهای عبور تغییر کرده
- [ ] کانتینرها با موفقیت اجرا شدند
- [ ] برنامه در `http://localhost:3000` در دسترس است
- [ ] لاگین با admin/admin123 موفقیت‌آمیز بود
- [ ] رمز عبور admin در برنامه تغییر کرد
- [ ] پشتیبان‌گیری تست شد

---

**موفق باشید! 🎉**
