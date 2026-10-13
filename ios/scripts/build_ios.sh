#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT/build"
mkdir -p "$BUILD_DIR"

if [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

SDK="iphoneos"
SDK_PATH=$(xcrun --sdk "$SDK" --show-sdk-path 2>/dev/null || true)
TARGET_ARCH="arm64-apple-ios15.0"

if [ -z "$SDK_PATH" ]; then
    echo "--> iphoneos SDK not found, checking iphonesimulator..."
    SDK="iphonesimulator"
    SDK_PATH=$(xcrun --sdk "$SDK" --show-sdk-path 2>/dev/null || true)
    TARGET_ARCH="arm64-apple-ios15.0-simulator"
fi

if [ -z "$SDK_PATH" ]; then
    echo "ERROR: No iOS SDK found via xcrun."
    exit 1
fi

echo "--> Using SDK: $SDK at $SDK_PATH"

echo "--> Compiling JuwishPro Client iOS..."
rm -rf "$BUILD_DIR/client-payload"
mkdir -p "$BUILD_DIR/client-payload/Payload/JuwishPro.app"
xcrun -sdk "$SDK" swiftc -O -parse-as-library \
    -target "$TARGET_ARCH" \
    -sdk "$SDK_PATH" \
    -framework UIKit \
    -framework WebKit \
    -framework Foundation \
    "$ROOT/JuwishPro/AppDelegate.swift" \
    -o "$BUILD_DIR/client-payload/Payload/JuwishPro.app/JuwishPro"

cp "$ROOT/JuwishPro/Info.plist" "$BUILD_DIR/client-payload/Payload/JuwishPro.app/Info.plist"
cp "$ROOT/JuwishPro/"AppIcon*.png "$BUILD_DIR/client-payload/Payload/JuwishPro.app/" 2>/dev/null || true

cd "$BUILD_DIR/client-payload"
zip -r -y "$BUILD_DIR/JuwishPro-Client.ipa" Payload
cd "$ROOT"

echo "--> Compiling JuwishPro Admin iOS..."
rm -rf "$BUILD_DIR/admin-payload"
mkdir -p "$BUILD_DIR/admin-payload/Payload/JuwishProAdmin.app"
xcrun -sdk "$SDK" swiftc -O -parse-as-library \
    -target "$TARGET_ARCH" \
    -sdk "$SDK_PATH" \
    -framework UIKit \
    -framework WebKit \
    -framework Foundation \
    "$ROOT/JuwishProAdmin/AppDelegate.swift" \
    -o "$BUILD_DIR/admin-payload/Payload/JuwishProAdmin.app/JuwishProAdmin"

cp "$ROOT/JuwishProAdmin/Info.plist" "$BUILD_DIR/admin-payload/Payload/JuwishProAdmin.app/Info.plist"
cp "$ROOT/JuwishProAdmin/"AppIcon*.png "$BUILD_DIR/admin-payload/Payload/JuwishProAdmin.app/" 2>/dev/null || true

cd "$BUILD_DIR/admin-payload"
zip -r -y "$BUILD_DIR/JuwishPro-Admin.ipa" Payload
cd "$ROOT"

echo "[OK] iOS Client and Admin IPAs built successfully in $BUILD_DIR"
