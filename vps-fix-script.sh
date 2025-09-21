#!/bin/bash
# VPS Fix Script - Targeted Solution
echo "🔧 VPS Fix Script - Applying Updates"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📍 Step 1: Force refresh from remote${NC}"
echo "Current commit: $(git rev-parse HEAD)"
echo "Remote commit: $(git rev-parse origin/main)"

if [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ]; then
    echo -e "${YELLOW}⚠️  Local and remote are same commit, but files might be different${NC}"
    echo "Force refreshing from remote..."
    
    # Force refresh
    git fetch origin
    git reset --hard origin/main
    echo -e "${GREEN}✅ Forced refresh completed${NC}"
else
    echo -e "${RED}❌ Commits are different - pulling updates${NC}"
    git pull origin main
fi
echo ""

echo -e "${BLUE}📍 Step 2: Check if responsive code exists${NC}"
if grep -q "card-view\|table-view" views/customers/list.ejs; then
    echo -e "${GREEN}✅ Responsive code found in list.ejs${NC}"
    echo "Responsive classes found:"
    grep -n "card-view\|table-view" views/customers/list.ejs | head -5
else
    echo -e "${RED}❌ Responsive code NOT found - this is the issue!${NC}"
    echo "The responsive changes didn't apply properly"
fi
echo ""

echo -e "${BLUE}📍 Step 3: Check server.js for moment-jalaali${NC}"
if grep -q "require('moment-jalaali')" server.js; then
    echo -e "${GREEN}✅ moment-jalaali import found in server.js${NC}"
else
    echo -e "${RED}❌ moment-jalaali import missing${NC}"
fi
echo ""

echo -e "${BLUE}📍 Step 4: Install/Update dependencies${NC}"
npm install
npm install moment-jalaali
echo ""

echo -e "${BLUE}📍 Step 5: Check file timestamps${NC}"
echo "Current file times:"
ls -la views/customers/list.ejs
ls -la server.js
echo ""

echo -e "${BLUE}📍 Step 6: Restart PM2 completely${NC}"
echo "Stopping PM2..."
pm2 stop gold-shop

echo "Killing PM2 processes..."
pm2 kill

echo "Starting fresh..."
pm2 start server.js --name gold-shop

echo "Checking PM2 status..."
pm2 list
echo ""

echo -e "${BLUE}📍 Step 7: Test the application${NC}"
sleep 3
echo "Testing server response..."
curl -I http://localhost:3000

echo ""
echo "Testing customer page for responsive elements..."
if curl -s http://localhost:3000/customers | grep -q "card-view"; then
    echo -e "${GREEN}✅ Responsive elements found!${NC}"
else
    echo -e "${RED}❌ Responsive elements still missing${NC}"
fi
echo ""

echo -e "${BLUE}📍 Step 8: Quick SQL Error Check${NC}"
echo "Recent PM2 errors (last 5 lines):"
pm2 logs gold-shop --err --lines 5
echo ""

echo -e "${YELLOW}=== NEXT STEPS ===${NC}"
echo ""
echo -e "${GREEN}1. Test in browser:${NC}"
echo "   Visit: http://your-vps-ip:3000/customers"
echo "   - Desktop: Should show table"
echo "   - Mobile: Should show cards"
echo ""
echo -e "${GREEN}2. If still not working:${NC}"
echo "   - Clear browser cache completely"
echo "   - Try incognito mode"
echo "   - Check console for JavaScript errors"
echo ""
echo -e "${GREEN}3. If SQL errors persist:${NC}"
echo "   pm2 logs gold-shop --err --lines 20"
echo ""

echo -e "${BLUE}Script completed! Check the results above.${NC}"
