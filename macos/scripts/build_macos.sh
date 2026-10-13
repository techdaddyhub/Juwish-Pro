#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT/build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/JuwishPro.app/Contents/MacOS"
mkdir -p "$BUILD_DIR/JuwishPro.app/Contents/Resources"
mkdir -p "$BUILD_DIR/JuwishProAdmin.app/Contents/MacOS"
mkdir -p "$BUILD_DIR/JuwishProAdmin.app/Contents/Resources"

# Generate icons if possible
python3 "$ROOT/scripts/generate_macos_icons.py" 2>/dev/null || true

compile_universal() {
    local src="$1"
    local out="$2"
    local tmp_arm64="${out}_arm64"
    local tmp_x86="${out}_x86_64"

    if xcrun swiftc -O -target arm64-apple-macos11.0 "$src" -o "$tmp_arm64" 2>/dev/null && \
       xcrun swiftc -O -target x86_64-apple-macos11.0 "$src" -o "$tmp_x86" 2>/dev/null; then
        lipo -create -output "$out" "$tmp_arm64" "$tmp_x86"
        rm -f "$tmp_arm64" "$tmp_x86"
        echo "--> Successfully generated Universal (Apple Silicon & Intel) binary for $out"
    else
        swiftc -O "$src" -o "$out"
        echo "--> Generated native macOS binary for $out"
    fi
}

echo "--> Compiling JuwishPro Client macOS app..."
compile_universal "$ROOT/Client/main.swift" "$BUILD_DIR/JuwishPro.app/Contents/MacOS/JuwishPro"
cp "$ROOT/Client/Info.plist" "$BUILD_DIR/JuwishPro.app/Contents/Info.plist"
if [ -f "$ROOT/Client/AppIcon.icns" ]; then
    cp "$ROOT/Client/AppIcon.icns" "$BUILD_DIR/JuwishPro.app/Contents/Resources/"
fi

echo "--> Compiling JuwishPro Admin macOS app..."
compile_universal "$ROOT/Admin/main.swift" "$BUILD_DIR/JuwishProAdmin.app/Contents/MacOS/JuwishProAdmin"
cp "$ROOT/Admin/Info.plist" "$BUILD_DIR/JuwishProAdmin.app/Contents/Info.plist"
if [ -f "$ROOT/Admin/AppIcon.icns" ]; then
    cp "$ROOT/Admin/AppIcon.icns" "$BUILD_DIR/JuwishProAdmin.app/Contents/Resources/"
fi

cd "$BUILD_DIR"
zip -r -y "JuwishPro-macOS-Client.zip" "JuwishPro.app"
zip -r -y "JuwishPro-macOS-Admin.zip" "JuwishProAdmin.app"
cd "$ROOT"

echo "[OK] macOS Client and Admin applications built successfully in $BUILD_DIR"
