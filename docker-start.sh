#!/bin/bash

# Quick Start Script for Gold Shop Management System
# اسکریپت راه‌اندازی سریع سیستم مدیریت طلافروشی

set -e

echo "=========================================="
echo "Gold Shop Management - Docker Setup"
echo "سیستم مدیریت طلافروشی - راه‌اندازی Docker"
echo "=========================================="
echo ""
echo "Domain: mosaporgold.ir"
echo "IP: 45.156.186.85"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "❌ Docker نصب نشده است!"
    echo ""
    echo "Please install Docker first:"
    echo "لطفا ابتدا Docker را نصب کنید:"
    echo "https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "❌ Docker Compose نصب نشده است!"
    exit 1
fi

echo "✅ Docker is installed"
echo "✅ Docker نصب شده است"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    echo "📝 ساخت فایل .env از الگو..."
    cp .env.example .env
    echo "⚠️  IMPORTANT: Please edit .env file and change passwords!"
    echo "⚠️  مهم: لطفا فایل .env را ویرایش کنید و رمزها را تغییر دهید!"
    echo ""
    read -p "Press Enter to continue after editing .env (or Ctrl+C to exit)..." 
fi

# Check if last.sql exists
if [ ! -f last.sql ]; then
    echo "⚠️  Warning: last.sql not found!"
    echo "⚠️  هشدار: فایل last.sql پیدا نشد!"
    echo "The database will be empty on first run."
    echo "دیتابیس در اجرای اول خالی خواهد بود."
    echo ""
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
echo "🛑 توقف کانتینرهای موجود..."
docker compose down 2>/dev/null || true
echo ""

# Build and start containers
echo "🏗️  Building Docker images..."
echo "🏗️  ساخت تصاویر Docker..."
docker compose build --no-cache
echo ""

echo "🚀 Starting containers..."
echo "🚀 شروع کانتینرها..."
docker compose up -d
echo ""

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
echo "⏳ در انتظار آماده شدن سرویس‌ها..."
sleep 10

# Check container status
echo ""
echo "📊 Container Status:"
echo "📊 وضعیت کانتینرها:"
docker compose ps
echo ""

# Check if app is responding
echo "🔍 Checking application health..."
echo "🔍 بررسی سلامت برنامه..."
sleep 5

if curl -f http://localhost:80 > /dev/null 2>&1; then
    echo ""
    echo "=========================================="
    echo "✅ SUCCESS! Application is running!"
    echo "✅ موفق! برنامه در حال اجرا است!"
    echo "=========================================="
    echo ""
    echo "🌐 Access the application at:"
    echo "🌐 دسترسی به برنامه از:"
    echo "   http://mosaporgold.ir"
    echo "   http://45.156.186.85"
    echo "   http://localhost (local)"
    echo ""
    echo "🔐 Default login:"
    echo "🔐 ورود پیش‌فرض:"
    echo "   Username: admin"
    echo "   Password: admin123"
    echo ""
    echo "� Next Steps:"
    echo "🔒 مراحل بعدی:"
    echo "   1. Make sure DNS points to 45.156.186.85"
    echo "   2. Run ./setup-ssl.sh to get SSL certificate"
    echo "   3. Run ./enable-ssl.sh to enable HTTPS"
    echo "   4. Change admin password in application"
    echo ""
    echo "📊 Services:"
    echo "   • MySQL Database (internal)"
    echo "   • Node.js App (internal)"
    echo "   • Nginx Proxy (ports 80, 443)"
    echo ""
    echo "📋 Useful commands:"
    echo "📋 دستورات مفید:"
    echo "   docker compose logs -f     # View logs"
    echo "   docker compose stop        # Stop containers"
    echo "   docker compose start       # Start containers"
    echo "   docker compose restart     # Restart containers"
    echo "   docker compose down        # Stop and remove containers"
    echo ""
    echo "📚 For more info:"
    echo "   • README_DOCKER.md - Docker guide"
    echo "   • PRODUCTION_DEPLOYMENT.md - Production setup"
    echo "=========================================="
else
    echo ""
    echo "⚠️  Application may still be starting..."
    echo "⚠️  برنامه ممکن است هنوز در حال راه‌اندازی باشد..."
    echo ""
    echo "Check logs with:"
    echo "بررسی لاگ‌ها با:"
    echo "   docker compose logs -f"
fi

echo ""
