#!/bin/bash

# Enable SSL in Nginx configuration
# This script activates the HTTPS server block after SSL certificate is obtained

set -e

CONFIG_FILE="docker/nginx/conf.d/goldshop.conf"

echo "=========================================="
echo "Enable SSL Configuration"
echo "فعال‌سازی SSL"
echo "=========================================="
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Configuration file not found!"
    exit 1
fi

echo "📝 Updating Nginx configuration..."

# Check if SSL is already enabled
if grep -q "^server {" "$CONFIG_FILE" | head -1 | grep -q "443"; then
    echo "✅ SSL appears to be already enabled!"
    read -p "Continue anyway? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        exit 0
    fi
fi

# Backup original config
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
echo "📦 Backup created: $CONFIG_FILE.backup"

# Comment out temporary HTTP proxy and enable redirect
sed -i 's/^    # location \/ {$/    location \/ {/' "$CONFIG_FILE"
sed -i 's/^    #     return 301 https:\/\/\$host\$request_uri;$/        return 301 https:\/\/\$host\$request_uri;/' "$CONFIG_FILE"
sed -i 's/^    # }$/    }/' "$CONFIG_FILE"

# Comment out the temporary proxy block
sed -i '/# Temporary proxy to app (before SSL is configured)/,/^    }$/ {
    /# Temporary proxy to app/! {
        /^    location \/ {$/,/^    }$/ s/^/    # /
    }
}' "$CONFIG_FILE"

# Uncomment the HTTPS server block
sed -i '/# HTTPS Server/,/^# }$/ s/^# //' "$CONFIG_FILE"

echo "✅ Configuration updated!"
echo ""
echo "🔄 Restarting Nginx..."
docker compose restart nginx

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ SSL Enabled Successfully!"
    echo "✅ SSL با موفقیت فعال شد!"
    echo "=========================================="
    echo ""
    echo "🌐 Your site is now available at:"
    echo "   https://mosaporgold.ir"
    echo ""
    echo "🔒 HTTP traffic will be redirected to HTTPS"
    echo ""
else
    echo ""
    echo "❌ Failed to restart Nginx"
    echo "Restoring backup..."
    mv "$CONFIG_FILE.backup" "$CONFIG_FILE"
    docker compose restart nginx
    echo "Configuration restored. Check logs: docker compose logs nginx"
fi
