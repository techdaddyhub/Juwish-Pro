#!/usr/bin/env python3
import os
from PIL import Image, ImageDraw, ImageFont

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
    except Exception:
        return ImageFont.load_default()


def alpha_rounded_rect(base_img, box, radius, fill=None, outline=None, width=1, **kwargs):
    """Draw a semi-transparent rounded rectangle with proper alpha compositing."""
    fill = kwargs.get('fill_rgba', fill)
    outline = kwargs.get('outline_rgba', outline)
    overlay = Image.new('RGBA', base_img.size, (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)
    odraw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)
    return Image.alpha_composite(base_img, overlay)


def draw_radial_gradient(base_img, center, max_radius, color_inner, color_outer):
    overlay = Image.new('RGBA', base_img.size, (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)
    cx, cy = center
    steps = 40
    for i in range(steps, 0, -1):
        r = int(max_radius * (i / steps))
        factor = i / steps
        alpha = int(color_inner[3] * (1 - factor) + color_outer[3] * factor)
        r_c = int(color_inner[0] * (1 - factor) + color_outer[0] * factor)
        g_c = int(color_inner[1] * (1 - factor) + color_outer[1] * factor)
        b_c = int(color_inner[2] * (1 - factor) + color_outer[2] * factor)
        odraw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_c, g_c, b_c, alpha))
    return Image.alpha_composite(base_img, overlay)


def draw_vector_check(draw, cx, cy, size, color, width=3):
    """Draw a crisp checkmark vector instead of relying on font glyph support."""
    pts = [
        (cx - size * 0.45, cy + size * 0.02),
        (cx - size * 0.10, cy + size * 0.38),
        (cx + size * 0.50, cy - size * 0.35),
    ]
    draw.line(pts, fill=color, width=width, joint='curve')


def draw_vector_down_arrow(draw, cx, cy, size, color, width=4):
    """Draw a crisp downward arrow vector."""
    top = cy - size * 0.45
    bot = cy + size * 0.45
    draw.line([(cx, top), (cx, bot)], fill=color, width=width)
    draw.line([(cx - size * 0.32, bot - size * 0.32), (cx, bot), (cx + size * 0.32, bot - size * 0.32)],
              fill=color, width=width, joint='curve')


def wrap_lines(draw, text, font, max_width):
    words = text.split()
    lines = []
    cur = []
    for w in words:
        trial = ' '.join(cur + [w])
        if draw.textlength(trial, font=font) <= max_width or not cur:
            cur.append(w)
        else:
            lines.append(' '.join(cur))
            cur = [w]
    if cur:
        lines.append(' '.join(cur))
    return lines


def draw_centered_text(draw, box, text, font, fill):
    x1, y1, x2, y2 = box
    cx = (x1 + x2) / 2
    cy = (y1 + y2) / 2
    draw.text((cx, cy), text, font=font, fill=fill, anchor='mm')


def draw_bottom_nav(base_img, sx, sy, sw, sh, active_tab):
    """Draw a realistic mobile bottom navigation bar inside the phone mockup."""
    bar_h = 110
    by1 = sy + sh - bar_h - 14
    by2 = sy + sh - 14
    base_img = alpha_rounded_rect(base_img, [sx + 18, by1, sx + sw - 18, by2], radius=28,
                                  fill=(18, 22, 28, 245), outline=(255, 255, 255, 25), width=2)
    draw = ImageDraw.Draw(base_img)
    tabs = ['Markets', 'JWC Pay', 'Wallet', 'Staking', 'Security']
    font_nav = get_font(FONT_BOLD, 21)
    col_w = (sw - 36) / len(tabs)
    for i, t in enumerate(tabs):
        cx = int(sx + 18 + col_w * (i + 0.5))
        is_active = (t == active_tab)
        col = (240, 185, 11) if is_active else (140, 150, 165)
        dot_r = 12 if is_active else 9
        draw.ellipse([cx - dot_r, by1 + 24 - dot_r, cx + dot_r, by1 + 24 + dot_r],
                     fill=col if is_active else (55, 65, 81), outline=col, width=2)
        draw.text((cx, by1 + 68), t, font=font_nav, fill=col, anchor='mm')
    return base_img


