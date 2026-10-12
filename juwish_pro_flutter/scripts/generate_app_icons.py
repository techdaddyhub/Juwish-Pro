#!/usr/bin/env python3
import os
from PIL import Image

def generate_icons():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    src_path = os.path.join(root, 'assets/images/logo-square.png')
    if not os.path.exists(src_path):
        src_path = os.path.join(root, 'assets/images/juwishcoin.png')
    
    base_img = Image.open(src_path).convert('RGBA')

    # Save 1024x1024 master
    base_1024 = base_img.resize((1024, 1024), Image.Resampling.LANCZOS)
    base_1024.save(os.path.join(root, 'assets/images/app_icon_1024.png'))

    # 1. Android Mipmaps
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    for folder, size in android_sizes.items():
        res_dir = os.path.join(root, 'android/app/src/main/res', folder)
        os.makedirs(res_dir, exist_ok=True)
        icon = base_img.resize((size, size), Image.Resampling.LANCZOS)
        icon.save(os.path.join(res_dir, 'ic_launcher.png'), 'PNG')
        icon.save(os.path.join(res_dir, 'ic_launcher_round.png'), 'PNG')

    # 2. iOS AppIcon set
    ios_dir = os.path.join(root, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
    os.makedirs(ios_dir, exist_ok=True)
    ios_sizes = {
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
    }
    for name, size in ios_sizes.items():
        icon = base_img.resize((size, size), Image.Resampling.LANCZOS)
        icon.save(os.path.join(ios_dir, name), 'PNG')

    # iOS 1024x1024 marketing (opaque background required by App Store)
    bg = Image.new('RGB', (1024, 1024), (11, 14, 17))
    medallion = base_img.resize((960, 960), Image.Resampling.LANCZOS)
    bg.paste(medallion, (32, 32), medallion)
    bg.save(os.path.join(ios_dir, 'Icon-App-1024x1024@1x.png'), 'PNG')

    # 3. macOS AppIcon set
    macos_dir = os.path.join(root, 'macos/Runner/Assets.xcassets/AppIcon.appiconset')
    os.makedirs(macos_dir, exist_ok=True)
    macos_sizes = {
        'app_icon_16.png': 16,
        'app_icon_32.png': 32,
        'app_icon_64.png': 64,
        'app_icon_128.png': 128,
        'app_icon_256.png': 256,
        'app_icon_512.png': 512,
        'app_icon_1024.png': 1024,
    }
    for name, size in macos_sizes.items():
        icon = base_img.resize((size, size), Image.Resampling.LANCZOS)
        icon.save(os.path.join(macos_dir, name), 'PNG')

    # 4. Windows ICO
    win_dir = os.path.join(root, 'windows/runner/resources')
    os.makedirs(win_dir, exist_ok=True)
    ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    base_img.save(os.path.join(win_dir, 'app_icon.ico'), format='ICO', sizes=ico_sizes)

    # 5. Web icons
    web_dir = os.path.join(root, 'web/icons')
    os.makedirs(web_dir, exist_ok=True)
    for name, size in [('Icon-192.png', 192), ('Icon-512.png', 512), ('Icon-maskable-192.png', 192), ('Icon-maskable-512.png', 512)]:
        icon = base_img.resize((size, size), Image.Resampling.LANCZOS)
        icon.save(os.path.join(web_dir, name), 'PNG')

    print('[OK] JuwishPro icons generated successfully across all platforms.')

if __name__ == '__main__':
    generate_icons()

