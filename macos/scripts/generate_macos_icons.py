#!/usr/bin/env python3
"""
Generate macOS App Icons for JuwishPro Client and Admin
"""
import os
import subprocess
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

    for target in ['Client', 'Admin']:
        iconset_dir = os.path.join(root, f'macos/{target}/AppIcon.iconset')
        os.makedirs(iconset_dir, exist_ok=True)

        sizes = [
            (16, 'icon_16x16.png'),
            (32, 'icon_16x16@2x.png'),
            (32, 'icon_32x32.png'),
            (64, 'icon_32x32@2x.png'),
            (128, 'icon_128x128.png'),
            (256, 'icon_128x128@2x.png'),
            (256, 'icon_256x256.png'),
            (512, 'icon_256x256@2x.png'),
            (512, 'icon_512x512.png'),
            (1024, 'icon_512x512@2x.png'),
        ]

        for sz, fname in sizes:
            resized = master_1024.resize((sz, sz), Image.Resampling.LANCZOS)
            resized.save(os.path.join(iconset_dir, fname), 'PNG')

        # Also save 512x512 AppIcon.png
        master_1024.resize((512, 512), Image.Resampling.LANCZOS).save(
            os.path.join(root, f'macos/{target}/AppIcon.png'), 'PNG'
        )

        # If iconutil is available (macOS), convert to .icns
        try:
            icns_path = os.path.join(root, f'macos/{target}/AppIcon.icns')
            subprocess.run(['iconutil', '-c', 'icns', iconset_dir, '-o', icns_path], check=True)
            print(f"[OK] Generated {icns_path}")
        except Exception:
            pass

    print("[OK] macOS icon assets generated successfully.")

if __name__ == '__main__':
    main()

