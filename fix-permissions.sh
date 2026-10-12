#!/bin/bash
# ==============================================================================
# JuwishPro - cPanel Permission Fixer Script for 2026.dmillers.org
# ==============================================================================

echo "=========================================================="
echo " Setting Full Required Permissions for JuwishPro on cPanel"
echo "=========================================================="

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR"

echo "[1/4] Setting standard directory permissions (755)..."
find . -type d -exec chmod 755 {} \;

echo "[2/4] Setting standard file permissions (644)..."
find . -type f -exec chmod 644 {} \;

echo "[3/4] Granting full write permissions to storage & bootstrap/cache (775)..."
mkdir -p storage/framework/views storage/framework/sessions storage/framework/cache storage/app/public storage/logs storage/debugbar storage/untranslated bootstrap/cache
chmod -R 775 storage
chmod -R 775 bootstrap/cache
chmod 644 .env .htaccess

echo "[4/4] Ensuring Artisan is executable..."
chmod 755 artisan

echo "=========================================================="
echo " Permissions successfully applied!"
echo " Ready for 2026.dmillers.org"
echo "=========================================================="

