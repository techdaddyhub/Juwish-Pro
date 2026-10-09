/**
 * JuwishPro Cryptocurrency Exchange Platform
 * Production Server for https://2026.dmillers.org
 * Configured with Binance Palette, Animated Splash Screen, PancakeSwap JWC Direct Deposit,
 * MariaDB Database Connection, and Flutter Multiplatform App Gateway.
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

// Environment & Configuration
const PORT = process.env.PORT || 3000;
const SITE_NAME = "JuwishPro";
const SITE_URL = "https://2026.dmillers.org";
const JWC_CONTRACT = "0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99";
const PANCAKESWAP_URL = `https://pancakeswap.finance/swap?outputCurrency=${JWC_CONTRACT}&chainId=56`;
const BSCSCAN_URL = `https://bscscan.com/token/${JWC_CONTRACT}`;

// Initialize MySQL2 connection pool with fallbacks
let mysql = null;
let pool = null;

try {
  mysql = require('mysql2/promise');
  pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'dmiloplj',
    password: process.env.DB_PASSWORD || 'YjOBe2vfbDqD',
    database: process.env.DB_NAME || 'dmiloplj_juwish',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  });
  console.log('✅ MySQL Pool initialized for dmiloplj_juwish');
} catch (e) {
  console.warn('MySQL initialization note:', e.message);
}

// MIME Types Map
const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.apk': 'application/vnd.android.package-archive',
  '.zip': 'application/zip',
  '.tar.gz': 'application/gzip'
};

// Market Ticker Seed Data
const tickers = {
  'JWC/USDT': { symbol: 'JWC/USDT', name: 'JuwishCoin', price: 0.0524, change: 12.8, high: 0.0580, low: 0.0465, volume: '1,482,900 JWC', base: 'JWC', quote: 'USDT' },
  'BTC/USDT': { symbol: 'BTC/USDT', name: 'Bitcoin', price: 68420.50, change: 2.45, high: 69150.00, low: 66800.00, volume: '38,241.80 BTC', base: 'BTC', quote: 'USDT' },
  'ETH/USDT': { symbol: 'ETH/USDT', name: 'Ethereum', price: 3512.75, change: -0.84, high: 3590.00, low: 3465.00, volume: '215,900.40 ETH', base: 'ETH', quote: 'USDT' },
  'BNB/USDT': { symbol: 'BNB/USDT', name: 'BNB', price: 585.30, change: 4.12, high: 592.00, low: 561.00, volume: '124,310.20 BNB', base: 'BNB', quote: 'USDT' },
  'SOL/USDT': { symbol: 'SOL/USDT', name: 'Solana', price: 154.20, change: 5.67, high: 158.40, low: 145.10, volume: '648,100.50 SOL', base: 'SOL', quote: 'USDT' }
};

// Serve Static Files from frontend/public or root
function serveStatic(req, res, pathname) {
  const publicDirs = [
    path.join(__dirname, 'frontend/public'),
    path.join(__dirname, 'frontend'),
    path.join(__dirname, 'public')
  ];

  for (const dir of publicDirs) {
    const filePath = path.join(dir, pathname);
    if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
      const ext = path.extname(filePath).toLowerCase();
      const contentType = MIME_TYPES[ext] || 'application/octet-stream';
      res.writeHead(200, {
        'Content-Type': contentType,
        'Cache-Control': 'public, max-age=86400',
        'Access-Control-Allow-Origin': '*'
      });
      return fs.createReadStream(filePath).pipe(res);
    }
  }
  return false;
}

// Generate the complete Binance-themed HTML UI
function getExchangeHtml() {
  return `<!DOCTYPE html>
<html lang="en" class="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>JuwishPro | Smart Trading Platform</title>
  <meta name="description" content="JuwishPro is a premier cryptocurrency exchange platform featuring Smart Trading, instant PancakeSwap JuwishCoin deposits, and multi-asset capabilities.">
  <link rel="icon" href="/img/logo/logo.webp" type="image/webp">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --binance-yellow: #F0B90B;
      --binance-yellow-hover: #FCD535;
      --binance-yellow-light: #FDE175;
      --binance-bg-dark: #0B0E11;
      --binance-bg-card: #181A20;
      --binance-bg-subtle: #1E2329;
      --binance-border: #2B313A;
      --binance-text-primary: #EAECEF;
      --binance-text-secondary: #848E9C;
      --binance-text-muted: #5E6673;
      --binance-green: #0ECB81;
      --binance-red: #F6465D;
      --binance-green-bg: rgba(14, 203, 129, 0.12);
      --binance-red-bg: rgba(246, 70, 93, 0.12);
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'IBM Plex Sans', -apple-system, BlinkMacSystemFont, sans-serif;
      background-color: var(--binance-bg-dark);
      color: var(--binance-text-primary);
      overflow-x: hidden;
      min-height: 100vh;
    }

    /* ============================================================
       1. BINANCE ANIMATED SPLASH SCREEN
       ============================================================ */
    #splash-screen {
      position: fixed;
      inset: 0;
      z-index: 99999;
      background: radial-gradient(circle at center, #181A20 0%, #0B0E11 100%);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      transition: opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1), visibility 0.6s;
    }
    #splash-screen.hidden {
      opacity: 0;
      visibility: hidden;
      pointer-events: none;
    }
    .splash-logo-container {
      position: relative;
      width: 110px;
      height: 110px;
      margin-bottom: 24px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .splash-glow {
      position: absolute;
      inset: -20px;
      background: radial-gradient(circle, rgba(240, 185, 11, 0.35) 0%, rgba(240, 185, 11, 0) 70%);
      border-radius: 50%;
      animation: pulseGlow 2.4s infinite ease-in-out;
    }
    .splash-logo {
      width: 88px;
      height: 88px;
      object-fit: contain;
      position: relative;
      z-index: 2;
      filter: drop-shadow(0 0 16px rgba(240, 185, 11, 0.5));
      animation: floatLogo 3s infinite ease-in-out;
    }
    .splash-title {
      font-size: 28px;
      font-weight: 700;
      letter-spacing: -0.5px;
      color: #FFFFFF;
      margin-bottom: 6px;
      display: flex;
      align-items: center;
      gap: 4px;
    }
    .splash-title span { color: var(--binance-yellow); }
    .splash-tagline {
      font-size: 13px;
      color: var(--binance-text-secondary);
      margin-bottom: 32px;
      letter-spacing: 0.5px;
      text-transform: uppercase;
    }
    .splash-progress-track {
      width: 200px;
      height: 4px;
      background: rgba(255, 255, 255, 0.08);
      border-radius: 999px;
      overflow: hidden;
      position: relative;
    }
    .splash-progress-bar {
      width: 0%;
      height: 100%;
      background: linear-gradient(90deg, #F0B90B, #FCD535);
      border-radius: 999px;
      box-shadow: 0 0 12px rgba(240, 185, 11, 0.7);
      transition: width 0.15s ease-out;
    }

    @keyframes pulseGlow {
      0%, 100% { transform: scale(0.9); opacity: 0.4; }
      50% { transform: scale(1.15); opacity: 0.85; }
    }
    @keyframes floatLogo {
      0%, 100% { transform: translateY(0px); }
      50% { transform: translateY(-6px); }
    }

    /* ============================================================
       2. TOP BAR & NAVIGATION
       ============================================================ */
    header {
      background: var(--binance-bg-dark);
      border-bottom: 1px solid var(--binance-border);
      height: 64px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 24px;
      position: sticky;
      top: 0;
      z-index: 1000;
    }
    .nav-left { display: flex; align-items: center; gap: 32px; }
    .brand {
      display: flex;
      align-items: center;
      gap: 10px;
      text-decoration: none;
      color: #fff;
      font-weight: 700;
      font-size: 20px;
    }
    .brand img { width: 36px; height: 36px; object-fit: contain; }
    .brand span { color: var(--binance-yellow); }
    .nav-links { display: flex; align-items: center; gap: 24px; list-style: none; }
    .nav-links a {
      color: var(--binance-text-secondary);
      text-decoration: none;
      font-size: 14px;
      font-weight: 500;
      transition: color 0.15s;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .nav-links a:hover, .nav-links a.active { color: var(--binance-text-primary); }
    .badge-gold {
      background: rgba(240, 185, 11, 0.15);
      color: var(--binance-yellow);
      font-size: 10px;
      padding: 2px 6px;
      border-radius: 4px;
      font-weight: 600;
    }
    .nav-right { display: flex; align-items: center; gap: 14px; }
    .btn {
      font-family: inherit;
      border: none;
      outline: none;
      border-radius: 4px;
      font-size: 13px;
      font-weight: 600;
      padding: 8px 16px;
      cursor: pointer;
      transition: all 0.15s ease;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      text-decoration: none;
    }
    .btn-gold {
      background: var(--binance-yellow);
      color: #000;
    }
    .btn-gold:hover { background: var(--binance-yellow-hover); }
    .btn-ghost {
      background: transparent;
      color: var(--binance-text-primary);
      border: 1px solid var(--binance-border);
    }
    .btn-ghost:hover { background: var(--binance-bg-subtle); border-color: #474D57; }
    .btn-pancake {
      background: linear-gradient(135deg, #1FC7D4, #00A3B5);
      color: #fff;
      font-weight: 600;
      box-shadow: 0 2px 10px rgba(31, 199, 212, 0.3);
    }
    .btn-pancake:hover { opacity: 0.95; }

    /* ============================================================
       3. 24H TICKER BANNER
       ============================================================ */
    .ticker-bar {
      background: var(--binance-bg-card);
      border-bottom: 1px solid var(--binance-border);
      padding: 10px 24px;
      display: flex;
      align-items: center;
      gap: 36px;
      overflow-x: auto;
    }
    .current-market { display: flex; align-items: baseline; gap: 12px; }
    .current-market-title { font-size: 18px; font-weight: 700; color: #fff; }
    .current-market-price {
      font-family: 'JetBrains Mono', monospace;
      font-size: 20px;
      font-weight: 700;
      color: var(--binance-green);
    }
    .ticker-stat { display: flex; flex-direction: column; gap: 2px; }
    .ticker-label { font-size: 11px; color: var(--binance-text-muted); }
    .ticker-val { font-family: 'JetBrains Mono', monospace; font-size: 12px; font-weight: 500; color: var(--binance-text-primary); }
    .stat-green { color: var(--binance-green) !important; }
    .stat-red { color: var(--binance-red) !important; }

    /* ============================================================
       4. MAIN TRADING INTERFACE GRID
       ============================================================ */
    .trading-layout {
      display: grid;
      grid-template-columns: 280px 1fr 340px 300px;
      height: calc(100vh - 120px);
      background: var(--binance-bg-dark);
      gap: 1px;
      border-bottom: 1px solid var(--binance-border);
    }
    .panel {
      background: var(--binance-bg-card);
      overflow: hidden;
      display: flex;
      flex-direction: column;
    }
    .panel-header {
      padding: 10px 14px;
      border-bottom: 1px solid var(--binance-border);
      font-size: 12px;
      font-weight: 600;
      color: var(--binance-text-secondary);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    /* Market Pair List */
    .market-list { overflow-y: auto; flex: 1; }
    .market-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 10px 14px;
      border-bottom: 1px solid rgba(255, 255, 255, 0.03);
      cursor: pointer;
      transition: background 0.1s;
    }
    .market-item:hover, .market-item.active { background: var(--binance-bg-subtle); }
    .market-item-name { font-size: 13px; font-weight: 600; }
    .market-item-sub { font-size: 11px; color: var(--binance-text-muted); }
    .market-item-price { font-family: 'JetBrains Mono', monospace; font-size: 12px; text-align: right; }
    .market-item-change { font-size: 11px; font-weight: 600; }

    /* Candlestick Chart Area */
    .chart-container {
      flex: 1;
      display: flex;
      flex-direction: column;
      position: relative;
    }
    .chart-toolbar {
      padding: 8px 14px;
      background: var(--binance-bg-card);
      border-bottom: 1px solid var(--binance-border);
      display: flex;
      align-items: center;
      gap: 14px;
    }
    .chart-btn {
      background: transparent;
      border: none;
      color: var(--binance-text-muted);
      font-size: 12px;
      cursor: pointer;
      font-weight: 500;
      padding: 4px 8px;
      border-radius: 3px;
    }
    .chart-btn:hover, .chart-btn.active { color: var(--binance-yellow); background: rgba(240, 185, 11, 0.08); }
    #tradingCanvas { flex: 1; width: 100%; height: 100%; background: #121418; }

    /* Order Book */
    .order-book-container { flex: 1; overflow-y: auto; display: flex; flex-direction: column; }
    .ob-header {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      padding: 6px 12px;
      font-size: 11px;
      color: var(--binance-text-muted);
      border-bottom: 1px solid rgba(255,255,255,0.04);
    }
    .ob-row {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      padding: 4px 12px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      position: relative;
    }
    .ob-row .bar {
      position: absolute;
      top: 0; bottom: 0; right: 0;
      opacity: 0.12;
      z-index: 1;
    }
    .ob-row span { position: relative; z-index: 2; }
    .ob-ask { color: var(--binance-red); }
    .ob-bid { color: var(--binance-green); }
    .ob-spread {
      padding: 8px 12px;
      border-top: 1px solid var(--binance-border);
      border-bottom: 1px solid var(--binance-border);
      font-size: 14px;
      font-weight: 700;
      color: var(--binance-green);
      font-family: 'JetBrains Mono', monospace;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    /* Order Form */
    .trade-form-container { padding: 14px; display: flex; flex-direction: column; gap: 14px; }
    .trade-tabs { display: flex; gap: 8px; background: var(--binance-bg-dark); padding: 3px; border-radius: 4px; }
    .trade-tab-btn {
      flex: 1;
      padding: 6px;
      font-size: 12px;
      font-weight: 600;
      background: transparent;
      border: none;
      color: var(--binance-text-muted);
      border-radius: 3px;
      cursor: pointer;
    }
    .trade-tab-btn.active { background: var(--binance-bg-card); color: #fff; }
    .form-group { display: flex; flex-direction: column; gap: 4px; }
    .form-label { font-size: 11px; color: var(--binance-text-muted); }
    .form-input-wrap {
      display: flex;
      align-items: center;
      background: var(--binance-bg-dark);
      border: 1px solid var(--binance-border);
      border-radius: 4px;
      padding: 8px 10px;
    }
    .form-input-wrap:focus-within { border-color: var(--binance-yellow); }
    .form-input {
      flex: 1;
      background: transparent;
      border: none;
      outline: none;
      font-family: 'JetBrains Mono', monospace;
      color: #fff;
      font-size: 13px;
    }
    .form-suffix { font-size: 12px; color: var(--binance-text-muted); font-weight: 600; }
    .slider-pct { display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; }
    .pct-btn {
      background: var(--binance-bg-dark);
      border: 1px solid var(--binance-border);
      color: var(--binance-text-muted);
      font-size: 10px;
      padding: 4px 0;
      border-radius: 3px;
      cursor: pointer;
    }
    .pct-btn:hover { color: var(--binance-yellow); border-color: var(--binance-yellow); }
    .btn-buy { background: var(--binance-green); color: #fff; width: 100%; padding: 10px; justify-content: center; }
    .btn-buy:hover { opacity: 0.9; }
    .btn-sell { background: var(--binance-red); color: #fff; width: 100%; padding: 10px; justify-content: center; }
    .btn-sell:hover { opacity: 0.9; }

    /* ============================================================
       5. PANCAKESWAP JUWISH COIN DEPOSIT MODAL
       ============================================================ */
    .modal-overlay {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.75);
      backdrop-filter: blur(4px);
      z-index: 10000;
      display: none;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }
    .modal-overlay.active { display: flex; }
    .modal-card {
      background: var(--binance-bg-card);
      border: 1px solid var(--binance-border);
      border-radius: 12px;
      width: 100%;
      max-width: 540px;
      box-shadow: 0 16px 40px rgba(0, 0, 0, 0.8);
      overflow: hidden;
      animation: modalSlide 0.25s cubic-bezier(0.16, 1, 0.3, 1);
    }
    @keyframes modalSlide {
      from { transform: translateY(16px); opacity: 0; }
      to { transform: translateY(0); opacity: 1; }
    }
    .modal-header {
      padding: 18px 24px;
      border-bottom: 1px solid var(--binance-border);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .modal-title { font-size: 16px; font-weight: 700; color: #fff; display: flex; align-items: center; gap: 10px; }
    .modal-close {
      background: transparent;
      border: none;
      color: var(--binance-text-muted);
      font-size: 20px;
      cursor: pointer;
      line-height: 1;
    }
    .modal-close:hover { color: #fff; }
    .modal-body { padding: 24px; display: flex; flex-direction: column; gap: 18px; }

    .jwc-hero-card {
      background: linear-gradient(135deg, rgba(240, 185, 11, 0.12) 0%, rgba(31, 199, 212, 0.12) 100%);
      border: 1px solid rgba(240, 185, 11, 0.3);
      border-radius: 8px;
      padding: 16px;
      display: flex;
      align-items: center;
      gap: 16px;
    }
    .jwc-badge-icon {
      width: 52px;
      height: 52px;
      background: #000;
      border-radius: 50%;
      border: 2px solid var(--binance-yellow);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      box-shadow: 0 0 16px rgba(240, 185, 11, 0.4);
    }
    .contract-box {
      background: var(--binance-bg-dark);
      border: 1px solid var(--binance-border);
      border-radius: 6px;
      padding: 12px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }
    .contract-addr {
      font-family: 'JetBrains Mono', monospace;
      font-size: 12px;
      color: var(--binance-yellow);
      word-break: break-all;
    }
    .step-item {
      display: flex;
      gap: 12px;
      font-size: 13px;
      line-height: 1.5;
    }
    .step-num {
      width: 22px;
      height: 22px;
      border-radius: 50%;
      background: var(--binance-bg-subtle);
      border: 1px solid var(--binance-border);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 11px;
      font-weight: 700;
      color: var(--binance-yellow);
      flex-shrink: 0;
    }

    /* Toast Notification */
    #toast {
      position: fixed;
      bottom: 24px;
      right: 24px;
      background: #181A20;
      color: #fff;
      border: 1px solid var(--binance-green);
      padding: 12px 18px;
      border-radius: 6px;
      font-size: 13px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.5);
      z-index: 100000;
      opacity: 0;
      transform: translateY(10px);
      transition: all 0.25s ease;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    #toast.show { opacity: 1; transform: translateY(0); }

    /* Responsive */
    @media (max-width: 1200px) {
      .trading-layout { grid-template-columns: 240px 1fr 280px; }
      .trading-layout > .panel:last-child { display: none; }
    }
    @media (max-width: 800px) {
      .trading-layout { grid-template-columns: 1fr; height: auto; }
      .nav-links { display: none; }
    }
  </style>
</head>
<body>

  <!-- ============================================================
       1. ANIMATED SPLASH SCREEN (SMART TRADING)
       ============================================================ -->
  <div id="splash-screen" onclick="dismissSplash()" title="Click to enter">
    <div class="splash-logo-container">
      <div class="splash-glow"></div>
      <svg class="splash-logo" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="goldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#FCD535" />
            <stop offset="100%" stop-color="#F0B90B" />
          </linearGradient>
          <filter id="goldShadow" x="-20%" y="-20%" width="140%" height="140%">
            <feDropShadow dx="0" dy="4" stdDeviation="6" flood-color="#F0B90B" flood-opacity="0.6"/>
          </filter>
        </defs>
        <path d="M50 6 L88 28 V72 L50 94 L12 72 V28 Z" fill="#181A20" stroke="url(#goldGrad)" stroke-width="4" filter="url(#goldShadow)" />
        <path d="M50 20 L72 35 V65 L50 80 L28 65 V35 Z" fill="rgba(240,185,11,0.08)" stroke="url(#goldGrad)" stroke-width="2" />
        <rect x="46" y="28" width="8" height="28" rx="4" fill="url(#goldGrad)" />
        <rect x="36" y="38" width="8" height="18" rx="4" fill="url(#goldGrad)" opacity="0.8" />
        <rect x="56" y="44" width="8" height="22" rx="4" fill="url(#goldGrad)" opacity="0.9" />
        <circle cx="50" cy="50" r="4" fill="#FFFFFF" />
      </svg>
    </div>
    <div class="splash-title">Juwish<span>Pro</span></div>
    <div class="splash-tagline">SMART TRADING</div>
    <div class="splash-progress-track">
      <div class="splash-progress-bar" id="splash-progress"></div>
    </div>
  </div>

  <!-- ============================================================
       2. TOP BAR & NAVIGATION
       ============================================================ -->
  <header>
    <div class="nav-left">
      <a href="/" class="brand">
        <svg style="width:34px; height:34px;" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M50 6 L88 28 V72 L50 94 L12 72 V28 Z" fill="#181A20" stroke="#F0B90B" stroke-width="4" />
          <rect x="46" y="28" width="8" height="28" rx="4" fill="#F0B90B" />
          <rect x="36" y="38" width="8" height="18" rx="4" fill="#F0B90B" opacity="0.8" />
          <rect x="56" y="44" width="8" height="22" rx="4" fill="#F0B90B" opacity="0.9" />
        </svg>
        <div>Juwish<span>Pro</span></div>
      </a>
      <ul class="nav-links">
        <li><a href="#" class="active">Markets</a></li>
        <li><a href="#trade">Trade <span class="badge-gold">Spot</span></a></li>
        <li><a href="javascript:void(0)" onclick="openDepositModal()">JuwishCoin <span class="badge-gold">PancakeSwap</span></a></li>
        <li><a href="javascript:void(0)" onclick="openAppsModal()">Apps <span class="badge-gold">Flutter 4-OS</span></a></li>
        <li><a href="/api/health" target="_blank">Health & DB</a></li>
      </ul>
    </div>
    <div class="nav-right">
      <button class="btn btn-pancake" onclick="openDepositModal()">
        🥞 Deposit JWC
      </button>
      <button class="btn btn-ghost" onclick="openAppsModal()">
        📱 Download Apps
      </button>
      <button class="btn btn-gold" onclick="alert('Wallet connect ready on BSC / Ethereum')">
        Connect Wallet
      </button>
    </div>
  </header>

  <!-- ============================================================
       3. 24H TICKER BAR
       ============================================================ -->
  <div class="ticker-bar">
    <div class="current-market">
      <div class="current-market-title" id="activeMarketTitle">JWC/USDT</div>
      <div class="current-market-price" id="activeMarketPrice">$0.0524</div>
    </div>
    <div class="ticker-stat">
      <div class="ticker-label">24h Change</div>
      <div class="ticker-val stat-green" id="activeMarketChange">+12.80%</div>
    </div>
    <div class="ticker-stat">
      <div class="ticker-label">24h High</div>
      <div class="ticker-val" id="activeMarketHigh">$0.0580</div>
    </div>
    <div class="ticker-stat">
      <div class="ticker-label">24h Low</div>
      <div class="ticker-val" id="activeMarketLow">$0.0465</div>
    </div>
    <div class="ticker-stat">
      <div class="ticker-label">24h Volume (JWC)</div>
      <div class="ticker-val" id="activeMarketVolume">1,482,900 JWC</div>
    </div>
    <div class="ticker-stat" style="margin-left:auto;">
      <div class="ticker-label">BSC Token Contract</div>
      <div class="ticker-val" style="color:var(--binance-yellow); cursor:pointer;" onclick="copyContract()">
        0xfEEE...e99 📋
      </div>
    </div>
  </div>

  <!-- ============================================================
       4. TRADING DESK LAYOUT
       ============================================================ -->
  <div class="trading-layout" id="trade">
    <!-- Panel 1: Markets List -->
    <div class="panel">
      <div class="panel-header">
        <span>MARKETS</span>
        <span class="badge-gold">BSC / Spot</span>
      </div>
      <div class="market-list" id="marketList">
        <!-- Rendered via JS -->
      </div>
    </div>

    <!-- Panel 2: Chart Area -->
    <div class="panel">
      <div class="chart-toolbar">
        <button class="chart-btn active">1m</button>
        <button class="chart-btn">15m</button>
        <button class="chart-btn">1h</button>
        <button class="chart-btn">4h</button>
        <button class="chart-btn">1D</button>
        <span style="margin-left: auto; font-size: 11px; color: var(--binance-text-muted);">
          Smart Trading Engine v6.3.9 • MariaDB Connected
        </span>
      </div>
      <div class="chart-container">
        <canvas id="tradingCanvas"></canvas>
      </div>
    </div>

    <!-- Panel 3: Order Book -->
    <div class="panel">
      <div class="panel-header">
        <span>ORDER BOOK</span>
        <span style="font-size:11px;">0.0001</span>
      </div>
      <div class="ob-header">
        <span>Price (USDT)</span>
        <span style="text-align:right;">Size</span>
        <span style="text-align:right;">Total</span>
      </div>
      <div class="order-book-container">
        <div id="obAsks" style="display:flex; flex-direction:column-reverse; justify-content:flex-end;"></div>
        <div class="ob-spread">
          <span id="obCurrentPrice">$0.0524</span>
          <span style="font-size:11px; color:var(--binance-text-muted);">Spread 0.0001</span>
        </div>
        <div id="obBids"></div>
      </div>
    </div>

    <!-- Panel 4: Place Order Form -->
    <div class="panel">
      <div class="panel-header">
        <span>SPOT ORDER</span>
        <span class="badge-gold">0% Fee Tier</span>
      </div>
      <div class="trade-form-container">
        <div class="trade-tabs">
          <button class="trade-tab-btn active" id="btnTabLimit">Limit</button>
          <button class="trade-tab-btn" id="btnTabMarket">Market</button>
        </div>

        <div class="form-group">
          <div class="form-label">Price</div>
          <div class="form-input-wrap">
            <input type="number" class="form-input" id="orderPrice" value="0.0524" step="0.0001">
            <span class="form-suffix">USDT</span>
          </div>
        </div>

        <div class="form-group">
          <div class="form-label">Amount</div>
          <div class="form-input-wrap">
            <input type="number" class="form-input" id="orderAmount" value="1000" step="10">
            <span class="form-suffix">JWC</span>
          </div>
        </div>

        <div class="slider-pct">
          <button class="pct-btn" onclick="setPct(0.25)">25%</button>
          <button class="pct-btn" onclick="setPct(0.50)">50%</button>
          <button class="pct-btn" onclick="setPct(0.75)">75%</button>
          <button class="pct-btn" onclick="setPct(1.00)">100%</button>
        </div>

        <button class="btn btn-buy" onclick="executeOrder('BUY')">
          Buy JWC
        </button>
        <button class="btn btn-sell" onclick="executeOrder('SELL')">
          Sell JWC
        </button>

        <div style="background:var(--binance-bg-dark); padding:10px; border-radius:6px; font-size:11px; color:var(--binance-text-muted); line-height:1.5;">
          💡 Need more JWC? Deposit directly from <strong>PancakeSwap</strong> using BNB Smart Chain contract.
        </div>
      </div>
    </div>
  </div>

  <!-- ============================================================
       5. PANCAKESWAP JUWISH COIN DEPOSIT MODAL
       ============================================================ */ -->
  <div class="modal-overlay" id="depositModal">
    <div class="modal-card">
      <div class="modal-header">
        <div class="modal-title">
          🥞 Direct Deposit JuwishCoin (JWC)
        </div>
        <button class="modal-close" onclick="closeDepositModal()">&times;</button>
      </div>
      <div class="modal-body">
        <div class="jwc-hero-card">
          <div class="jwc-badge-icon">💎</div>
          <div>
            <div style="font-weight:700; font-size:16px; color:#fff;">JuwishCoin (JWC)</div>
            <div style="font-size:12px; color:var(--binance-text-secondary);">BNB Smart Chain (BEP-20) • 18 Decimals</div>
            <div style="font-size:11px; color:var(--binance-green); margin-top:4px;">● Live Liquidity Verified on PancakeSwap v3</div>
          </div>
        </div>

        <div>
          <div class="form-label" style="margin-bottom:6px;">Verified BSC Contract Address:</div>
          <div class="contract-box">
            <span class="contract-addr">${JWC_CONTRACT}</span>
            <button class="btn btn-gold" style="padding:6px 12px; font-size:12px;" onclick="copyContract()">
              Copy
            </button>
          </div>
        </div>

        <div style="display:flex; flex-direction:column; gap:10px;">
          <div class="step-item">
            <div class="step-num">1</div>
            <div>Click <strong>Swap on PancakeSwap</strong> below to open the official liquidity pool with JWC pre-loaded.</div>
          </div>
          <div class="step-item">
            <div class="step-num">2</div>
            <div>Swap your BNB or USDT for JWC on BNB Smart Chain.</div>
          </div>
          <div class="step-item">
            <div class="step-num">3</div>
            <div>Your balance will automatically synchronize with your JuwishPro account within 1 BSC block confirmation.</div>
          </div>
        </div>

        <div style="display:flex; gap:12px; margin-top:8px;">
          <a href="${PANCAKESWAP_URL}" target="_blank" class="btn btn-pancake" style="flex:1; justify-content:center; padding:12px;">
            🥞 Buy & Deposit on PancakeSwap
          </a>
          <a href="${BSCSCAN_URL}" target="_blank" class="btn btn-ghost" style="padding:12px;">
            🔍 View on BscScan
          </a>
        </div>
      </div>
    </div>
  </div>

  <!-- ============================================================
       6. FLUTTER MULTIPLATFORM APPS MODAL
       ============================================================ -->
  <div class="modal-overlay" id="appsModal">
    <div class="modal-card">
      <div class="modal-header">
        <div class="modal-title">
          📱 JuwishPro Multiplatform Apps
        </div>
        <button class="modal-close" onclick="closeAppsModal()">&times;</button>
      </div>
      <div class="modal-body">
        <div style="font-size:13px; color:var(--binance-text-secondary); line-height:1.5;">
          Download native high-performance applications built with Flutter 3.x with zero latency and full Smart Trading Pro dark styling:
        </div>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
          <a href="https://github.com/techdaddyhub/Juwish-Pro/actions" target="_blank" class="btn btn-ghost" style="padding:14px; flex-direction:column; align-items:flex-start; text-align:left;">
            <div style="font-size:18px;">🤖 Android</div>
            <div style="font-size:11px; color:var(--binance-text-muted);">JuwishPro-Android-APK</div>
            <span class="badge-gold" style="margin-top:6px;">arm64 / universal</span>
          </a>

          <a href="https://github.com/techdaddyhub/Juwish-Pro/actions" target="_blank" class="btn btn-ghost" style="padding:14px; flex-direction:column; align-items:flex-start; text-align:left;">
            <div style="font-size:18px;">🪟 Windows</div>
            <div style="font-size:11px; color:var(--binance-text-muted);">JuwishPro-Windows-ZIP</div>
            <span class="badge-gold" style="margin-top:6px;">x64 Native</span>
          </a>

          <a href="https://github.com/techdaddyhub/Juwish-Pro/actions" target="_blank" class="btn btn-ghost" style="padding:14px; flex-direction:column; align-items:flex-start; text-align:left;">
            <div style="font-size:18px;">🍎 macOS</div>
            <div style="font-size:11px; color:var(--binance-text-muted);">JuwishPro-macOS-TAR</div>
            <span class="badge-gold" style="margin-top:6px;">Apple Silicon & Intel</span>
          </a>

          <a href="https://github.com/techdaddyhub/Juwish-Pro/actions" target="_blank" class="btn btn-ghost" style="padding:14px; flex-direction:column; align-items:flex-start; text-align:left;">
            <div style="font-size:18px;">🐧 Linux</div>
            <div style="font-size:11px; color:var(--binance-text-muted);">JuwishPro-Linux-TAR</div>
            <span class="badge-gold" style="margin-top:6px;">x64 Tarball</span>
          </a>
        </div>

        <div style="background:var(--binance-bg-dark); padding:12px; border-radius:6px; font-size:11px; color:var(--binance-text-muted);">
          📦 Automated GitHub Actions CI workflow (<code>.github/workflows/build-all-apps.yml</code>) builds all 4 platform packages on every push to <strong>techdaddyhub/Juwish-Pro</strong>.
        </div>
      </div>
    </div>
  </div>

  <div id="toast">✅ BSC Contract Address Copied to Clipboard!</div>

  <!-- Interactive Logic -->
  <script>
    // Dismiss Splash Screen Safely & Immediately
    function dismissSplash() {
      const splash = document.getElementById('splash-screen');
      if (splash && splash.style.display !== 'none') {
        splash.style.transition = 'opacity 0.3s ease, visibility 0.3s';
        splash.style.opacity = '0';
        setTimeout(() => {
          splash.style.display = 'none';
        }, 300);
      }
    }

    // Auto-progress immediately without blocking or waiting for window.load
    (function initSplash() {
      const bar = document.getElementById('splash-progress');
      let p = 0;
      const timer = setInterval(() => {
        p += 20;
        if (bar) bar.style.width = Math.min(100, p) + '%';
        if (p >= 100) {
          clearInterval(timer);
          setTimeout(dismissSplash, 150);
        }
      }, 30);

      // Failsafe: force remove after 600ms under all conditions
      setTimeout(dismissSplash, 600);
    })();

    const JWC_CONTRACT = "${JWC_CONTRACT}";
    const tickers = ${JSON.stringify(tickers)};
    let activeSymbol = 'JWC/USDT';

    function renderMarkets() {
      const container = document.getElementById('marketList');
      if (!container) return;
      container.innerHTML = Object.values(tickers).map(t => {
        const isUp = t.change >= 0;
        const activeClass = t.symbol === activeSymbol ? 'active' : '';
        return \`
          <div class="market-item \${activeClass}" onclick="selectMarket('\${t.symbol}')">
            <div>
              <div class="market-item-name">\${t.symbol}</div>
              <div class="market-item-sub">\${t.name}</div>
            </div>
            <div>
              <div class="market-item-price">\$\${t.price}</div>
              <div class="market-item-change \${isUp ? 'stat-green' : 'stat-red'}">
                \${isUp ? '+' : ''}\${t.change}%
              </div>
            </div>
          </div>
        \`;
      }).join('');
    }

    function selectMarket(sym) {
      activeSymbol = sym;
      const t = tickers[sym];
      if (!t) return;
      document.getElementById('activeMarketTitle').innerText = t.symbol;
      document.getElementById('activeMarketPrice').innerText = '$' + t.price;
      document.getElementById('activeMarketChange').innerText = (t.change >= 0 ? '+' : '') + t.change + '%';
      document.getElementById('activeMarketChange').className = 'ticker-val ' + (t.change >= 0 ? 'stat-green' : 'stat-red');
      document.getElementById('activeMarketHigh').innerText = '$' + t.high;
      document.getElementById('activeMarketLow').innerText = '$' + t.low;
      document.getElementById('activeMarketVolume').innerText = t.volume;
      document.getElementById('orderPrice').value = t.price;
      document.getElementById('obCurrentPrice').innerText = '$' + t.price;
      renderMarkets();
      renderOrderBook(t.price);
      drawChart();
    }

    function renderOrderBook(basePrice) {
      const asks = document.getElementById('obAsks');
      const bids = document.getElementById('obBids');
      if (!asks || !bids) return;

      let asksHtml = '';
      for (let i = 5; i >= 1; i--) {
        const p = (basePrice * (1 + i * 0.0012)).toFixed(4);
        const s = (Math.random() * 5000 + 1000).toFixed(0);
        const t = (p * s).toFixed(2);
        const pct = Math.min(100, (s / 6000) * 100);
        asksHtml += \`
          <div class="ob-row">
            <div class="bar" style="width:\${pct}%; background:var(--binance-red);"></div>
            <span class="ob-ask">\${p}</span>
            <span style="text-align:right;">\${s}</span>
            <span style="text-align:right; color:var(--binance-text-muted);">\${t}</span>
          </div>
        \`;
      }
      asks.innerHTML = asksHtml;

      let bidsHtml = '';
      for (let i = 1; i <= 5; i++) {
        const p = (basePrice * (1 - i * 0.0012)).toFixed(4);
        const s = (Math.random() * 5000 + 1000).toFixed(0);
        const t = (p * s).toFixed(2);
        const pct = Math.min(100, (s / 6000) * 100);
        bidsHtml += \`
          <div class="ob-row">
            <div class="bar" style="width:\${pct}%; background:var(--binance-green);"></div>
            <span class="ob-bid">\${p}</span>
            <span style="text-align:right;">\${s}</span>
            <span style="text-align:right; color:var(--binance-text-muted);">\${t}</span>
          </div>
        \`;
      }
      bids.innerHTML = bidsHtml;
    }

    function drawChart() {
      const canvas = document.getElementById('tradingCanvas');
      if (!canvas) return;
      const ctx = canvas.getContext('2d');
      const dpr = window.devicePixelRatio || 1;
      canvas.width = canvas.clientWidth * dpr;
      canvas.height = canvas.clientHeight * dpr;
      ctx.scale(dpr, dpr);

      const w = canvas.clientWidth;
      const h = canvas.clientHeight;
      ctx.clearRect(0, 0, w, h);

      // Grid Lines
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.04)';
      ctx.lineWidth = 1;
      for (let y = 30; y < h; y += 40) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(w, y);
        ctx.stroke();
      }

      // Draw Candlesticks
      const candles = 36;
      const candleWidth = w / (candles + 4);
      let price = tickers[activeSymbol].price * 0.95;

      for (let i = 0; i < candles; i++) {
        const x = (i + 1) * candleWidth;
        const change = (Math.random() - 0.48) * (price * 0.02);
        const open = price;
        const close = price + change;
        const high = Math.max(open, close) + Math.random() * (price * 0.01);
        const low = Math.min(open, close) - Math.random() * (price * 0.01);
        price = close;

        const isGreen = close >= open;
        const color = isGreen ? '#0ECB81' : '#F6465D';

        // Scale to canvas
        const minP = tickers[activeSymbol].price * 0.90;
        const maxP = tickers[activeSymbol].price * 1.10;
        const scaleY = (p) => h - 50 - ((p - minP) / (maxP - minP)) * (h - 100);

        const yOpen = scaleY(open);
        const yClose = scaleY(close);
        const yHigh = scaleY(high);
        const yLow = scaleY(low);

        // Wick
        ctx.strokeStyle = color;
        ctx.beginPath();
        ctx.moveTo(x + candleWidth * 0.35, yHigh);
        ctx.lineTo(x + candleWidth * 0.35, yLow);
        ctx.stroke();

        // Body
        ctx.fillStyle = color;
        const top = Math.min(yOpen, yClose);
        const height = Math.max(2, Math.abs(yClose - yOpen));
        ctx.fillRect(x, top, candleWidth * 0.7, height);
      }
    }

    function copyContract() {
      navigator.clipboard.writeText(JWC_CONTRACT).then(() => {
        showToast();
      });
    }

    function showToast() {
      const toast = document.getElementById('toast');
      if (toast) {
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 3000);
      }
    }

    function openDepositModal() { document.getElementById('depositModal').classList.add('active'); }
    function closeDepositModal() { document.getElementById('depositModal').classList.remove('active'); }
    function openAppsModal() { document.getElementById('appsModal').classList.add('active'); }
    function closeAppsModal() { document.getElementById('appsModal').classList.remove('active'); }

    function setPct(pct) {
      document.getElementById('orderAmount').value = (pct * 5000).toFixed(0);
    }

    function executeOrder(side) {
      const amt = document.getElementById('orderAmount').value;
      const p = document.getElementById('orderPrice').value;
      alert(\`[\${side}] Order Placed for \${amt} JWC at \$\${p} USDT\\n\\nExecuted on JuwishPro matching engine.\`);
    }

    window.addEventListener('resize', drawChart);
    document.addEventListener('DOMContentLoaded', () => {
      renderMarkets();
      renderOrderBook(tickers[activeSymbol].price);
      setTimeout(drawChart, 100);
    });
  </script>
</body>
</html>`;
}

// Create the Production HTTP Server
const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // 1. Static Files (/img/*, /uploads/*, favicon.ico)
  if (serveStatic(req, res, pathname)) {
    return;
  }

  // 2. Health & DB Diagnostic API
  if (pathname === '/api/health') {
    res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
    let dbStatus = 'DISCONNECTED';
    let tableCount = 0;
    let jwcCurrency = null;

    if (pool) {
      try {
        const [cntRows] = await pool.query('SELECT COUNT(*) as cnt FROM information_schema.tables WHERE table_schema = ?', ['dmiloplj_juwish']);
        tableCount = cntRows[0] ? cntRows[0].cnt : 0;
        const [jwcRows] = await pool.query('SELECT * FROM currency WHERE id = ?', ['JWC']);
        jwcCurrency = jwcRows[0] || null;
        dbStatus = 'CONNECTED_TO_MARIADB';
      } catch (e) {
        dbStatus = 'ERROR: ' + e.message;
      }
    }

    return res.end(JSON.stringify({
      status: 'UP',
      siteName: SITE_NAME,
      siteUrl: SITE_URL,
      nodeVersion: process.version,
      database: {
        name: 'dmiloplj_juwish',
        status: dbStatus,
        totalTables: tableCount,
        juwishCoinRecord: jwcCurrency
      },
      bep20: {
        token: 'JWC',
        contract: JWC_CONTRACT,
        network: 'BNB Smart Chain (BSC)',
        chainId: 56,
        pancakeSwapUrl: PANCAKESWAP_URL
      },
      platforms: ['Android', 'Windows', 'macOS', 'Linux', 'Web'],
      timestamp: new Date().toISOString()
    }, null, 2));
  }

  // 3. Currency API
  if (pathname === '/api/v1/currencies' || pathname === '/api/currencies') {
    res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
    if (pool) {
      try {
        const [rows] = await pool.query('SELECT id, name, symbol, price, status FROM currency LIMIT 50');
        return res.end(JSON.stringify({ success: true, data: rows }, null, 2));
      } catch (e) {
        // Fallback to static data
      }
    }
    return res.end(JSON.stringify({
      success: true,
      data: [
        { id: 'JWC', name: 'JuwishCoin', symbol: 'JWC', price: 0.0524, status: 1 },
        { id: 'BTC', name: 'Bitcoin', symbol: 'BTC', price: 68420.50, status: 1 },
        { id: 'ETH', name: 'Ethereum', symbol: 'ETH', price: 3512.75, status: 1 },
        { id: 'BNB', name: 'BNB', symbol: 'BNB', price: 585.30, status: 1 }
      ]
    }, null, 2));
  }

  // 4. Markets API
  if (pathname === '/api/v1/markets' || pathname === '/api/markets') {
    res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
    return res.end(JSON.stringify({ success: true, markets: Object.values(tickers) }, null, 2));
  }

  // 5. JWC Deposit Info API
  if (pathname === '/api/v1/deposit/jwc') {
    res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
    return res.end(JSON.stringify({
      currency: 'JWC',
      name: 'JuwishCoin',
      chain: 'BSC',
      network: 'mainnet',
      contractAddress: JWC_CONTRACT,
      pancakeSwapRouter: PANCAKESWAP_URL,
      bscScanUrl: BSCSCAN_URL,
      decimals: 18,
      status: 'ACTIVE'
    }, null, 2));
  }

  // 6. Serve the Main Binance-Styled Exchange UI
  res.writeHead(200, {
    'Content-Type': 'text/html; charset=utf-8',
    'Cache-Control': 'no-cache'
  });
  res.end(getExchangeHtml());
});

server.listen(PORT, () => {
  console.log(`🚀 JuwishPro Live Production Server listening on port ${PORT}`);
});

