#!/usr/bin/env python3
import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BASE_DIR = '/home/thbinnovation/Desktop/JuwishPro'
OUT_DIR = os.path.join(BASE_DIR, 'public/apps/images/playstore')
DOWNLOADS_DIR = os.path.join(BASE_DIR, 'public/apps/downloads')
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(DOWNLOADS_DIR, exist_ok=True)

MEDALLION_PATH = os.path.join(BASE_DIR, 'public/assets/images/juwishcoin.png')
if not os.path.exists(MEDALLION_PATH):
    MEDALLION_PATH = os.path.join(BASE_DIR, 'public/assets/images/logo-square.png')

FONT_BOLD = '/usr/share/fonts/truetype/open-sans/OpenSans-Bold.ttf'
FONT_EXTRA_BOLD = '/usr/share/fonts/truetype/open-sans/OpenSans-ExtraBold.ttf'
FONT_REGULAR = '/usr/share/fonts/truetype/open-sans/OpenSans-Regular.ttf'

def get_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except:
        return ImageFont.load_default()

def draw_radial_gradient(img, center, max_radius, color_inner, color_outer):
    draw = ImageDraw.Draw(img)
    cx, cy = center
    # create smooth overlay
    overlay = Image.new('RGBA', img.size, (0, 0, 0, 0))
    o_draw = ImageDraw.Draw(overlay)
    steps = 40
    for i in range(steps, 0, -1):
        r = int(max_radius * (i / steps))
        factor = i / steps
        alpha = int(color_inner[3] * (1 - factor) + color_outer[3] * factor)
        r_c = int(color_inner[0] * (1 - factor) + color_outer[0] * factor)
        g_c = int(color_inner[1] * (1 - factor) + color_outer[1] * factor)
        b_c = int(color_inner[2] * (1 - factor) + color_outer[2] * factor)
        o_draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_c, g_c, b_c, alpha))
    img.alpha_composite(overlay)

def generate_app_icon():
    print("Generating 512x512 App Icon...")
    size = (512, 512)
    img = Image.new('RGBA', size, (11, 14, 17, 255)) # Rich Obsidian #0B0E11
    
    # Gold Radial glow in center
    draw_radial_gradient(img, (256, 256), 280, (240, 185, 11, 65), (11, 14, 17, 0))
    
    # Outer subtle rounded frame
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([16, 16, 496, 496], radius=90, outline=(240, 185, 11, 50), width=3)
    
    # Load and place coin medallion
    medallion = Image.open(MEDALLION_PATH).convert('RGBA')
    medallion_resized = medallion.resize((370, 370), Image.Resampling.LANCZOS)
    img.paste(medallion_resized, (71, 52), medallion_resized)
    
    # "JUWISHPRO" text badge at bottom
    font_badge = get_font(FONT_EXTRA_BOLD, 32)
    font_pro = get_font(FONT_EXTRA_BOLD, 22)
    
    # Draw dark pill at bottom
    draw.rounded_rectangle([126, 434, 386, 482], radius=16, fill=(18, 22, 28, 240), outline=(240, 185, 11, 120), width=2)
    draw.text((150, 442), "JUWISH", font=font_badge, fill=(255, 255, 255))
    
    # Gold PRO tag
    draw.rounded_rectangle([292, 444, 362, 474], radius=6, fill=(240, 185, 11, 255))
    draw.text((304, 446), "PRO", font=font_pro, fill=(11, 14, 17))
    
    # Ensure strictly RGB/no alpha for Google Play Store icon requirements
    final_rgb = img.convert('RGB')
    icon_path = os.path.join(OUT_DIR, 'app_icon_512x512.png')
    final_rgb.save(icon_path, 'PNG', optimize=True)
    final_rgb.save(os.path.join(DOWNLOADS_DIR, 'app_icon_512x512.png'), 'PNG', optimize=True)
    print(f"  [OK] Saved: {icon_path}")

