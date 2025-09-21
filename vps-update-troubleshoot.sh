#!/bin/bash
# VPS Update Troubleshooting Script for Gold Shop Management
echo "🔧 VPS Update Troubleshooting Script"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📍 Step 1: Check Current Directory and Git Status${NC}"
echo "Current directory: $(pwd)"
echo ""

echo -e "${BLUE}📍 Step 2: Git Status Check${NC}"
echo "Git status:"
git status
echo ""

echo "Current branch:"
git branch
echo ""

echo "Recent commits:"
git log --oneline -5
echo ""

echo -e "${BLUE}📍 Step 3: Check if local changes exist${NC}"
echo "Checking for uncommitted changes:"
if [[ $(git status --porcelain) ]]; then
    echo -e "${RED}❌ You have uncommitted changes that might prevent pulling:${NC}"
    git status --porcelain
    echo ""
    echo -e "${YELLOW}💡 Solution: Commit or stash your changes first:${NC}"
    echo "   git add ."
    echo "   git commit -m 'VPS local changes'"
    echo "   OR"
    echo "   git stash"
    echo "   git pull"
    echo "   git stash pop"
else
    echo -e "${GREEN}✅ No uncommitted changes${NC}"
fi
echo ""

echo -e "${BLUE}📍 Step 4: Check remote connection${NC}"
echo "Testing connection to remote repository:"
git remote -v
echo ""

echo "Fetching latest from remote:"
git fetch origin
echo ""

echo "Comparing local vs remote:"
git log HEAD..origin/main --oneline 2>/dev/null || git log HEAD..origin/master --oneline
echo ""

echo -e "${BLUE}📍 Step 5: Check specific files that should be updated${NC}"
echo "Checking customers list file modification time:"
ls -la views/customers/list.ejs 2>/dev/null || echo "File not found"
echo ""

echo "Checking server.js modification time:"
ls -la server.js 2>/dev/null || echo "File not found"
echo ""

echo -e "${BLUE}📍 Step 6: PM2 Process Status${NC}"
echo "Current PM2 processes:"
pm2 list
echo ""

echo "PM2 logs (last 20 lines):"
pm2 logs --lines 20
echo ""

echo -e "${BLUE}📍 Step 7: Node.js Process Check${NC}"
echo "Checking if any Node.js processes are running:"
ps aux | grep node | grep -v grep
echo ""

echo "Checking what's running on port 3000:"
netstat -tulnp | grep :3000 2>/dev/null || ss -tulnp | grep :3000 2>/dev/null || echo "Nothing on port 3000"
echo ""

echo -e "${BLUE}📍 Step 8: File Permissions Check${NC}"
echo "Checking file permissions:"
ls -la package.json server.js views/customers/ 2>/dev/null || echo "Some files not found"
echo ""

echo -e "${BLUE}📍 Step 9: Disk Space Check${NC}"
echo "Available disk space:"
df -h .
echo ""

echo -e "${BLUE}📍 Step 10: Dependencies Check${NC}"
echo "Checking if node_modules exists:"
ls -la node_modules/ | head -5 2>/dev/null || echo "node_modules not found"
echo ""

echo "Checking package.json vs package-lock.json:"
if [ -f package-lock.json ]; then
    echo "package-lock.json exists"
else
    echo "package-lock.json missing"
fi
echo ""

echo -e "${YELLOW}=== RECOMMENDED SOLUTIONS ===${NC}"
echo ""

echo -e "${GREEN}1. Force Pull and Restart:${NC}"
echo "   git fetch origin"
echo "   git reset --hard origin/main  # or origin/master"
echo "   npm install"
echo "   pm2 restart all"
echo ""

echo -e "${GREEN}2. Complete PM2 Restart:${NC}"
echo "   pm2 kill"
echo "   pm2 start ecosystem.config.js"
echo "   # OR if no ecosystem file:"
echo "   pm2 start server.js --name gold-shop"
echo ""

echo -e "${GREEN}3. Manual Process Kill and Restart:${NC}"
echo "   pm2 kill"
echo "   pkill -f node"
echo "   npm start"
echo "   # OR"
echo "   node server.js"
echo ""

echo -e "${GREEN}4. Check Browser Cache:${NC}"
echo "   - Hard refresh: Ctrl+F5 (Windows) or Cmd+Shift+R (Mac)"
echo "   - Open in incognito/private mode"
echo "   - Clear browser cache"
echo ""

echo -e "${GREEN}5. Verify Updates Applied:${NC}"
echo "   curl -I http://localhost:3000"
echo "   curl -s http://localhost:3000/customers | grep -o 'card-view\\|table-view'"
echo ""

echo -e "${BLUE}📍 Run this script with: bash vps-update-troubleshoot.sh${NC}"
echo -e "${BLUE}📍 Or step by step as needed${NC}"
