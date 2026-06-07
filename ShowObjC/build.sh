#!/bin/bash
# ═══════════════════════════════════════════
# Show — macOS Native Build (ObjC + WKWebView)
# ═══════════════════════════════════════════

set -euo pipefail

APP_NAME="Show"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"
BUILD_ID="$(date +%Y%m%d-%H%M%S)"

echo ""
echo "═══ Building $APP_NAME ($BUILD_ID) ═══"

pkill -x "$APP_NAME" 2>/dev/null || true
sleep 0.2

# ─── Directories ───
rm -rf "$APP_NAME.app"
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources/Web"

# ─── Compile (ObjC, ~1 second) ───
echo "→ Compiling..."
clang -fobjc-arc \
    -framework Cocoa \
    -framework WebKit \
    -o "$APP_NAME.app/Contents/MacOS/$APP_NAME" \
    main.m
echo "  ✓ Compiled"

# ─── Bundle ───
cp Info.plist "$APP_NAME.app/Contents/"
sed "s/__SHOW_BUILD_ID__/$BUILD_ID/g" index.html > "$APP_NAME.app/Contents/Resources/Web/index.html"
cp mp4-muxer.mjs "$APP_NAME.app/Contents/Resources/Web/mp4-muxer.mjs"

# ─── Sign (ad-hoc) ───
codesign --force --deep --sign - "$APP_NAME.app" 2>/dev/null || true
echo "  ✓ Signed"

echo ""
echo "✅ 构建成功!  $(pwd)/$APP_NAME.app"
echo "运行: open $APP_NAME.app"
echo ""