def generate_feature_graphic():
    print("Generating 1024x500 Feature Graphic (Banner)...")
    size = (1024, 500)
    img = Image.new('RGBA', size, (11, 14, 17, 255))
    
    # Dual radial ambient glows
    draw_radial_gradient(img, (260, 250), 380, (240, 185, 11, 50), (11, 14, 17, 0))
    draw_radial_gradient(img, (850, 150), 300, (16, 185, 129, 35), (11, 14, 17, 0))
    
    draw = ImageDraw.Draw(img)
    
    # Background high-tech grid lines
    for x in range(0, 1024, 60):
        draw.line([(x, 0), (x, 500)], fill=(255, 255, 255, 6), width=1)
    for y in range(0, 500, 50):
        draw.line([(0, y), (1024, y)], fill=(255, 255, 255, 6), width=1)
        
    # Medallion on the left
    medallion = Image.open(MEDALLION_PATH).convert('RGBA')
    medallion_resized = medallion.resize((360, 360), Image.Resampling.LANCZOS)
    img.paste(medallion_resized, (60, 70), medallion_resized)
    
    # Text Information on the right
    font_title = get_font(FONT_EXTRA_BOLD, 56)
    font_pro = get_font(FONT_EXTRA_BOLD, 36)
    font_sub = get_font(FONT_BOLD, 22)
    font_badge = get_font(FONT_BOLD, 15)
    font_desc = get_font(FONT_REGULAR, 16)
    
    # Brand row
    draw.text((450, 95), "JUWISH", font=font_title, fill=(255, 255, 255))
    # PRO gold pill
    draw.rounded_rectangle([705, 102, 810, 152], radius=10, fill=(240, 185, 11, 255))
    draw.text((725, 106), "PRO", font=font_pro, fill=(11, 14, 17))
    
    # Tagline
    draw.text((452, 170), "The Premier Multi-Asset Financial Ecosystem", font=font_sub, fill=(240, 185, 11))
    draw.text((452, 206), "Institutional Trading • JuwishCoin Protocol • Automated Staking", font=font_desc, fill=(180, 190, 205))
    
    # Feature Badges Row 1
    badges_r1 = [
        ("JWC / USDT • $3.00", (240, 185, 11)),
        ("PancakeSwap Peg", (56, 189, 248)),
        ("+14.5% APY Staking", (52, 211, 153))
    ]
    cur_x = 452
    for b_text, b_color in badges_r1:
        text_w = int(draw.textlength(b_text, font=font_badge))
        draw.rounded_rectangle([cur_x, 250, cur_x + text_w + 24, 286], radius=18, fill=(24, 28, 36, 240), outline=b_color, width=1)
        draw.text((cur_x + 12, 258), b_text, font=font_badge, fill=b_color)
        cur_x += text_w + 34

    # Feature Badges Row 2 (Market assets)
    badges_r2 = [
        ("Forex", (255, 255, 255)),
        ("Crypto Futures", (255, 255, 255)),
        ("Global Stocks", (255, 255, 255)),
        ("Instant Bank & Wire Deposit", (250, 204, 21))
    ]
    cur_x = 452
    for b_text, b_color in badges_r2:
        text_w = int(draw.textlength(b_text, font=font_badge))
        draw.rounded_rectangle([cur_x, 302, cur_x + text_w + 20, 336], radius=16, fill=(18, 22, 28, 200), outline=(255, 255, 255, 40), width=1)
        draw.text((cur_x + 10, 309), b_text, font=font_badge, fill=b_color)
        cur_x += text_w + 28
        
    # Security bar at bottom
    draw.rounded_rectangle([452, 365, 960, 420], radius=14, fill=(16, 185, 129, 25), outline=(16, 185, 129, 90), width=1)
    draw.text((475, 381), "✓  256-Bit Bank-Grade Encryption   •   Multi-Sig Cold Storage   •   Regulated Standards", font=font_badge, fill=(52, 211, 153))
    
    # Outer elegant gold border
    draw.rectangle([0, 0, 1023, 499], outline=(240, 185, 11, 60), width=2)
    
    final_rgb = img.convert('RGB')
    banner_path = os.path.join(OUT_DIR, 'feature_graphic_1024x500.png')
    final_rgb.save(banner_path, 'PNG', optimize=True)
    final_rgb.save(os.path.join(DOWNLOADS_DIR, 'feature_graphic_1024x500.png'), 'PNG', optimize=True)
    print(f"  [OK] Saved: {banner_path}")

