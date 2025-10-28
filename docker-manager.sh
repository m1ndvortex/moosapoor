#!/bin/bash

# Docker Management Helper Script
# اسکریپت کمکی مدیریت Docker

COMPOSE_FILE="docker-compose.yml"

show_menu() {
    echo "=========================================="
    echo "Gold Shop Management - Docker Manager"
    echo "مدیریت سیستم طلافروشی"
    echo "=========================================="
    echo ""
    echo "1) Start containers (شروع کانتینرها)"
    echo "2) Stop containers (توقف کانتینرها)"
    echo "3) Restart containers (ری‌استارت)"
    echo "4) View logs (مشاهده لاگ‌ها)"
    echo "5) Check status (بررسی وضعیت)"
    echo "6) Backup database (پشتیبان دیتابیس)"
    echo "7) Access MySQL shell (دسترسی به MySQL)"
    echo "8) Access app shell (دسترسی به برنامه)"
    echo "9) Clean everything (پاک کردن همه چیز)"
    echo "0) Exit (خروج)"
    echo ""
    echo -n "Select option / انتخاب گزینه: "
}

start_containers() {
    echo "🚀 Starting containers..."
    docker compose up -d
    echo "✅ Done! Access: http://localhost:3000"
}

stop_containers() {
    echo "🛑 Stopping containers..."
    docker compose stop
    echo "✅ Done!"
}

restart_containers() {
    echo "🔄 Restarting containers..."
    docker compose restart
    echo "✅ Done!"
}

view_logs() {
    echo "📋 Viewing logs (Ctrl+C to exit)..."
    docker compose logs -f
}

check_status() {
    echo "📊 Container Status:"
    docker compose ps
    echo ""
    echo "💾 Disk Usage:"
    docker system df
    echo ""
    echo "📈 Resource Usage:"
    docker stats --no-stream
}

backup_database() {
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    echo "💾 Creating database backup..."
    docker compose exec -T mysql mysqldump -u root -p gold_shop_db > "$BACKUP_FILE"
    echo "✅ Backup saved to: $BACKUP_FILE"
}

mysql_shell() {
    echo "🗄️  Opening MySQL shell..."
    docker compose exec mysql mysql -u root -p gold_shop_db
}

app_shell() {
    echo "🖥️  Opening app shell..."
    docker compose exec app sh
}

clean_everything() {
    echo "⚠️  WARNING: This will remove all containers, volumes, and data!"
    echo "⚠️  هشدار: این عملیات همه کانتینرها، volumeها و داده‌ها را حذف می‌کند!"
    echo ""
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" == "yes" ]; then
        echo "🗑️  Cleaning everything..."
        docker compose down -v
        docker system prune -f
        echo "✅ Done!"
    else
        echo "❌ Cancelled"
    fi
}

# Main loop
while true; do
    show_menu
    read choice
    case $choice in
        1) start_containers ;;
        2) stop_containers ;;
        3) restart_containers ;;
        4) view_logs ;;
        5) check_status ;;
        6) backup_database ;;
        7) mysql_shell ;;
        8) app_shell ;;
        9) clean_everything ;;
        0) echo "👋 Goodbye!"; exit 0 ;;
        *) echo "❌ Invalid option" ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
    clear
done
