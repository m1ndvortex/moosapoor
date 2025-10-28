#!/bin/bash
# VPS Auto-Restart Setup Script
# Run this ONCE on your VPS after Docker installation

set -e

echo "🔄 Setting up Docker Auto-Restart on VPS..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${BLUE}Step 1: Enabling Docker service on boot...${NC}"
systemctl enable docker
systemctl enable containerd.service
echo -e "${GREEN}✅ Docker enabled${NC}"
echo ""

echo -e "${BLUE}Step 2: Starting Docker service...${NC}"
systemctl start docker
echo -e "${GREEN}✅ Docker started${NC}"
echo ""

echo -e "${BLUE}Step 3: Verifying Docker status...${NC}"
systemctl status docker --no-pager | head -5
echo ""

echo -e "${BLUE}Step 4: Checking Docker Compose...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker not found! Please install Docker first.${NC}"
    exit 1
fi

docker compose version || docker-compose --version
echo -e "${GREEN}✅ Docker Compose is available${NC}"
echo ""

echo -e "${BLUE}Step 5: Creating health check script...${NC}"
cat > /usr/local/bin/docker-health-check.sh << 'EOF'
#!/bin/bash
# Docker Health Check Script
# Checks if containers are running and attempts to restart them

COMPOSE_DIR="/opt/moosapoor"
CONTAINERS="goldshop_mysql goldshop_app goldshop_nginx goldshop_certbot"

cd $COMPOSE_DIR || exit 1

for container in $CONTAINERS; do
    if [ ! $(docker ps -q -f name=$container) ]; then
        echo "[$(date)] WARNING: $container is not running!"
        echo "[$(date)] Attempting to start $container..."
        docker compose up -d $container
        
        if [ $? -eq 0 ]; then
            echo "[$(date)] SUCCESS: $container started"
        else
            echo "[$(date)] ERROR: Failed to start $container"
        fi
    fi
done
EOF

chmod +x /usr/local/bin/docker-health-check.sh
echo -e "${GREEN}✅ Health check script created at /usr/local/bin/docker-health-check.sh${NC}"
echo ""

echo -e "${BLUE}Step 6: Setting up cron job for monitoring...${NC}"
# Remove existing cron job if exists
crontab -l 2>/dev/null | grep -v 'docker-health-check.sh' | crontab -

# Add new cron job (check every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/docker-health-check.sh >> /var/log/docker-health.log 2>&1") | crontab -
echo -e "${GREEN}✅ Cron job added (checks every 5 minutes)${NC}"
echo ""

echo -e "${BLUE}Step 7: Creating log directory...${NC}"
touch /var/log/docker-health.log
chmod 644 /var/log/docker-health.log
echo -e "${GREEN}✅ Log file created at /var/log/docker-health.log${NC}"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ VPS Auto-Restart Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}What's configured:${NC}"
echo "  ✅ Docker starts automatically on VPS boot"
echo "  ✅ All containers have restart: unless-stopped"
echo "  ✅ Health monitoring every 5 minutes"
echo "  ✅ Automatic container restart if stopped"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Deploy your application: cd /opt/moosapoor && docker compose up -d"
echo "  2. Test auto-restart: sudo reboot"
echo "  3. Check logs: tail -f /var/log/docker-health.log"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  • Check containers: docker ps"
echo "  • Check Docker status: systemctl status docker"
echo "  • View health logs: tail -f /var/log/docker-health.log"
echo "  • Manual health check: /usr/local/bin/docker-health-check.sh"
echo ""
echo -e "${GREEN}Your application will now survive VPS reboots! 🎉${NC}"