def generate_screenshots():
    print("Generating 5 Phone Screenshots (1080x2400)...")
    shots_dir = os.path.join(OUT_DIR, 'screenshots')
    os.makedirs(shots_dir, exist_ok=True)
    
    medallion = Image.open(MEDALLION_PATH).convert('RGBA')

    configs = [
        {
            "filename": "screenshot_1_trading.png",
            "tag": "REAL-TIME MULTI-ASSET TRADING",
            "headline": "Institutional Execution Across Forex, Crypto & Stocks",
            "sub": "Live Depth of Market • Real-Time Candlestick Charts • Ultra-Low Spreads",
            "mockup_type": "trading"
        },
        {
            "filename": "screenshot_2_juwishcoin.png",
            "tag": "JUWISHCOIN PROTOCOL",
            "headline": "PancakeSwap Live Rate at $3.00 USD per JuwishCoin",
            "sub": "Direct Deposit Credited to Wallet Balance • 0% Surcharge • Instant Purchase",
            "mockup_type": "juwishcoin"
        },
        {
            "filename": "screenshot_3_wallet.png",
            "tag": "MULTI-CURRENCY CASH WALLET",
            "headline": "Manage Fiat, Crypto & JuwishCoin in One Unified Balance",
            "sub": "Instant Balances in USD • Bank Wire, Cards & Automated Crypto Gateways",
            "mockup_type": "wallet"
        },
        {
            "filename": "screenshot_4_staking.png",
            "tag": "HIGH-YIELD VAULTS & STAKING",
            "headline": "Earn Up to 14.5% APY with Daily Automated Returns",
            "sub": "Fixed & Flexible Investment Plans • Automated Compound Yields • Instant Payouts",
            "mockup_type": "staking"
        },
        {
            "filename": "screenshot_5_security.png",
            "tag": "BANK-GRADE ENCRYPTION & SECURITY",
            "headline": "Regulated Institutional Multi-Sig Protection",
            "sub": "2FA Biometric Authentication • Cold Storage Reserve • 24/7 Priority Support",
            "mockup_type": "security"
        }
    ]

    font_tag = get_font(FONT_EXTRA_BOLD, 26)
    font_headline = get_font(FONT_EXTRA_BOLD, 48)
    font_sub = get_font(FONT_BOLD, 26)
    font_ui_bold = get_font(FONT_BOLD, 30)
    font_ui_reg = get_font(FONT_REGULAR, 24)
    font_ui_sm = get_font(FONT_REGULAR, 20)
    font_price = get_font(FONT_EXTRA_BOLD, 54)

    for idx, cfg in enumerate(configs, 1):
        shot = Image.new('RGBA', (1080, 2400), (11, 14, 17, 255))
        draw_radial_gradient(shot, (540, 450), 600, (240, 185, 11, 45), (11, 14, 17, 0))
        draw_radial_gradient(shot, (540, 1600), 700, (18, 24, 33, 80), (11, 14, 17, 0))
        
        draw = ImageDraw.Draw(shot)
        
        # Grid line accents
        for y in range(0, 2400, 120):
            draw.line([(0, y), (1080, y)], fill=(255, 255, 255, 4), width=1)
            
        # Top Logo Pill
        medallion_sm = medallion.resize((64, 64), Image.Resampling.LANCZOS)
        shot.paste(medallion_sm, (90, 95), medallion_sm)
        draw.text((165, 105), "JUWISHPRO", font=get_font(FONT_EXTRA_BOLD, 32), fill=(255, 255, 255))
        
        # Tag Badge
        tag_w = int(draw.textlength(cfg['tag'], font=font_tag))
        draw.rounded_rectangle([90, 190, 90 + tag_w + 32, 242], radius=16, fill=(240, 185, 11, 30), outline=(240, 185, 11, 180), width=2)
        draw.text((106, 202), cfg['tag'], font=font_tag, fill=(240, 185, 11))
        
        # Headline (wrapped)
        words = cfg['headline'].split()
        line1 = " ".join(words[:4])
        line2 = " ".join(words[4:])
        draw.text((90, 275), line1, font=font_headline, fill=(255, 255, 255))
        if line2:
            draw.text((90, 345), line2, font=font_headline, fill=(255, 255, 255))
            
        # Subtitle
        draw.text((90, 435), cfg['sub'], font=font_sub, fill=(156, 163, 175))
        
        # Phone Mockup Canvas (Inside frame)
        # Phone Dimensions: 900w x 1750h positioned from y=530 to y=2280
        fx, fy, fw, fh = 90, 520, 900, 1760
        # Phone Outer Bezel
        draw.rounded_rectangle([fx, fy, fx + fw, fy + fh], radius=56, fill=(18, 22, 28, 255), outline=(240, 185, 11, 70), width=4)
        # Screen Inner Glass
        sx, sy, sw, sh = fx + 16, fy + 16, fw - 32, fh - 32
        draw.rounded_rectangle([sx, sy, sx + sw, sy + sh], radius=44, fill=(11, 14, 17, 255))
        
        # Top Dynamic Island Notch
        draw.rounded_rectangle([sx + sw//2 - 90, sy + 15, sx + sw//2 + 90, sy + 48], radius=16, fill=(0, 0, 0, 255))
        
        # Screen Content based on mockup_type
        if cfg['mockup_type'] == 'trading':
            # Trading Header
            draw.text((sx + 40, sy + 80), "BTC / USDT", font=font_ui_bold, fill=(255, 255, 255))
            draw.rounded_rectangle([sx + 240, sy + 82, sx + 325, sy + 118], radius=8, fill=(16, 185, 129, 30))
            draw.text((sx + 252, sy + 88), "LIVE", font=font_ui_sm, fill=(52, 211, 153))
            
            draw.text((sx + 40, sy + 130), "$67,840.50", font=font_price, fill=(255, 255, 255))
            draw.text((sx + 360, sy + 145), "+4.28% (+$2,790.20)", font=font_ui_bold, fill=(52, 211, 153))
            
            # Chart Canvas
            draw.rounded_rectangle([sx + 30, sy + 220, sx + sw - 30, sy + 750], radius=24, fill=(18, 22, 28, 200), outline=(255, 255, 255, 15), width=2)
            # Draw synthetic candlesticks
            candle_pts = [
                (100, 380, 480, True), (150, 420, 440, False), (200, 410, 520, True),
                (250, 500, 470, False), (300, 460, 540, True), (350, 530, 510, False),
                (400, 490, 590, True), (450, 580, 560, False), (500, 550, 640, True),
                (550, 620, 600, False), (600, 590, 670, True), (650, 650, 640, False),
                (700, 630, 710, True), (750, 690, 680, False)
            ]
            for cx_o, o_y, c_y, is_green in candle_pts:
                col = (52, 211, 153) if is_green else (244, 63, 94)
                draw.line([(sx + cx_o, sy + 220 + 750 - max(o_y, c_y) - 20), (sx + cx_o, sy + 220 + 750 - min(o_y, c_y) + 20)], fill=col, width=2)
                draw.rectangle([sx + cx_o - 14, sy + 220 + 750 - max(o_y, c_y), sx + cx_o + 14, sy + 220 + 750 - min(o_y, c_y)], fill=col)
                
            # Order Book Snippet
            draw.text((sx + 40, sy + 780), "Live Order Depth", font=font_ui_bold, fill=(255, 255, 255))
            orders = [
                ("67,845.00", "1.4285", "BUY", (52, 211, 153)),
                ("67,842.50", "3.8500", "BUY", (52, 211, 153)),
                ("67,841.00", "0.9500", "BUY", (52, 211, 153)),
                ("67,839.00", "2.1200", "SELL", (244, 63, 94)),
                ("67,837.50", "4.6500", "SELL", (244, 63, 94))
            ]
            oy = sy + 830
            for price, amt, side, col in orders:
                draw.text((sx + 50, oy), price, font=font_ui_bold, fill=col)
                draw.text((sx + 350, oy), f"{amt} BTC", font=font_ui_reg, fill=(200, 205, 215))
                draw.text((sx + sw - 140, oy), side, font=font_ui_bold, fill=col)
                oy += 60
                
            # Action Buttons
            draw.rounded_rectangle([sx + 30, sy + 1180, sx + sw//2 - 15, sy + 1280], radius=20, fill=(52, 211, 153))
            draw.text((sx + sw//4 - 50, sy + 1210), "BUY / LONG", font=font_ui_bold, fill=(11, 14, 17))
            draw.rounded_rectangle([sx + sw//2 + 15, sy + 1180, sx + sw - 30, sy + 1280], radius=20, fill=(244, 63, 94))
            draw.text((sx + 3*sw//4 - 60, sy + 1210), "SELL / SHORT", font=font_ui_bold, fill=(255, 255, 255))

        elif cfg['mockup_type'] == 'juwishcoin':
            # JuwishCoin Protocol Card
            draw.text((sx + 40, sy + 80), "JuwishCoin Protocol (JWC)", font=font_ui_bold, fill=(240, 185, 11))
            draw.text((sx + 40, sy + 125), "Direct PancakeSwap Liquidity Pool", font=font_ui_reg, fill=(156, 163, 175))
            
            # Big Valuation Banner
            draw.rounded_rectangle([sx + 30, sy + 180, sx + sw - 30, sy + 440], radius=24, fill=(24, 28, 36, 240), outline=(240, 185, 11, 90), width=2)
            med_ui = medallion.resize((150, 150), Image.Resampling.LANCZOS)
            shot.paste(med_ui, (sx + 55, sy + 215), med_ui)
            draw.text((sx + 240, sy + 225), "Live Peg Valuation", font=font_ui_sm, fill=(156, 163, 175))
            draw.text((sx + 240, sy + 260), "1 JWC = $3.00 USD", font=font_price, fill=(240, 185, 11))
            draw.text((sx + 240, sy + 335), "PancakeSwap Pool Verified  •  0% Fee", font=font_ui_reg, fill=(52, 211, 153))
            
            # Interactive Buy Calculator
            draw.text((sx + 40, sy + 480), "Instant Deposit Calculator", font=font_ui_bold, fill=(255, 255, 255))
            
            # Input You Pay
            draw.rounded_rectangle([sx + 30, sy + 530, sx + sw - 30, sy + 640], radius=20, fill=(18, 22, 28, 255), outline=(255, 255, 255, 20), width=2)
            draw.text((sx + 60, sy + 550), "You Pay (USD)", font=font_ui_sm, fill=(156, 163, 175))
            draw.text((sx + 60, sy + 580), "$300.00", font=font_price, fill=(255, 255, 255))
            draw.text((sx + sw - 140, sy + 575), "USD", font=font_ui_bold, fill=(240, 185, 11))
            
            # Arrow
            draw.text((sx + sw//2 - 20, sy + 665), "↓", font=font_price, fill=(240, 185, 11))
            
            # Input You Receive
            draw.rounded_rectangle([sx + 30, sy + 740, sx + sw - 30, sy + 850], radius=20, fill=(18, 22, 28, 255), outline=(240, 185, 11, 140), width=2)
            draw.text((sx + 60, sy + 760), "You Receive (Direct Wallet Cash Credit)", font=font_ui_sm, fill=(52, 211, 153))
            draw.text((sx + 60, sy + 790), "100.00 JWC", font=font_price, fill=(240, 185, 11))
            draw.text((sx + sw - 140, sy + 785), "JWC", font=font_ui_bold, fill=(255, 255, 255))
            
            # Presets chips
            draw.text((sx + 40, sy + 880), "Quick Presets:", font=font_ui_sm, fill=(156, 163, 175))
            chips = ["$30", "$90", "$300", "$600", "$1.5k", "$3k"]
            cx = sx + 40
            for chip in chips:
                is_active = (chip == "$300")
                fill_bg = (240, 185, 11, 40) if is_active else (24, 28, 36)
                border_col = (240, 185, 11) if is_active else (255, 255, 255, 20)
                text_col = (240, 185, 11) if is_active else (200, 205, 215)
                draw.rounded_rectangle([cx, sy + 920, cx + 115, sy + 975], radius=14, fill=fill_bg, outline=border_col, width=1)
                draw.text((cx + 25, sy + 935), chip, font=font_ui_bold, fill=text_col)
                cx += 130
                
            # CTA button
            draw.rounded_rectangle([sx + 30, sy + 1040, sx + sw - 30, sy + 1150], radius=24, fill=(240, 185, 11))
            draw.text((sx + sw//2 - 180, sy + 1075), "Instant Buy & Credit Wallet", font=font_ui_bold, fill=(11, 14, 17))

        elif cfg['mockup_type'] == 'wallet':
            # Wallet Header
            draw.text((sx + 40, sy + 80), "Multi-Currency Portfolio", font=font_ui_bold, fill=(255, 255, 255))
            draw.text((sx + 40, sy + 130), "Total Net Balance", font=font_ui_sm, fill=(156, 163, 175))
            draw.text((sx + 40, sy + 165), "$142,850.00", font=font_price, fill=(255, 255, 255))
            draw.text((sx + 420, sy + 180), "+12.4% this month", font=font_ui_bold, fill=(52, 211, 153))
            
            # Action Buttons Row
            actions = [("Deposit", (240, 185, 11)), ("Withdraw", (255, 255, 255)), ("Trade", (52, 211, 153)), ("Transfer", (156, 163, 175))]
            ax = sx + 40
            for a_name, a_col in actions:
                draw.rounded_rectangle([ax, sy + 270, ax + 175, sy + 350], radius=18, fill=(24, 28, 36), outline=(255, 255, 255, 20), width=1)
                draw.text((ax + 35, sy + 295), a_name, font=font_ui_bold, fill=a_col)
                ax += 200
                
            # Assets breakdown
            draw.text((sx + 40, sy + 400), "Asset Distribution", font=font_ui_bold, fill=(255, 255, 255))
            assets = [
                ("JuwishCoin (JWC)", "15,000.00 JWC", "$45,000.00", "+34.8%"),
                ("US Dollar Cash", "$38,400.00", "$38,400.00", "0.0%"),
                ("Bitcoin (BTC)", "0.5500 BTC", "$37,312.28", "+4.2%"),
                ("Apple Inc (AAPL)", "120 Shares", "$22,137.60", "+1.8%")
            ]
            ay = sy + 460
            for name, qty, val, chg in assets:
                draw.rounded_rectangle([sx + 30, ay, sx + sw - 30, ay + 110], radius=18, fill=(18, 22, 28, 220), outline=(255, 255, 255, 15), width=1)
                draw.text((sx + 60, ay + 22), name, font=font_ui_bold, fill=(255, 255, 255))
                draw.text((sx + 60, ay + 62), qty, font=font_ui_reg, fill=(156, 163, 175))
                draw.text((sx + sw - 220, ay + 22), val, font=font_ui_bold, fill=(240, 185, 11))
                draw.text((sx + sw - 150, ay + 62), chg, font=font_ui_sm, fill=(52, 211, 153))
                ay += 135

        elif cfg['mockup_type'] == 'staking':
            # Staking Header
            draw.text((sx + 40, sy + 80), "Staking Vaults & Yield", font=font_ui_bold, fill=(255, 255, 255))
            draw.text((sx + 40, sy + 130), "Total Value Staked", font=font_ui_sm, fill=(156, 163, 175))
            draw.text((sx + 40, sy + 165), "$85,000.00", font=font_price, fill=(240, 185, 11))
            draw.text((sx + 380, sy + 180), "Earns 14.5% APY", font=font_ui_bold, fill=(52, 211, 153))
            
            # Staking Plans Grid
            plans = [
                ("Genesis JWC Vault", "14.5% APY", "Daily Compound", "$1,000 Min"),
                ("Crypto Growth Plan", "18.2% APY", "Weekly Payout", "$2,500 Min"),
                ("Bluechip Forex Yield", "11.0% APY", "Instant Liquidity", "$500 Min")
            ]
            py = sy + 270
            for p_title, p_apy, p_pay, p_min in plans:
                draw.rounded_rectangle([sx + 30, py, sx + sw - 30, py + 180], radius=22, fill=(24, 28, 36, 240), outline=(240, 185, 11, 80), width=2)
                draw.text((sx + 60, py + 30), p_title, font=font_ui_bold, fill=(255, 255, 255))
                draw.text((sx + 60, py + 75), f"{p_pay} • {p_min}", font=font_ui_reg, fill=(156, 163, 175))
                draw.text((sx + sw - 240, py + 40), p_apy, font=font_price, fill=(52, 211, 153))
                # Button
                draw.rounded_rectangle([sx + 60, py + 115, sx + 220, py + 160], radius=12, fill=(240, 185, 11))
                draw.text((sx + 95, py + 125), "Stake Now", font=font_ui_sm, fill=(11, 14, 17))
                py += 210

        elif cfg['mockup_type'] == 'security':
            # Security Header
            draw.text((sx + 40, sy + 80), "Security & Compliance Center", font=font_ui_bold, fill=(255, 255, 255))
            draw.text((sx + 40, sy + 130), "Institutional Grade Protection", font=font_ui_reg, fill=(52, 211, 153))
            
            features = [
                ("Multi-Signature Vaults", "Zero single-point-of-failure cold storage custody"),
                ("256-Bit Financial Encryption", "Military-grade data transit & storage encryption"),
                ("Biometric 2FA Protocol", "Hardware key, Google Authenticator & Face ID protection"),
                ("Continuous AML / KYC Audit", "International regulatory standards & verified compliance"),
                ("Segregated Client Accounts", "Funds stored 1:1 with Tier-1 banking partners")
            ]
            fy_item = sy + 200
            for f_title, f_desc in features:
                draw.rounded_rectangle([sx + 30, fy_item, sx + sw - 30, fy_item + 125], radius=18, fill=(18, 22, 28, 220), outline=(16, 185, 129, 60), width=1)
                draw.text((sx + 60, fy_item + 22), f"✓ {f_title}", font=font_ui_bold, fill=(52, 211, 153))
                draw.text((sx + 60, fy_item + 65), f_desc, font=font_ui_reg, fill=(180, 190, 205))
                fy_item += 145

        final_rgb = shot.convert('RGB')
        out_shot = os.path.join(shots_dir, cfg['filename'])
        final_rgb.save(out_shot, 'PNG', optimize=True)
        final_rgb.save(os.path.join(DOWNLOADS_DIR, cfg['filename']), 'PNG', optimize=True)
        print(f"  [OK] Saved screenshot {idx}: {out_shot}")

if __name__ == '__main__':
    generate_app_icon()
    generate_feature_graphic()
    generate_screenshots()
    print("ALL PLAY STORE GRAPHIC ASSETS GENERATED SUCCESSFULLY!")
