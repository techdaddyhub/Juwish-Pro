#!/usr/bin/env python3
"""
Generate Native Android App Icons for JuwishPro using official Star of David medallion
"""
import os
from PIL import Image

def main():
    root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    src_path = os.path.join(root, 'public/assets/images/logo-square.png')
    if not os.path.exists(src_path):
        src_path = os.path.join(root, 'public/assets/images/juwishcoin.png')

    medallion = Image.open(src_path).convert('RGBA')

    # Dark obsidian background (#0B0E11)
    master_1024 = Image.new('RGBA', (1024, 1024), (11, 14, 17, 255))
    medallion_900 = medallion.resize((900, 900), Image.Resampling.LANCZOS)
    master_1024.paste(medallion_900, (62, 62), medallion_900)

    round_1024 = medallion.resize((1024, 1024), Image.Resampling.LANCZOS)

    res_dir = os.path.join(root, 'android/app/src/main/res')
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    for folder, size in android_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        # Square
        sq = master_1024.resize((size, size), Image.Resampling.LANCZOS)
        sq.save(os.path.join(folder_path, 'ic_launcher.png'), 'PNG')
        # Round
        rd = round_1024.resize((size, size), Image.Resampling.LANCZOS)
        rd.save(os.path.join(folder_path, 'ic_launcher_round.png'), 'PNG')

    print(f"[OK] Android launcher icons generated successfully from {src_path}")

if __name__ == '__main__':
    main()