def generate_app_icon():
    print("Generating full-bleed 512x512 App Icon...")
    size = (512, 512)
    img = Image.new('RGBA', size, (11, 14, 17, 255))
    img = draw_radial_gradient(img, (256, 215), 260, (240, 185, 11, 80), (11, 14, 17, 0))

    medallion = Image.open(MEDALLION_PATH).convert('RGBA')
    med_size = 336
    medallion_resized = medallion.resize((med_size, med_size), Image.Resampling.LANCZOS)
    img.paste(medallion_resized, ((512 - med_size) // 2, 42), medallion_resized)

    # Bottom pill cleanly centered with generous vertical padding so J never touches borders
    pill_box = [106, 404, 406, 468]
    img = alpha_rounded_rect(img, pill_box, radius=20, fill=(22, 26, 33, 255), outline=(240, 185, 11, 180), width=2)
    draw = ImageDraw.Draw(img)

    font_juwish = get_font(FONT_EXTRA_BOLD, 30)
    font_pro = get_font(FONT_EXTRA_BOLD, 22)

    draw.text((212, 436), "JUWISH", font=font_juwish, fill=(255, 255, 255), anchor='mm')
    pro_box = [294, 418, 376, 454]
    draw.rounded_rectangle(pro_box, radius=8, fill=(240, 185, 11, 255))
    draw_centered_text(draw, pro_box, "PRO", font_pro, (11, 14, 17))

    final_rgb = img.convert('RGB')
    icon_path = os.path.join(OUT_DIR, 'app_icon_512x512.png')
    final_rgb.save(icon_path, 'PNG', optimize=True)
    final_rgb.save(os.path.join(DOWNLOADS_DIR, 'app_icon_512x512.png'), 'PNG', optimize=True)
    print(f"  [OK] Saved: {icon_path}")


def generate_feature_graphic():
    print("Generating 1024x500 Feature Graphic (Banner)...")
    size = (1024, 500)
    img = Image.new('RGBA', size, (11, 14, 17, 255))
    img = draw_radial_gradient(img, (235, 250), 340, (240, 185, 11, 65), (11, 14, 17, 0))
    img = draw_radial_gradient(img, (860, 140), 290, (16, 185, 129, 35), (11, 14, 17, 0))

    # Subtle grid
    grid_overlay = Image.new('RGBA', size, (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(grid_overlay)
    for x in range(0, 1024, 64):
        gdraw.line([(x, 0), (x, 500)], fill=(255, 255, 255, 10), width=1)
    for y in range(0, 500, 64):
        gdraw.line([(0, y), (1024, y)], fill=(255, 255, 255, 10), width=1)
    img = Image.alpha_composite(img, grid_overlay)

    # Medallion on left
    medallion = Image.open(MEDALLION_PATH).convert('RGBA')
    medallion_resized = medallion.resize((330, 330), Image.Resampling.LANCZOS)
    img.paste(medallion_resized, (65, 85), medallion_resized)

    # Right column (x from 435 to 975 -> 540px width)
    font_title = get_font(FONT_EXTRA_BOLD, 56)
    font_pro = get_font(FONT_EXTRA_BOLD, 34)
    font_sub = get_font(FONT_BOLD, 21)
    font_desc = get_font(FONT_REGULAR, 16)
    font_badge = get_font(FONT_BOLD, 14)

    draw = ImageDraw.Draw(img)
    draw.text((435, 76), "JUWISH", font=font_title, fill=(255, 255, 255))
    pro_box = [678, 86, 778, 134]
    draw.rounded_rectangle(pro_box, radius=10, fill=(240, 185, 11, 255))
    draw_centered_text(draw, pro_box, "PRO", font_pro, (11, 14, 17))

    draw.text((437, 152), "Multi-Asset Crypto, Stocks & Staking Platform", font=font_sub, fill=(240, 185, 11))
    draw.text((437, 186), "Institutional Trading  •  JuwishCoin Protocol  •  Automated Yield", font=font_desc, fill=(195, 203, 214))

    # Feature pills Row 1
    badges_r1 = [
        ("JWC / USD • $3.00", (240, 185, 11)),
        ("PancakeSwap Rate", (56, 189, 248)),
        ("Up to 14.5% APY", (52, 211, 153)),
    ]
    cur_x = 437
    for b_text, b_color in badges_r1:
        tw = int(draw.textlength(b_text, font=font_badge))
        box = [cur_x, 232, cur_x + tw + 26, 268]
        img = alpha_rounded_rect(img, box, radius=18, fill=(22, 27, 34, 240), outline=(b_color[0], b_color[1], b_color[2], 200), width=1)
        draw = ImageDraw.Draw(img)
        draw_centered_text(draw, box, b_text, font_badge, b_color)
        cur_x += tw + 36

    # Feature pills Row 2
    badges_r2 = [
        ("Forex", (234, 236, 239)),
        ("Crypto Futures", (234, 236, 239)),
        ("Global Stocks", (234, 236, 239)),
        ("USD Wallet", (250, 204, 21)),
    ]
    cur_x = 437
    for b_text, b_color in badges_r2:
        tw = int(draw.textlength(b_text, font=font_badge))
        box = [cur_x, 284, cur_x + tw + 26, 318]
        img = alpha_rounded_rect(img, box, radius=17, fill=(22, 27, 34, 220), outline=(255, 255, 255, 50), width=1)
        draw = ImageDraw.Draw(img)
        draw_centered_text(draw, box, b_text, font_badge, b_color)
        cur_x += tw + 36

    # Security Bar with crisp contrast and comfortable padding (no overflow)
    sec_box = [437, 348, 972, 412]
    img = alpha_rounded_rect(img, sec_box, radius=16, fill=(16, 185, 129, 34), outline=(52, 211, 153, 140), width=1)
    draw = ImageDraw.Draw(img)
    draw_vector_check(draw, 466, 380, 16, (52, 211, 153), width=3)
    draw.text((488, 380), "AES-256 Encryption  •  2FA Biometrics  •  Cold Storage Architecture", font=font_badge, fill=(110, 231, 183), anchor='lm')

    draw.rectangle([0, 0, 1023, 499], outline=(240, 185, 11, 80), width=2)

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
            "tag": "MULTI-ASSET TRADING",
            "headline": "Fast Execution Across Crypto, Forex & Global Stocks",
            "sub": "Live Market Depth • Candlestick Charts • Low Spreads",
            "mockup_type": "trading",
            "active_tab": "Markets",
        },
        {
            "filename": "screenshot_2_juwishcoin.png",
            "tag": "JUWISHCOIN PROTOCOL",
            "headline": "PancakeSwap Rate at $3.00 USD per JuwishCoin",
            "sub": "Direct Cash Wallet Credit • Zero Fee • Instant Settlement",
            "mockup_type": "juwishcoin",
            "active_tab": "JWC Pay",
        },
        {
            "filename": "screenshot_3_wallet.png",
            "tag": "UNIFIED USD WALLET",
            "headline": "Manage Fiat, Crypto & JuwishCoin in One Balance",
            "sub": "USD Valuation • Card, Wire & Automated Crypto Deposits",
            "mockup_type": "wallet",
            "active_tab": "Wallet",
        },
        {
            "filename": "screenshot_4_staking.png",
            "tag": "STAKING VAULTS",
            "headline": "Earn Up to 14.5% APY on Digital Assets",
            "sub": "Flexible & Fixed Vaults • Daily Compound Yields",
            "mockup_type": "staking",
            "active_tab": "Staking",
        },
        {
            "filename": "screenshot_5_security.png",
            "tag": "SECURITY & COMPLIANCE",
            "headline": "Multi-Layer Account & Asset Protection",
            "sub": "2FA Biometrics • Cold Reserve Vaults • 24/7 Support",
            "mockup_type": "security",
            "active_tab": "Security",
        }
    ]

    font_tag = get_font(FONT_EXTRA_BOLD, 24)
    font_headline = get_font(FONT_EXTRA_BOLD, 46)
    font_sub = get_font(FONT_BOLD, 25)
    font_ui_bold = get_font(FONT_BOLD, 30)
    font_ui_reg = get_font(FONT_REGULAR, 24)
    font_ui_sm = get_font(FONT_BOLD, 21)
    font_price = get_font(FONT_EXTRA_BOLD, 52)

    for idx, cfg in enumerate(configs, 1):
        shot = Image.new('RGBA', (1080, 2400), (11, 14, 17, 255))
        shot = draw_radial_gradient(shot, (540, 420), 580, (240, 185, 11, 52), (11, 14, 17, 0))
        shot = draw_radial_gradient(shot, (540, 1650), 680, (24, 34, 48, 85), (11, 14, 17, 0))

        # Subtle background lines
        grid = Image.new('RGBA', (1080, 2400), (0, 0, 0, 0))
        gdraw = ImageDraw.Draw(grid)
        for y in range(0, 2400, 120):
            gdraw.line([(0, y), (1080, y)], fill=(255, 255, 255, 8), width=1)
        shot = Image.alpha_composite(shot, grid)

        # Header branding row
        medallion_sm = medallion.resize((60, 60), Image.Resampling.LANCZOS)
        shot.paste(medallion_sm, (84, 78), medallion_sm)
        draw = ImageDraw.Draw(shot)
        draw.text((160, 108), "JUWISHPRO", font=get_font(FONT_EXTRA_BOLD, 32), fill=(255, 255, 255), anchor='lm')

        # Category Tag Pill with proper alpha_composite so gold text is crisp
        tag_w = int(draw.textlength(cfg['tag'], font=font_tag))
        tag_box = [84, 165, 84 + tag_w + 40, 217]
        shot = alpha_rounded_rect(shot, tag_box, radius=16, fill=(240, 185, 11, 38), outline=(240, 185, 11, 200), width=2)
        draw = ImageDraw.Draw(shot)
        draw_centered_text(draw, tag_box, cfg['tag'], font_tag, (252, 213, 53))

        # Wrapped headline (guaranteed inside 912px max width)
        h_lines = wrap_lines(draw, cfg['headline'], font_headline, 912)
        hy = 248
        for hl in h_lines[:2]:
            draw.text((84, hy), hl, font=font_headline, fill=(255, 255, 255))
            hy += 62

        # Wrapped subtitle
        s_lines = wrap_lines(draw, cfg['sub'], font_sub, 912)
        sy_text = hy + 14
        for sl in s_lines[:2]:
            draw.text((84, sy_text), sl, font=font_sub, fill=(156, 163, 175))
            sy_text += 34

        # Phone Mockup Canvas
        fx, fy, fw, fh = 80, 495, 920, 1815
        shot = alpha_rounded_rect(shot, [fx, fy, fx + fw, fy + fh], radius=56,
                                  fill=(20, 24, 31, 255), outline=(240, 185, 11, 130), width=4)
        sx, sy, sw, sh = fx + 18, fy + 18, fw - 36, fh - 36
        shot = alpha_rounded_rect(shot, [sx, sy, sx + sw, sy + sh], radius=44, fill=(11, 14, 17, 255))
        draw = ImageDraw.Draw(shot)

        # Dynamic Island
        draw.rounded_rectangle([sx + sw // 2 - 92, sy + 16, sx + sw // 2 + 92, sy + 48], radius=16, fill=(0, 0, 0, 255))

        if cfg['mockup_type'] == 'trading':
            draw.text((sx + 38, sy + 96), "BTC / USDT", font=font_ui_bold, fill=(255, 255, 255), anchor='lm')
            live_box = [sx + 225, sy + 78, sx + 312, sy + 114]
            shot = alpha_rounded_rect(shot, live_box, radius=10, fill=(16, 185, 129, 45), outline=(52, 211, 153, 140), width=1)
            draw = ImageDraw.Draw(shot)
            draw_centered_text(draw, live_box, "LIVE", font_ui_sm, (52, 211, 153))

            draw.text((sx + 38, sy + 148), "$67,840.50", font=font_price, fill=(255, 255, 255))
            draw.text((sx + 38, sy + 216), "24h: +4.28% (+$2,790.20)   •   Vol: $1.84B", font=font_ui_reg, fill=(52, 211, 153))

            # Chart Panel
            shot = alpha_rounded_rect(shot, [sx + 30, sy + 270, sx + sw - 30, sy + 820], radius=24,
                                      fill=(18, 22, 28, 220), outline=(255, 255, 255, 25), width=2)
            draw = ImageDraw.Draw(shot)
            # Subtle horizontal chart grid
            for cy_g in range(sy + 350, sy + 780, 95):
                draw.line([(sx + 50, cy_g), (sx + sw - 50, cy_g)], fill=(38, 44, 54), width=1)

            candle_pts = [
                (85, 360, 470, True), (138, 420, 445, False), (191, 410, 520, True),
                (244, 505, 475, False), (297, 465, 550, True), (350, 535, 505, False),
                (403, 495, 600, True), (456, 585, 555, False), (509, 550, 645, True),
                (562, 625, 595, False), (615, 590, 675, True), (668, 655, 635, False),
                (721, 630, 720, True), (774, 705, 685, False), (815, 675, 745, True),
            ]
            for cx_o, o_y, c_y, is_green in candle_pts:
                col = (52, 211, 153) if is_green else (244, 63, 94)
                y_hi = sy + 270 + 810 - max(o_y, c_y) - 18
                y_lo = sy + 270 + 810 - min(o_y, c_y) + 18
                draw.line([(sx + cx_o, y_hi), (sx + cx_o, y_lo)], fill=col, width=3)
                draw.rectangle([sx + cx_o - 13, sy + 270 + 810 - max(o_y, c_y),
                                sx + cx_o + 13, sy + 270 + 810 - min(o_y, c_y)], fill=col)

            # Order Depth Card
            shot = alpha_rounded_rect(shot, [sx + 30, sy + 850, sx + sw - 30, sy + 1320], radius=24,
                                      fill=(18, 22, 28, 210), outline=(255, 255, 255, 20), width=1)
            draw = ImageDraw.Draw(shot)
            draw.text((sx + 56, sy + 884), "Live Order Depth", font=font_ui_bold, fill=(255, 255, 255))
            orders = [
                ("67,845.00", "1.4285 BTC", "BUY", (52, 211, 153)),
                ("67,842.50", "3.8500 BTC", "BUY", (52, 211, 153)),
                ("67,841.00", "0.9500 BTC", "BUY", (52, 211, 153)),
                ("67,839.00", "2.1200 BTC", "SELL", (244, 63, 94)),
                ("67,837.50", "4.6500 BTC", "SELL", (244, 63, 94)),
            ]
            oy = sy + 950
            for price, amt, side, col in orders:
                draw.text((sx + 56, oy), price, font=font_ui_bold, fill=col)
                draw.text((sx + sw // 2, oy + 16), amt, font=font_ui_reg, fill=(195, 203, 214), anchor='mm')
                draw.text((sx + sw - 56, oy + 16), side, font=font_ui_bold, fill=col, anchor='rm')
                oy += 68

            # Buy / Sell Buttons cleanly centered
            buy_box = [sx + 30, sy + 1360, sx + sw // 2 - 14, sy + 1465]
            sell_box = [sx + sw // 2 + 14, sy + 1360, sx + sw - 30, sy + 1465]
            draw.rounded_rectangle(buy_box, radius=20, fill=(52, 211, 153))
            draw_centered_text(draw, buy_box, "BUY / LONG", font_ui_bold, (11, 14, 17))
            draw.rounded_rectangle(sell_box, radius=20, fill=(244, 63, 94))
            draw_centered_text(draw, sell_box, "SELL / SHORT", font_ui_bold, (255, 255, 255))

            # Quick stats pill strip above nav
            stat_box = [sx + 30, sy + 1500, sx + sw - 30, sy + 1615]
            shot = alpha_rounded_rect(shot, stat_box, radius=18, fill=(24, 28, 36, 220), outline=(255, 255, 255, 18), width=1)
            draw = ImageDraw.Draw(shot)
            draw.text((sx + 56, sy + 1535), "Open Positions: 3 Active", font=font_ui_sm, fill=(234, 236, 239))
            draw.text((sx + sw - 56, sy + 1558), "+$1,240.80 PnL", font=font_ui_bold, fill=(52, 211, 153), anchor='rm')
            draw.text((sx + 56, sy + 1574), "Cross Margin 10x • Instant Fill", font=font_ui_reg, fill=(140, 150, 165))

        elif cfg['mockup_type'] == 'juwishcoin':
            draw.text((sx + 38, sy + 85), "JuwishCoin Protocol (JWC)", font=font_ui_bold, fill=(240, 185, 11))
            draw.text((sx + 38, sy + 128), "Direct PancakeSwap Liquidity Pool", font=font_ui_reg, fill=(156, 163, 175))

            # Valuation Banner
            shot = alpha_rounded_rect(shot, [sx + 30, sy + 185, sx + sw - 30, sy + 425], radius=24,
                                      fill=(24, 28, 36, 240), outline=(240, 185, 11, 120), width=2)
            med_ui = medallion.resize((142, 142), Image.Resampling.LANCZOS)
            shot.paste(med_ui, (sx + 56, sy + 234), med_ui)
            draw = ImageDraw.Draw(shot)
            draw.text((sx + 225, sy + 228), "Live PancakeSwap Rate", font=font_ui_sm, fill=(156, 163, 175))
            draw.text((sx + 225, sy + 266), "1 JWC = $3.00 USD", font=font_price, fill=(240, 185, 11))
            draw.text((sx + 225, sy + 344), "Verified Liquidity  •  0% Buy Fee", font=font_ui_reg, fill=(52, 211, 153))

            draw.text((sx + 38, sy + 465), "Instant Deposit Calculator", font=font_ui_bold, fill=(255, 255, 255))

            # You Pay Box
            shot = alpha_rounded_rect(shot, [sx + 30, sy + 520, sx + sw - 30, sy + 660], radius=22,
                                      fill=(18, 22, 28, 255), outline=(255, 255, 255, 35), width=2)
            draw = ImageDraw.Draw(shot)
            draw.text((sx + 58, sy + 544), "You Pay (USD)", font=font_ui_sm, fill=(156, 163, 175))
            draw.text((sx + 58, sy + 582), "$300.00", font=font_price, fill=(255, 255, 255))
            draw.text((sx + sw - 58, sy + 590), "USD", font=font_ui_bold, fill=(240, 185, 11), anchor='rm')

            # Crisp Vector Swap Arrow Badge
            draw.ellipse([sx + sw // 2 - 28, sy + 676, sx + sw // 2 + 28, sy + 732],
                         fill=(24, 28, 36), outline=(240, 185, 11), width=2)
            draw_vector_down_arrow(draw, sx + sw // 2, sy + 704, 28, (240, 185, 11), width=4)

            # You Receive Box (generous height so text sits comfortably above border)
            shot = alpha_rounded_rect(shot, [sx + 30, sy + 748, sx + sw - 30, sy + 888], radius=22,
                                      fill=(18, 22, 28, 255), outline=(240, 185, 11, 170), width=2)
            draw = ImageDraw.Draw(shot)
            draw.text((sx + 58, sy + 772), "You Receive (Wallet Cash Credit)", font=font_ui_sm, fill=(52, 211, 153))
            draw.text((sx + 58, sy + 810), "100.00 JWC", font=font_price, fill=(240, 185, 11))
            draw.text((sx + sw - 58, sy + 818), "JWC", font=font_ui_bold, fill=(255, 255, 255), anchor='rm')

            # Preset Chips (rendered cleanly via alpha_rounded_rect + centered text)
            draw.text((sx + 38, sy + 922), "Quick Presets:", font=font_ui_sm, fill=(156, 163, 175))
            chips = ["$30", "$90", "$300", "$600", "$1.5k", "$3k"]
            cx = sx + 30
            chip_w = 126
            gap = 13
            for chip in chips:
                is_active = (chip == "$300")
                fill_bg = (240, 185, 11, 48) if is_active else (24, 28, 36, 255)
                border_col = (240, 185, 11, 230) if is_active else (255, 255, 255, 35)
                text_col = (252, 213, 53) if is_active else (220, 225, 235)
                cbox = [cx, sy + 964, cx + chip_w, sy + 1022]
                shot = alpha_rounded_rect(shot, cbox, radius=14, fill=fill_bg, outline=border_col, width=2 if is_active else 1)
                draw = ImageDraw.Draw(shot)
                draw_centered_text(draw, cbox, chip, font_ui_sm, text_col)
                cx += chip_w + gap

            # CTA Button
            cta_box = [sx + 30, sy + 1068, sx + sw - 30, sy + 1172]
            draw.rounded_rectangle(cta_box, radius=24, fill=(240, 185, 11))
            draw_centered_text(draw, cta_box, "Instant Buy & Credit Wallet", font_ui_bold, (11, 14, 17))

            # Settlement Guarantee Card filling bottom space cleanly
            info_box = [sx + 30, sy + 1218, sx + sw - 30, sy + 1595]
            shot = alpha_rounded_rect(shot, info_box, radius=22, fill=(18, 22, 28, 220), outline=(255, 255, 255, 22), width=1)
            draw = ImageDraw.Draw(shot)
            draw.text((sx + 58, sy + 1252), "Instant Protocol Settlement", font=font_ui_bold, fill=(255, 255, 255))
            rows = [
                ("Settlement Speed", "Instant (< 3 seconds)"),
                ("Conversion Rate", "1 JWC = $3.00 USD Fixed Peg"),
                ("Platform Deposit Fee", "$0.00 (Zero Surcharge)"),
                ("Payment Rails", "BEP-20, USDT, Bank & Card"),
            ]
            ry = sy + 1318
            for rk, rv in rows:
                draw.text((sx + 58, ry), rk, font=font_ui_reg, fill=(156, 163, 175))
                draw.text((sx + sw - 58, ry), rv, font=font_ui_sm, fill=(234, 236, 239), anchor='rt')
                ry += 62

        elif cfg['mockup_type'] == 'wallet':
            draw.text((sx + 38, sy + 85), "Multi-Currency Portfolio", font=font_ui_bold, fill=(255, 255, 255))
            draw.text((sx + 38, sy + 135), "Total Net Balance (USD)", font=font_ui_sm, fill=(156, 163, 175))
            draw.text((sx + 38, sy + 172), "$142,850.00", font=font_price, fill=(255, 255, 255))
            draw.text((sx + sw - 38, sy + 196), "+12.4% (30d)", font=font_ui_bold, fill=(52, 211, 153), anchor='rm')

            # Action Buttons Row (even widths & properly centered text — NO overflow)
            actions = [
                ("Deposit", (240, 185, 11)),
                ("Withdraw", (255, 255, 255)),
                ("Trade", (52, 211, 153)),
                ("Transfer", (195, 203, 214)),
            ]
            btn_w = 190
            btn_gap = 18
            ax = sx + 35
            for a_name, a_col in actions:
                abox = [ax, sy + 275, ax + btn_w, sy + 355]
                shot = alpha_rounded_rect(shot, abox, radius=18, fill=(24, 28, 36, 255), outline=(255, 255, 255, 30), width=1)
                draw = ImageDraw.Draw(shot)
                draw_centered_text(draw, abox, a_name, get_font(FONT_BOLD, 26), a_col)
                ax += btn_w + btn_gap

            draw.text((sx + 38, sy + 408), "Asset Allocation", font=font_ui_bold, fill=(255, 255, 255))
            assets = [
                ("JuwishCoin (JWC)", "15,000.00 JWC", "$45,000.00", "+34.8%"),
                ("US Dollar Cash", "Available USD Liquidity", "$38,400.00", "0.0%"),
                ("Bitcoin (BTC)", "0.5500 BTC", "$37,312.28", "+4.2%"),
                ("Apple Inc (AAPL)", "120 Shares", "$22,137.60", "+1.8%"),
                ("S&P 500 ETF (SPY)", "42 Shares", "$24,570.00", "+2.9%"),
            ]
            ay = sy + 468
            for name, qty, val, chg in assets:
                abox = [sx + 30, ay, sx + sw - 30, ay + 122]
                shot = alpha_rounded_rect(shot, abox, radius=20, fill=(18, 22, 28, 240), outline=(255, 255, 255, 24), width=1)
                draw = ImageDraw.Draw(shot)
                draw.text((sx + 58, ay + 24), name, font=font_ui_bold, fill=(255, 255, 255))
                draw.text((sx + 58, ay + 68), qty, font=font_ui_reg, fill=(156, 163, 175))
                draw.text((sx + sw - 58, ay + 24), val, font=font_ui_bold, fill=(240, 185, 11), anchor='rt')
                draw.text((sx + sw - 58, ay + 68), chg, font=font_ui_sm, fill=(52, 211, 153), anchor='rt')
                ay += 142

            # Recent Activity footer card
            rec_box = [sx + 30, ay + 18, sx + sw - 30, sy + 1615]
            shot = alpha_rounded_rect(shot, rec_box, radius=20, fill=(24, 28, 36, 220), outline=(240, 185, 11, 60), width=1)
            draw = ImageDraw.Draw(shot)
            draw.text((sx + 58, ay + 48), "Recent Settlement", font=font_ui_bold, fill=(255, 255, 255))
            draw.text((sx + 58, ay + 96), "+100.00 JWC Credited ($300.00)", font=font_ui_reg, fill=(52, 211, 153))
            draw.text((sx + 58, ay + 136), "Instant Wire Transfer • Completed", font=font_ui_sm, fill=(156, 163, 175))

        elif cfg['mockup_type'] == 'staking':
            draw.text((sx + 38, sy + 85), "Staking Vaults & Yield", font=font_ui_bold, fill=(255, 255, 255))
            draw.text((sx + 38, sy + 135), "Total Value Staked", font=font_ui_sm, fill=(156, 163, 175))
            draw.text((sx + 38, sy + 172), "$85,000.00", font=font_price, fill=(240, 185, 11))
            draw.text((sx + sw - 38, sy + 196), "Avg 14.5% APY", font=font_ui_bold, fill=(52, 211, 153), anchor='rm')

            plans = [
                ("Genesis JWC Vault", "14.5% APY", "Daily Compound", "$1,000 Min", "90 Days Lock"),
                ("Crypto Growth Plan", "18.2% APY", "Weekly Payout", "$2,500 Min", "180 Days Lock"),
                ("Bluechip Forex Yield", "11.0% APY", "Flexible Withdraw", "$500 Min", "No Lock"),
            ]
            py = sy + 275
            font_apy = get_font(FONT_EXTRA_BOLD, 44)
            for p_title, p_apy, p_pay, p_min, p_term in plans:
                pbox = [sx + 30, py, sx + sw - 30, py + 235]
                shot = alpha_rounded_rect(shot, pbox, radius=24, fill=(24, 28, 36, 245), outline=(240, 185, 11, 110), width=2)
                draw = ImageDraw.Draw(shot)
                draw.text((sx + 58, py + 32), p_title, font=font_ui_bold, fill=(255, 255, 255))
                draw.text((sx + 58, py + 82), f"{p_pay} • {p_min}", font=font_ui_reg, fill=(156, 163, 175))
                draw.text((sx + 58, py + 118), f"Term: {p_term}", font=font_ui_sm, fill=(140, 150, 165))
                # Right-aligned inside card with generous margin so APY never clips outside frame
                draw.text((sx + sw - 58, py + 44), p_apy, font=font_apy, fill=(52, 211, 153), anchor='rt')
                btn_box = [sx + 58, py + 162, sx + 238, py + 210]
                draw.rounded_rectangle(btn_box, radius=14, fill=(240, 185, 11))
                draw_centered_text(draw, btn_box, "Stake Now", font_ui_sm, (11, 14, 17))
                py += 265

            # Projected rewards summary at bottom
            sum_box = [sx + 30, py + 20, sx + sw - 30, sy + 1615]
            shot = alpha_rounded_rect(shot, sum_box, radius=22, fill=(18, 22, 28, 220), outline=(52, 211, 153, 80), width=1)
            draw = ImageDraw.Draw(shot)
            draw.text((sx + 58, py + 55), "Estimated Yield Projection", font=font_ui_bold, fill=(255, 255, 255))
            draw.text((sx + 58, py + 110), "Daily Reward Payouts", font=font_ui_reg, fill=(156, 163, 175))
            draw.text((sx + sw - 58, py + 110), "+$33.76 / day", font=font_ui_bold, fill=(52, 211, 153), anchor='rt')
            draw.text((sx + 58, py + 168), "Annualized Estimate", font=font_ui_reg, fill=(156, 163, 175))
            draw.text((sx + sw - 58, py + 168), "+$12,325.00 / yr", font=font_ui_bold, fill=(240, 185, 11), anchor='rt')
            draw.text((sx + 58, py + 235), "Automated Crediting • On-Chain Proof", font=font_ui_sm, fill=(140, 150, 165))

        elif cfg['mockup_type'] == 'security':
            draw.text((sx + 38, sy + 85), "Security & Compliance Center", font=font_ui_bold, fill=(255, 255, 255))
            draw.text((sx + 38, sy + 132), "Bank-Grade Multi-Layer Protection", font=font_ui_reg, fill=(52, 211, 153))

            features = [
                ("Multi-Signature Vaults", "Zero single-point-of-failure cold storage custody"),
                ("AES-256 Financial Encryption", "TLS 1.3 data transit & hardware-key encryption"),
                ("Biometric & Email 2FA", "Multi-factor login & withdrawal verification codes"),
                ("Continuous AML / KYC Audit", "Identity verification & real-time anomaly defense"),
                ("Segregated Client Balances", "Isolated portfolio accounting & audit receipts"),
                ("24/7 Priority Concierge", "Direct compliance support via info@juwishcoin.online"),
            ]
            fy_item = sy + 198
            for f_title, f_desc in features:
                fbox = [sx + 30, fy_item, sx + sw - 30, fy_item + 178]
                shot = alpha_rounded_rect(shot, fbox, radius=20, fill=(18, 22, 28, 240), outline=(16, 185, 129, 95), width=1)
                draw = ImageDraw.Draw(shot)
                # Crisp green circular check badge instead of missing font glyph
                draw.ellipse([sx + 54, fy_item + 26, sx + 92, fy_item + 64], fill=(16, 185, 129))
                draw_vector_check(draw, sx + 73, fy_item + 45, 20, (11, 14, 17), width=4)
                draw.text((sx + 108, fy_item + 45), f_title, font=font_ui_bold, fill=(52, 211, 153), anchor='lm')
                dlines = wrap_lines(draw, f_desc, font_ui_reg, sw - 120)
                dy_line = fy_item + 88
                for dl in dlines:
                    draw.text((sx + 58, dy_line), dl, font=font_ui_reg, fill=(195, 203, 214))
                    dy_line += 34
                fy_item += 204

            # Security Status Footer Card
            sfoot = [sx + 30, fy_item + 10, sx + sw - 30, sy + 1615]
            shot = alpha_rounded_rect(shot, sfoot, radius=20, fill=(16, 185, 129, 32), outline=(52, 211, 153, 140), width=1)
            draw = ImageDraw.Draw(shot)
            draw_centered_text(draw, sfoot, "Protection Status: ALL SYSTEMS ACTIVE", font_ui_bold, (110, 231, 183))

        # Bottom Navigation Bar on every screen
        shot = draw_bottom_nav(shot, sx, sy, sw, sh, cfg['active_tab'])

        final_rgb = shot.convert('RGB')
        out_shot = os.path.join(shots_dir, cfg['filename'])
        final_rgb.save(out_shot, 'PNG', optimize=True)
        final_rgb.save(os.path.join(DOWNLOADS_DIR, cfg['filename']), 'PNG', optimize=True)
        print(f"  [OK] Saved screenshot {idx}: {out_shot}")


if __name__ == '__main__':
    generate_app_icon()
    generate_feature_graphic()
    generate_screenshots()
    print("ALL PLAY STORE GRAPHIC ASSETS REGENERATED SUCCESSFULLY!")
