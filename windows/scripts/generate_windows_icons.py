#!/usr/bin/env python3
"""
Generate Windows .ico for JuwishPro Client and Admin
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
    master = Image.new('RGBA', (512, 512), (11, 14, 17, 255))
    medallion_resized = medallion.resize((450, 450), Image.Resampling.LANCZOS)
    master.paste(medallion_resized, (31, 31), medallion_resized)

    windows_dir = os.path.join(root, 'windows')
    os.makedirs(windows_dir, exist_ok=True)

    client_dir = os.path.join(windows_dir, 'JuwishPro.Client')
    admin_dir = os.path.join(windows_dir, 'JuwishPro.Admin')
    os.makedirs(client_dir, exist_ok=True)
    os.makedirs(admin_dir, exist_ok=True)

    ico_sizes = [(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)]
    master.save(os.path.join(client_dir, 'app.ico'), format='ICO', sizes=ico_sizes)
    master.save(os.path.join(admin_dir, 'app.ico'), format='ICO', sizes=ico_sizes)

    print(f"[OK] Generated Windows icons for Client and Admin from {src_path}")

if __name__ == '__main__':
    main()
