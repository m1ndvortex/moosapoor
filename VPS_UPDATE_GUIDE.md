# 🚀 VPS Update Troubleshooting Guide

## Common Issues and Solutions

### 🔍 **Issue: Changes not showing after `git pull` and `pm2 restart`**

This usually happens due to one of these reasons:

## 📋 **Step-by-Step Troubleshooting**

### **1. Check Git Status**
```bash
cd /path/to/your/project
git status
git branch
```

**If you see uncommitted changes:**
```bash
# Option A: Commit them
git add .
git commit -m "VPS local changes"

# Option B: Stash them
git stash
```

### **2. Force Update from Remote**
```bash
# Fetch latest changes
git fetch origin

# Check what's different
git log HEAD..origin/main --oneline

# Force update (⚠️ This will overwrite local changes)
git reset --hard origin/main
# OR if your main branch is 'master':
git reset --hard origin/master
```

### **3. Install Dependencies**
```bash
# Make sure all dependencies are installed
npm install

# Specifically install moment-jalaali if missing
npm install moment-jalaali
```

### **4. Complete PM2 Restart**
```bash
# Option A: Restart all processes
pm2 restart all

# Option B: Kill and restart (more thorough)
pm2 kill
pm2 start server.js --name gold-shop

# Option C: If you have ecosystem file
pm2 start ecosystem.config.js
```

### **5. Manual Process Check**
```bash
# Check what's running on port 3000
netstat -tulnp | grep :3000
# OR
ss -tulnp | grep :3000

# If something else is running, kill it
sudo kill -9 <PID>

# Check all node processes
ps aux | grep node

# Kill all node processes if needed
pkill -f node
```

### **6. Start Fresh**
```bash
# Navigate to project directory
cd /path/to/your/project

# Start the application
node server.js

# OR with PM2
pm2 start server.js --name gold-shop --watch
```

### **7. Verify the Update**
```bash
# Check if server is responding
curl -I http://localhost:3000

# Check if responsive features are present
curl -s http://localhost:3000/customers | grep -o "card-view\|table-view"

# If you see both "card-view" and "table-view", the update worked!
```

### **8. Browser Cache Issues**
- **Hard Refresh**: `Ctrl+F5` (Windows) or `Cmd+Shift+R` (Mac)
- **Incognito Mode**: Open in private/incognito browsing
- **Clear Cache**: Clear browser cache completely

## 🔧 **Quick Fix Commands**

Run these commands in sequence on your VPS:

```bash
# 1. Go to project directory
cd /path/to/your/project

# 2. Force pull latest changes
git fetch origin
git reset --hard origin/main

# 3. Install dependencies
npm install

# 4. Completely restart PM2
pm2 kill
pm2 start server.js --name gold-shop

# 5. Check if it's working
curl -I http://localhost:3000
```

## 🚨 **Emergency Reset**

If nothing works, try this complete reset:

```bash
# 1. Kill everything
pm2 kill
pkill -f node

# 2. Backup and re-clone (if needed)
mv your-project your-project-backup
git clone <your-repo-url> your-project
cd your-project

# 3. Set up fresh
npm install
npm install moment-jalaali

# 4. Start
pm2 start server.js --name gold-shop
```

## 📊 **Verification Checklist**

After updating, verify these features work:

### ✅ **Responsive Design**
- [ ] Desktop: Full table visible
- [ ] Tablet: Reduced columns, horizontal scroll
- [ ] Mobile: Card layout instead of table

### ✅ **Financial Reports**
- [ ] Visit: `http://your-vps:3000/accounting/financial-reports`
- [ ] Numbers show properly (no concatenation)
- [ ] Calculations are correct

### ✅ **Customer Detail**
- [ ] Visit: `http://your-vps:3000/accounting/customer-detail/27`
- [ ] No 500 errors
- [ ] Persian dates display correctly

## 📞 **Still Not Working?**

If you're still having issues:

1. **Check error logs:**
   ```bash
   pm2 logs
   tail -f /var/log/nginx/error.log  # if using nginx
   ```

2. **Check file permissions:**
   ```bash
   ls -la server.js views/customers/list.ejs
   chmod +x server.js  # if needed
   ```

3. **Verify file contents:**
   ```bash
   grep -n "card-view\|table-view" views/customers/list.ejs
   grep -n "moment-jalaali" server.js
   ```

4. **Check if git pull actually worked:**
   ```bash
   git log -1 --stat
   ```

The most common solution is the **force pull + complete PM2 restart** combination.
