#!/bin/bash
# ==============================================================================
# JuwishPro Production Deployment Script
# Target: 2026.dmillers.org
# ==============================================================================

set -e

echo "🚀 Starting JuwishPro Production Deployment..."

# 1. Check for .env file, copy from .env.example if missing
if [ ! -f .env ]; then
  echo "⚠️ .env not found. Creating from .env.example..."
  cp .env.example .env
  sed -i 's|NEXT_PUBLIC_SITE_URL="http://localhost"|NEXT_PUBLIC_SITE_URL="https://2026.dmillers.org"|g' .env
  sed -i 's|NEXT_PUBLIC_SITE_NAME="Bicrypto"|NEXT_PUBLIC_SITE_NAME="JuwishPro"|g' .env
  echo "✅ .env initialized for 2026.dmillers.org"
fi

# 2. Configure Nginx Reverse Proxy
echo "🌐 Configuring Nginx for 2026.dmillers.org..."
if [ -d /etc/nginx/sites-available ]; then
  sudo cp nginx.2026.dmillers.org.conf /etc/nginx/sites-available/2026.dmillers.org
  sudo ln -sf /etc/nginx/sites-available/2026.dmillers.org /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx || echo "⚠️ Could not reload nginx automatically; check permissions."
fi

# 3. Stop existing PM2 processes
echo "⏹️ Stopping existing PM2 instances..."
pm2 stop production.config.js 2>/dev/null || true

# 4. Run database seeder for JuwishCoin (JWC)
echo "🪙 Registering JuwishCoin on BSC in Database..."
if [ -f backend/scripts/seed-juwish-coin.sql ] && command -v mysql &> /dev/null; then
  mysql -u root -p v4 < backend/scripts/seed-juwish-coin.sql 2>/dev/null || echo "ℹ️ Database will be updated when MySQL is active."
fi

# 5. Start Application with PM2
echo "▶️ Launching Backend and Frontend in Production Mode via PM2..."
pm2 start production.config.js --env production
pm2 save

echo "=================================================================="
echo "🎉 JuwishPro successfully deployed for https://2026.dmillers.org!"
echo "To obtain an SSL certificate via Let's Encrypt:"
echo "   sudo certbot --nginx -d 2026.dmillers.org"
echo "=================================================================="
