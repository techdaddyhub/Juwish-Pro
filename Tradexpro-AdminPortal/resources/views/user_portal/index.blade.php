<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? 'JuwishPro - Smart Crypto Exchange & PancakeSwap JWC Gateway' }}</title>
    <meta name="description" content="Trade JuwishCoin (JWC), Bitcoin, Ethereum and digital assets on JuwishPro with institutional liquidity and automated PancakeSwap on-chain deposits.">
    <link rel="icon" type="image/svg+xml" href="{{ asset('assets/landing/images/logo.svg') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <style>
        :root {
            --bg-main: #0B0E11;
            --bg-card: #181A20;
            --bg-card-hover: #1E2329;
            --bg-input: #2B313A;
            --border-color: #2B313A;
            --primary-gold: #F0B90B;
            --primary-gold-hover: #FCD535;
            --text-primary: #EAECEF;
            --text-secondary: #848E9C;
            --text-muted: #5E6673;
            --color-up: #0ECB81;
            --color-down: #F6465D;
            --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            --font-mono: 'JetBrains Mono', monospace;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: var(--bg-main);
            color: var(--text-primary);
            font-family: var(--font-sans);
            line-height: 1.5;
            overflow-x: hidden;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        /* Top Ticker Marquee */
        .ticker-bar {
            background: #12161C;
            border-bottom: 1px solid var(--border-color);
            padding: 8px 24px;
            font-size: 13px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            overflow-x: auto;
            white-space: nowrap;
            gap: 20px;
        }

        .ticker-item {
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .ticker-symbol {
            font-weight: 600;
            color: var(--text-primary);
        }

        .ticker-price {
            font-family: var(--font-mono);
            font-weight: 500;
        }

        .up { color: var(--color-up); }
        .down { color: var(--color-down); }

        /* Navigation */
        .navbar {
            background: var(--bg-card);
            border-bottom: 1px solid var(--border-color);
            padding: 14px 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .navbar-brand {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .navbar-brand img {
            width: 36px;
            height: 36px;
        }

        .brand-text {
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .brand-text span {
            color: var(--primary-gold);
        }

        .badge-tag {
            background: rgba(240, 185, 11, 0.15);
            color: var(--primary-gold);
            font-size: 10px;
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 4px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 24px;
            font-size: 14px;
            font-weight: 500;
        }

        .nav-link {
            color: var(--text-secondary);
            transition: color 0.2s;
        }

        .nav-link:hover, .nav-link.active {
            color: var(--primary-gold);
        }

        .nav-actions {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .balance-pill {
            background: #1E2329;
            border: 1px solid var(--border-color);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .balance-pill span.val {
            color: var(--primary-gold);
            font-family: var(--font-mono);
            font-weight: 700;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 9px 18px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
            outline: none;
        }

        .btn-gold {
            background: var(--primary-gold);
            color: #000;
        }

        .btn-gold:hover {
            background: var(--primary-gold-hover);
            transform: translateY(-1px);
        }

        .btn-outline {
            background: transparent;
            color: var(--text-primary);
            border: 1px solid var(--border-color);
        }

        .btn-outline:hover {
            border-color: var(--primary-gold);
            color: var(--primary-gold);
        }

        .btn-admin {
            background: #2B313A;
            color: #EAECEF;
        }

        .btn-admin:hover {
            background: #3B424E;
            color: #fff;
        }

        /* Hero & PancakeSwap Section */
        .hero-section {
            padding: 48px 28px 32px;
            max-width: 1380px;
            margin: 0 auto;
        }

        .hero-grid {
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 36px;
            align-items: center;
        }

        .hero-title {
            font-size: 44px;
            font-weight: 800;
            line-height: 1.15;
            margin-bottom: 16px;
            letter-spacing: -1px;
        }

        .hero-title span {
            color: var(--primary-gold);
            background: linear-gradient(135deg, #F0B90B 0%, #FCD535 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero-desc {
            font-size: 16px;
            color: var(--text-secondary);
            margin-bottom: 28px;
            line-height: 1.6;
        }

        .contract-pill {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 10px 16px;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            font-size: 13px;
            margin-bottom: 24px;
        }

        .contract-pill code {
            font-family: var(--font-mono);
            color: var(--primary-gold);
        }

        .copy-btn {
            background: transparent;
            border: none;
            color: var(--text-secondary);
            cursor: pointer;
            font-size: 13px;
        }

        .copy-btn:hover { color: #fff; }

        /* PancakeSwap Card */
        .swap-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 28px;
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.4);
            position: relative;
            overflow: hidden;
        }

        .swap-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #F0B90B, #0ECB81, #F0B90B);
        }

        .swap-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .swap-card-title {
            font-size: 18px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .swap-tabs {
            display: flex;
            background: var(--bg-main);
            border-radius: 8px;
            padding: 3px;
            margin-bottom: 20px;
        }

        .swap-tab {
            flex: 1;
            text-align: center;
            padding: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border-radius: 6px;
            color: var(--text-secondary);
            transition: all 0.2s;
        }

        .swap-tab.active {
            background: var(--bg-card);
            color: var(--primary-gold);
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
        }

        .swap-input-box {
            background: var(--bg-main);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 14px 16px;
            margin-bottom: 12px;
            transition: border-color 0.2s;
        }

        .swap-input-box:focus-within {
            border-color: var(--primary-gold);
        }

        .swap-input-top {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            color: var(--text-secondary);
            margin-bottom: 6px;
        }

        .swap-input-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .swap-input-bottom input {
            background: transparent;
            border: none;
            color: #fff;
            font-size: 20px;
            font-family: var(--font-mono);
            font-weight: 600;
            width: 60%;
            outline: none;
        }

        .token-selector {
            display: flex;
            align-items: center;
            gap: 8px;
            background: var(--bg-card);
            padding: 6px 12px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 14px;
        }

        .swap-icon-divider {
            display: flex;
            justify-content: center;
            margin: -6px 0 6px;
        }

        .swap-arrow-btn {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-gold);
        }

        .swap-details {
            background: rgba(240, 185, 11, 0.05);
            border: 1px solid rgba(240, 185, 11, 0.15);
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 18px;
            font-size: 12px;
        }

        .swap-detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 4px;
            color: var(--text-secondary);
        }

        .swap-detail-row:last-child { margin-bottom: 0; }
        .swap-detail-row strong { color: var(--text-primary); }

        .hash-verify-box {
            display: none;
        }

        .hash-input {
            width: 100%;
            background: var(--bg-main);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 12px 14px;
            color: #fff;
            font-family: var(--font-mono);
            font-size: 13px;
            margin-bottom: 12px;
            outline: none;
        }

        .hash-input:focus { border-color: var(--primary-gold); }

        .alert-toast {
            display: none;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 13px;
            margin-top: 14px;
        }

        .alert-toast.success {
            background: rgba(14, 203, 129, 0.15);
            border: 1px solid var(--color-up);
            color: var(--color-up);
        }

        .alert-toast.error {
            background: rgba(246, 70, 93, 0.15);
            border: 1px solid var(--color-down);
            color: var(--color-down);
        }

        /* Trading & Markets Grid */
        .market-section {
            padding: 24px 28px 60px;
            max-width: 1380px;
            margin: 0 auto;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .section-title {
            font-size: 24px;
            font-weight: 700;
        }

        .trading-container {
            display: grid;
            grid-template-columns: 2.2fr 1fr;
            gap: 20px;
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            min-height: 520px;
            margin-bottom: 36px;
        }

        .chart-panel {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .chart-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 12px;
        }

        .pair-title {
            font-size: 18px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .orderbook-panel {
            border-left: 1px solid var(--border-color);
            padding-left: 20px;
            display: flex;
            flex-direction: column;
        }

        .book-title {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 12px;
            color: var(--text-secondary);
        }

        .book-table {
            width: 100%;
            font-size: 12px;
            font-family: var(--font-mono);
            border-collapse: collapse;
        }

        .book-table th {
            text-align: left;
            color: var(--text-muted);
            padding-bottom: 8px;
            font-weight: 500;
        }

        .book-table td {
            padding: 3px 0;
        }

        .markets-table-wrap {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            overflow: hidden;
        }

        .markets-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .markets-table th {
            background: #14171C;
            text-align: left;
            padding: 14px 20px;
            font-size: 12px;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .markets-table td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .markets-table tr:hover {
            background: var(--bg-card-hover);
        }

        .coin-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 600;
        }

        /* Footer */
        .footer {
            background: #12161C;
            border-top: 1px solid var(--border-color);
            padding: 40px 28px 24px;
            margin-top: 40px;
        }

        .footer-inner {
            max-width: 1380px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .footer-links {
            display: flex;
            gap: 24px;
            font-size: 13px;
            color: var(--text-secondary);
        }

        .footer-links a:hover {
            color: var(--primary-gold);
        }

        @media (max-width: 992px) {
            .hero-grid { grid-template-columns: 1fr; }
            .trading-container { grid-template-columns: 1fr; }
            .orderbook-panel { border-left: none; border-top: 1px solid var(--border-color); padding-left: 0; padding-top: 20px; }
            .nav-links { display: none; }
        }
    </style>
</head>
<body>

    <!-- Top Live Ticker Bar -->
    <div class="ticker-bar">
        <div class="ticker-item">
            <span class="ticker-symbol">JWC/USDT</span>
            <span class="ticker-price up">$0.0500 (+14.8%)</span>
        </div>
        <div class="ticker-item">
            <span class="ticker-symbol">BTC/USDT</span>
            <span class="ticker-price up">$64,320.50 (+3.4%)</span>
        </div>
        <div class="ticker-item">
            <span class="ticker-symbol">ETH/USDT</span>
            <span class="ticker-price up">$3,490.20 (+2.9%)</span>
        </div>
        <div class="ticker-item">
            <span class="ticker-symbol">BNB/USDT</span>
            <span class="ticker-price up">$586.40 (+1.8%)</span>
        </div>
        <div class="ticker-item">
            <span class="ticker-symbol">24h Network Settlement</span>
            <span class="ticker-price" style="color: var(--primary-gold)">BNB Smart Chain (Active)</span>
        </div>
    </div>

    <!-- Navigation Bar -->
    <nav class="navbar">
        <div class="navbar-brand">
            <a href="/" style="display: flex; align-items: center; gap: 10px;">
                <img src="{{ asset('assets/landing/images/logo.svg') }}" alt="JuwishPro Logo">
                <div class="brand-text">Juwish<span>Pro</span></div>
                <span class="badge-tag">Smart Trading</span>
            </a>
        </div>

        <div class="nav-links">
            <a href="#exchange" class="nav-link active">Exchange</a>
            <a href="#markets" class="nav-link">Markets</a>
            <a href="{{ $pancakeswap_url }}" target="_blank" class="nav-link" style="color: var(--primary-gold)">
                <i class="fa-solid fa-cake-candles"></i> PancakeSwap
            </a>
            <a href="https://bscscan.com/token/{{ $jwc_contract }}" target="_blank" class="nav-link">BscScan (BEP-20)</a>
        </div>

        <div class="nav-actions">
            <!-- Balance Indicator -->
            <div class="balance-pill" id="balancePill">
                <i class="fa-solid fa-coins" style="color: var(--primary-gold)"></i>
                <span>JWC Balance:</span>
                <span class="val" id="userJwcBalance">{{ number_format($jwc_balance, 2) }}</span>
            </div>

            <button class="btn btn-gold" onclick="openSwapCard()">
                <i class="fa-solid fa-bolt"></i> Buy JWC Direct
            </button>

            <!-- Admin Access -->
            <a href="{{ route('adminDashboard') }}" class="btn btn-admin" title="Admin Portal Management">
                <i class="fa-solid fa-shield-halved"></i> Admin
            </a>
        </div>
    </nav>

    <!-- Main Hero & PancakeSwap Deposit Section -->
    <section class="hero-section">
        <div class="hero-grid">
            <div class="hero-left">
                <div class="contract-pill">
                    <i class="fa-brands fa-ethereum" style="color: var(--primary-gold)"></i>
                    <span>BSC BEP-20:</span>
                    <code id="contractAddress">{{ $jwc_contract }}</code>
                    <button class="copy-btn" onclick="copyContract()"><i class="fa-regular fa-copy"></i></button>
                </div>

                <h1 class="hero-title">
                    Trade <span>JuwishCoin</span> & Digital Assets with Automated Settlement
                </h1>
                <p class="hero-desc">
                    Experience deep liquidity and real-time on-chain deposits. Buy JWC instantly with BNB or USDT via PancakeSwap, and your balance credits automatically upon blockchain confirmation.
                </p>

                <div style="display: flex; gap: 14px; flex-wrap: wrap;">
                    <a href="#exchange" class="btn btn-gold" style="padding: 12px 24px; font-size: 15px;">
                        <i class="fa-solid fa-chart-line"></i> Spot Trading
                    </a>
                    <a href="{{ $pancakeswap_url }}" target="_blank" class="btn btn-outline" style="padding: 12px 24px; font-size: 15px;">
                        <i class="fa-solid fa-arrow-up-right-from-square"></i> Open PancakeSwap
                    </a>
                </div>
            </div>

            <!-- Interactive PancakeSwap Deposit Card -->
            <div class="hero-right">
                <div class="swap-card" id="pancakeswapCard">
                    <div class="swap-card-header">
                        <div class="swap-card-title">
                            <i class="fa-solid fa-cake-candles" style="color: var(--primary-gold); font-size: 20px;"></i>
                            PancakeSwap Instant Deposit
                        </div>
                        <span class="badge-tag">Auto-Credited</span>
                    </div>

                    <div class="swap-tabs">
                        <div class="swap-tab active" id="tabWeb3" onclick="switchTab('web3')">
                            <i class="fa-solid fa-wallet"></i> Web3 Direct Buy
                        </div>
                        <div class="swap-tab" id="tabHash" onclick="switchTab('hash')">
                            <i class="fa-solid fa-receipt"></i> Verify Tx Hash
                        </div>
                    </div>

                    <!-- Mode 1: Web3 Direct Swap -->
                    <div id="web3SwapBox">
                        <div class="swap-input-box">
                            <div class="swap-input-top">
                                <span>You Pay</span>
                                <span>Balance: <span id="userBnbBalance">0.00</span> BNB</span>
                            </div>
                            <div class="swap-input-bottom">
                                <input type="number" id="inputPayAmount" value="0.1" step="0.01" min="0.01" oninput="calculateJwc()">
                                <div class="token-selector">
                                    <i class="fa-solid fa-diamond" style="color: #F0B90B"></i>
                                    <span>BNB</span>
                                </div>
                            </div>
                        </div>

                        <div class="swap-icon-divider">
                            <div class="swap-arrow-btn"><i class="fa-solid fa-arrow-down"></i></div>
                        </div>

                        <div class="swap-input-box">
                            <div class="swap-input-top">
                                <span>You Receive (Estimated)</span>
                                <span>1 JWC = $0.05</span>
                            </div>
                            <div class="swap-input-bottom">
                                <input type="text" id="inputReceiveAmount" value="1,172.80" readonly>
                                <div class="token-selector">
                                    <img src="{{ asset('assets/landing/images/logo.svg') }}" style="width: 18px; height: 18px;">
                                    <span>JWC</span>
                                </div>
                            </div>
                        </div>

                        <div class="swap-details">
                            <div class="swap-detail-row">
                                <span>Slippage Tolerance</span>
                                <strong>0.5%</strong>
                            </div>
                            <div class="swap-detail-row">
                                <span>Routing</span>
                                <strong>PancakeSwap V2 Router (BSC)</strong>
                            </div>
                            <div class="swap-detail-row">
                                <span>Settlement Time</span>
                                <strong style="color: var(--color-up)">Instant (~3 seconds)</strong>
                            </div>
                        </div>

                        <button class="btn btn-gold" id="btnConnectAndBuy" onclick="executePancakeSwapWeb3()" style="width: 100%; padding: 14px; font-size: 15px;">
                            <i class="fa-solid fa-wallet"></i> Connect Wallet & Buy JWC
                        </button>
                    </div>

                    <!-- Mode 2: Verify Completed Hash -->
                    <div id="hashVerifyBox" class="hash-verify-box">
                        <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 12px;">
                            Bought JWC on PancakeSwap directly? Paste your Binance Smart Chain transaction hash below to verify and credit your balance immediately:
                        </p>
                        <input type="text" class="hash-input" id="txHashInput" placeholder="0x1234567890abcdef..." autocomplete="off">
                        
                        <button class="btn btn-gold" id="btnVerifyHash" onclick="submitDepositHash()" style="width: 100%; padding: 14px; font-size: 15px;">
                            <i class="fa-solid fa-circle-check"></i> Verify & Credit Balance
                        </button>
                    </div>

                    <div class="alert-toast" id="toastMessage"></div>
                </div>
            </div>
        </div>
    </section>

    <!-- Spot Trading Interface -->
    <section class="market-section" id="exchange">
        <div class="section-header">
            <div>
                <h2 class="section-title">Spot Exchange</h2>
                <p style="color: var(--text-secondary); font-size: 14px;">Institutional orderbook matching & TradingView real-time charting</p>
            </div>
            <div style="display: flex; gap: 8px;">
                <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">1m</button>
                <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">5m</button>
                <button class="btn btn-gold" style="padding: 6px 12px; font-size: 12px;">15m</button>
                <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">1H</button>
                <button class="btn btn-outline" style="padding: 6px 12px; font-size: 12px;">1D</button>
            </div>
        </div>

        <div class="trading-container">
            <!-- Chart Panel -->
            <div class="chart-panel">
                <div class="chart-header">
                    <div class="pair-title">
                        <img src="{{ asset('assets/landing/images/logo.svg') }}" style="width: 24px; height: 24px;">
                        <span>JWC / USDT</span>
                        <span class="up" style="font-family: var(--font-mono); font-size: 16px;">$0.0500</span>
                    </div>
                    <div style="display: flex; gap: 16px; font-size: 12px; color: var(--text-secondary);">
                        <div>24h High: <strong style="color: var(--text-primary)">$0.0524</strong></div>
                        <div>24h Low: <strong style="color: var(--text-primary)">$0.0435</strong></div>
                        <div>24h Volume: <strong style="color: var(--primary-gold)">842,500 JWC</strong></div>
                    </div>
                </div>

                <!-- Live Candlestick Canvas -->
                <div style="flex: 1; min-height: 400px; background: #0F1216; border-radius: 8px; position: relative; overflow: hidden;">
                    <iframe src="https://s.tradingview.com/widgetembed/?frameElementId=tradingview_widget&symbol=BINANCE%3ABNBUSDT&interval=15&hidesidetoolbar=1&symboledit=0&saveimage=0&toolbarbg=181A20&studies=%5B%5D&theme=dark&style=1&timezone=Etc%2FUTC&studies_overrides=%7B%7D&overrides=%7B%22mainSeriesProperties.candleStyle.upColor%22%3A%22%230ECB81%22%2C%22mainSeriesProperties.candleStyle.downColor%22%3A%22%23F6465D%22%7D&enabled_features=%5B%5D&disabled_features=%5B%5D&locale=en" 
                            style="width: 100%; height: 100%; border: none;"></iframe>
                </div>
            </div>

            <!-- Orderbook Panel -->
            <div class="orderbook-panel">
                <div class="book-title">Order Book (JWC/USDT)</div>
                <table class="book-table">
                    <thead>
                        <tr>
                            <th>Price (USDT)</th>
                            <th>Size (JWC)</th>
                            <th style="text-align: right;">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Asks (Sells) -->
                        <tr class="down"><td>0.0508</td><td>14,200</td><td style="text-align: right;">721.36</td></tr>
                        <tr class="down"><td>0.0506</td><td>28,500</td><td style="text-align: right;">1,442.10</td></tr>
                        <tr class="down"><td>0.0504</td><td>35,100</td><td style="text-align: right;">1,769.04</td></tr>
                        <tr class="down"><td>0.0502</td><td>12,800</td><td style="text-align: right;">642.56</td></tr>
                        <!-- Spread -->
                        <tr style="border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color);">
                            <td colspan="3" style="padding: 8px 0; text-align: center; font-weight: 700; font-size: 14px;" class="up">
                                $0.0500 <i class="fa-solid fa-arrow-trend-up"></i>
                            </td>
                        </tr>
                        <!-- Bids (Buys) -->
                        <tr class="up"><td>0.0498</td><td>42,000</td><td style="text-align: right;">2,091.60</td></tr>
                        <tr class="up"><td>0.0496</td><td>25,400</td><td style="text-align: right;">1,259.84</td></tr>
                        <tr class="up"><td>0.0494</td><td>18,900</td><td style="text-align: right;">933.66</td></tr>
                        <tr class="up"><td>0.0492</td><td>55,000</td><td style="text-align: right;">2,706.00</td></tr>
                    </tbody>
                </table>

                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border-color);">
                    <button class="btn btn-gold" onclick="openSwapCard()" style="width: 100%;">
                        <i class="fa-solid fa-plus"></i> Buy JWC Instantly
                    </button>
                </div>
            </div>
        </div>

        <!-- Markets Table -->
        <div class="section-header" id="markets">
            <h2 class="section-title">Cryptocurrency Markets</h2>
            <span class="badge-tag">Zero Fees on JWC Pairs</span>
        </div>

        <div class="markets-table-wrap">
            <table class="markets-table">
                <thead>
                    <tr>
                        <th>Asset Pair</th>
                        <th>Last Price</th>
                        <th>24h Change</th>
                        <th>24h Volume</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <div class="coin-meta">
                                <img src="{{ asset('assets/landing/images/logo.svg') }}" style="width: 28px; height: 28px;">
                                <div>
                                    <div>JuwishCoin <span style="color: var(--primary-gold)">JWC</span></div>
                                    <div style="font-size: 11px; color: var(--text-muted)">Binance Smart Chain BEP-20</div>
                                </div>
                            </div>
                        </td>
                        <td style="font-family: var(--font-mono); font-weight: 600;">$0.0500</td>
                        <td class="up" style="font-family: var(--font-mono); font-weight: 600;">+14.80%</td>
                        <td style="font-family: var(--font-mono);">$42,125 USD</td>
                        <td>
                            <button class="btn btn-gold" style="padding: 6px 14px; font-size: 12px;" onclick="openSwapCard()">
                                Buy JWC
                            </button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="coin-meta">
                                <i class="fa-brands fa-bitcoin" style="color: #F7931A; font-size: 26px;"></i>
                                <div>
                                    <div>Bitcoin <span>BTC</span></div>
                                    <div style="font-size: 11px; color: var(--text-muted)">Bitcoin Core</div>
                                </div>
                            </div>
                        </td>
                        <td style="font-family: var(--font-mono); font-weight: 600;">$64,320.50</td>
                        <td class="up" style="font-family: var(--font-mono); font-weight: 600;">+3.42%</td>
                        <td style="font-family: var(--font-mono);">$1,184,820,400 USD</td>
                        <td>
                            <a href="#exchange" class="btn btn-outline" style="padding: 6px 14px; font-size: 12px;">Trade</a>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="coin-meta">
                                <i class="fa-brands fa-ethereum" style="color: #627EEA; font-size: 26px;"></i>
                                <div>
                                    <div>Ethereum <span>ETH</span></div>
                                    <div style="font-size: 11px; color: var(--text-muted)">Ethereum Mainnet</div>
                                </div>
                            </div>
                        </td>
                        <td style="font-family: var(--font-mono); font-weight: 600;">$3,490.20</td>
                        <td class="up" style="font-family: var(--font-mono); font-weight: 600;">+2.90%</td>
                        <td style="font-family: var(--font-mono);">$742,910,200 USD</td>
                        <td>
                            <a href="#exchange" class="btn btn-outline" style="padding: 6px 14px; font-size: 12px;">Trade</a>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="coin-meta">
                                <i class="fa-solid fa-diamond" style="color: #F0B90B; font-size: 24px;"></i>
                                <div>
                                    <div>BNB <span>BNB</span></div>
                                    <div style="font-size: 11px; color: var(--text-muted)">BNB Smart Chain</div>
                                </div>
                            </div>
                        </td>
                        <td style="font-family: var(--font-mono); font-weight: 600;">$586.40</td>
                        <td class="up" style="font-family: var(--font-mono); font-weight: 600;">+1.85%</td>
                        <td style="font-family: var(--font-mono);">$310,480,100 USD</td>
                        <td>
                            <a href="#exchange" class="btn btn-outline" style="padding: 6px 14px; font-size: 12px;">Trade</a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <div class="footer-inner">
            <div style="display: flex; align-items: center; gap: 12px;">
                <img src="{{ asset('assets/landing/images/logo.svg') }}" style="width: 28px; height: 28px;">
                <span style="font-weight: 700;">Juwish<span style="color: var(--primary-gold)">Pro</span></span>
                <span style="font-size: 12px; color: var(--text-muted);">&copy; 2026 JuwishPro. All rights reserved.</span>
            </div>

            <div class="footer-links">
                <a href="{{ $pancakeswap_url }}" target="_blank">PancakeSwap Liquidity</a>
                <a href="https://bscscan.com/token/{{ $jwc_contract }}" target="_blank">BscScan Token</a>
                <a href="{{ route('adminDashboard') }}" style="color: var(--primary-gold)">
                    <i class="fa-solid fa-lock"></i> Admin Portal Login
                </a>
            </div>
        </div>
    </footer>

    <!-- Web3 & Verification Script -->
    <script>
        const JWC_CONTRACT = "{{ $jwc_contract }}";
        const PANCAKESWAP_ROUTER = "0x10ED43C718714eb63d5aA57B78B54704E256024E";
        const JWC_PRICE_USD = 0.05;
        const BNB_PRICE_USD = 586.40;

        function copyContract() {
            navigator.clipboard.writeText(JWC_CONTRACT).then(() => {
                showToast('Contract address copied to clipboard!', 'success');
            });
        }

        function calculateJwc() {
            const payAmount = parseFloat(document.getElementById('inputPayAmount').value) || 0;
            const jwcAmount = (payAmount * BNB_PRICE_USD) / JWC_PRICE_USD;
            document.getElementById('inputReceiveAmount').value = jwcAmount.toLocaleString('en-US', { maximumFractionDigits: 2 });
        }

        function switchTab(mode) {
            const tabWeb3 = document.getElementById('tabWeb3');
            const tabHash = document.getElementById('tabHash');
            const web3Box = document.getElementById('web3SwapBox');
            const hashBox = document.getElementById('hashVerifyBox');

            if (mode === 'web3') {
                tabWeb3.classList.add('active');
                tabHash.classList.remove('active');
                web3Box.style.display = 'block';
                hashBox.style.display = 'none';
            } else {
                tabHash.classList.add('active');
                tabWeb3.classList.remove('active');
                hashBox.style.display = 'block';
                web3Box.style.display = 'none';
            }
        }

        function openSwapCard() {
            document.getElementById('pancakeswapCard').scrollIntoView({ behavior: 'smooth' });
        }

        function showToast(msg, type) {
            const toast = document.getElementById('toastMessage');
            toast.className = 'alert-toast ' + type;
            toast.innerHTML = (type === 'success' ? '<i class="fa-solid fa-circle-check"></i> ' : '<i class="fa-solid fa-triangle-exclamation"></i> ') + msg;
            toast.style.display = 'block';
            setTimeout(() => {
                toast.style.display = 'none';
            }, 6000);
        }

        // Web3 PancakeSwap Integration
        async function executePancakeSwapWeb3() {
            const btn = document.getElementById('btnConnectAndBuy');
            
            if (typeof window.ethereum === 'undefined') {
                showToast('No Web3 wallet detected. Opening PancakeSwap directly...', 'success');
                setTimeout(() => {
                    window.open("{{ $pancakeswap_url }}", "_blank");
                    switchTab('hash');
                }, 800);
                return;
            }

            try {
                btn.disabled = true;
                btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Connecting Wallet...';

                const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
                const userAddress = accounts[0];

                // Ensure Binance Smart Chain
                const chainId = await window.ethereum.request({ method: 'eth_chainId' });
                if (chainId !== '0x38') {
                    btn.innerHTML = '<i class="fa-solid fa-arrows-rotate"></i> Switching to BSC...';
                    try {
                        await window.ethereum.request({
                            method: 'wallet_switchEthereumChain',
                            params: [{ chainId: '0x38' }]
                        });
                    } catch (switchError) {
                        if (switchError.code === 4902) {
                            await window.ethereum.request({
                                method: 'wallet_addEthereumChain',
                                params: [{
                                    chainId: '0x38',
                                    chainName: 'BNB Smart Chain Mainnet',
                                    nativeCurrency: { name: 'BNB', symbol: 'BNB', decimals: 18 },
                                    rpcUrls: ['https://bsc-dataseed.binance.org'],
                                    blockExplorerUrls: ['https://bscscan.com']
                                }]
                            });
                        }
                    }
                }

                // Fetch and display live BNB balance
                try {
                    const bnbBalHex = await window.ethereum.request({ method: 'eth_getBalance', params: [userAddress, 'latest'] });
                    const bnbBal = (parseInt(bnbBalHex, 16) / 1e18).toFixed(4);
                    const bnbBalEl = document.getElementById('userBnbBalance');
                    if (bnbBalEl) bnbBalEl.innerText = bnbBal;
                } catch (e) {
                    console.log('Balance fetch err:', e);
                }

                btn.innerHTML = '<i class="fa-solid fa-arrow-up-right-from-square"></i> Opening PancakeSwap...';
                window.open("{{ $pancakeswap_url }}", "_blank");

                // Switch to hash verification tab and guide user
                setTimeout(() => {
                    switchTab('hash');
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fa-solid fa-wallet"></i> Connect Wallet & Buy JWC';
                    showToast('PancakeSwap opened! Once your swap confirms in your wallet, paste the transaction hash here to credit your balance.', 'success');
                }, 1000);

            } catch (err) {
                console.error(err);
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-wallet"></i> Connect Wallet & Buy JWC';
                showToast(err.message || 'Wallet connection was canceled.', 'error');
            }
        }

        // Verify and Credit Tx Hash
        async function submitDepositHash() {
            const input = document.getElementById('txHashInput');
            const btn = document.getElementById('btnVerifyHash');
            const txHash = input.value.trim();

            if (!txHash || !txHash.startsWith('0x') || txHash.length !== 66) {
                showToast('Please enter a valid 66-character BSC transaction hash (starts with 0x)', 'error');
                return;
            }

            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Verifying with BNB Chain...';

            await verifyTxHashOnServer(txHash);

            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-circle-check"></i> Verify & Credit Balance';
        }

        async function verifyTxHashOnServer(txHash) {
            try {
                const response = await fetch('/api/verify-pancakeswap-deposit', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({ tx_hash: txHash })
                });

                const result = await response.json();

                if (result.success) {
                    showToast(result.message, 'success');
                    if (result.data && result.data.new_balance !== undefined) {
                        const newBal = result.data.new_balance;
                        localStorage.setItem('juwish_jwc_balance', newBal);
                        const balEl = document.getElementById('userJwcBalance');
                        if (balEl) balEl.innerText = parseFloat(newBal).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                    }
                    document.getElementById('txHashInput').value = '';
                } else {
                    showToast(result.message || 'Verification failed.', 'error');
                }
            } catch (err) {
                showToast('Failed to contact verification server. Please try again.', 'error');
            }
        }

        // Restore cached balance on load
        window.addEventListener('DOMContentLoaded', () => {
            const saved = localStorage.getItem('juwish_jwc_balance');
            if (saved) {
                const balEl = document.getElementById('userJwcBalance');
                if (balEl && (balEl.innerText.trim() === '0.00' || balEl.innerText.trim() === '0')) {
                    balEl.innerText = parseFloat(saved).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                }
            }
        });
    </script>
</body>
</html>
