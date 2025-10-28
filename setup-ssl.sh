#!/bin/bash

# SSL Setup Script for Gold Shop Management System
# This script will obtain SSL certificate from Let's Encrypt

set -e

DOMAIN="mosaporgold.ir"
EMAIL="your-email@example.com"  # Change this to your email

echo "=========================================="
echo "SSL Certificate Setup"
echo "راه‌اندازی گواهی SSL"
echo "=========================================="
echo ""

# Check if domain is set
if [ -z "$DOMAIN" ]; then
    echo "❌ Error: DOMAIN not set!"
    exit 1
fi

# Check if containers are running
if ! docker compose ps | grep -q "goldshop_nginx.*Up"; then
    echo "❌ Error: Nginx container is not running!"
    echo "Please run: docker compose up -d"
    exit 1
fi

echo "📋 Configuration:"
echo "   Domain: $DOMAIN"
echo "   Email: $EMAIL"
echo ""

read -p "Is this correct? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Setup cancelled. Please edit this script and update DOMAIN and EMAIL."
    exit 1
fi

echo ""
echo "🔐 Obtaining SSL certificate from Let's Encrypt..."
echo ""

# Obtain certificate
docker compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    -d "$DOMAIN" \
    -d "www.$DOMAIN"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SSL certificate obtained successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Edit docker/nginx/conf.d/goldshop.conf"
    echo "2. Uncomment the HTTPS server block"
    echo "3. Comment out the temporary HTTP proxy"
    echo "4. Restart nginx: docker compose restart nginx"
    echo ""
    echo "Or run: ./enable-ssl.sh"
else
    echo ""
    echo "❌ Failed to obtain SSL certificate"
    echo ""
    echo "Troubleshooting:"
    echo "1. Make sure domain mosaporgold.ir points to 45.156.186.85"
    echo "2. Check DNS propagation: dig mosaporgold.ir"
    echo "3. Ensure ports 80 and 443 are open"
    echo "4. Check logs: docker compose logs nginx certbot"
fi
