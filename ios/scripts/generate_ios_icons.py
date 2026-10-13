#!/usr/bin/env python3
"""
Generate iOS App Icons for JuwishPro Client and Admin
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

    for target in ['JuwishPro', 'JuwishProAdmin']:
        app_dir = os.path.join(root, f'ios/{target}')
        os.makedirs(app_dir, exist_ok=True)

        # iOS sizes
        master_1024.save(os.path.join(app_dir, 'AppIcon-1024.png'), 'PNG')
        master_1024.resize((180, 180), Image.Resampling.LANCZOS).save(os.path.join(app_dir, 'AppIcon-60@3x.png'), 'PNG')
        master_1024.resize((120, 120), Image.Resampling.LANCZOS).save(os.path.join(app_dir, 'AppIcon-60@2x.png'), 'PNG')
        master_1024.resize((87, 87), Image.Resampling.LANCZOS).save(os.path.join(app_dir, 'AppIcon-29@3x.png'), 'PNG')
        master_1024.resize((58, 58), Image.Resampling.LANCZOS).save(os.path.join(app_dir, 'AppIcon-29@2x.png'), 'PNG')
        master_1024.resize((120, 120), Image.Resampling.LANCZOS).save(os.path.join(app_dir, 'AppIcon.png'), 'PNG')

    print("[OK] iOS icon assets generated successfully.")

if __name__ == '__main__':
    main()
