#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR"
PROJECT_DIR="$(dirname "$BUILD_DIR")"
OUTPUT_DIR="$PROJECT_DIR"
APPIMAGE_DIR="$PROJECT_DIR/nvim.AppDir"

echo "=== Building nvim-portable.appimage ==="

# Clean previous build
rm -rf "$APPIMAGE_DIR"

# 1. Download neovim legacy release (glibc 2.17)
echo "[1/6] Downloading neovim v0.11.6 (legacy, glibc 2.17)..."
NVIM_URL="https://github.com/neovim/neovim-releases/releases/download/v0.11.6/nvim-linux-x86_64.tar.gz"
if [ ! -f /tmp/nvim-legacy.tar.gz ]; then
    curl -sL "$NVIM_URL" -o /tmp/nvim-legacy.tar.gz
fi
rm -rf /tmp/nvim-linux-x86_64
tar xzf /tmp/nvim-legacy.tar.gz -C /tmp/

# 2. Create AppDir structure
echo "[2/6] Creating AppDir structure..."
mkdir -p "$APPIMAGE_DIR/usr/bin"
mkdir -p "$APPIMAGE_DIR/usr/lib"
mkdir -p "$APPIMAGE_DIR/usr/share/nvim"
mkdir -p "$APPIMAGE_DIR/usr/share/fonts/TTF"
mkdir -p "$APPIMAGE_DIR/usr/share/fonts/twemoji"
mkdir -p "$APPIMAGE_DIR/nvim-home/config"
mkdir -p "$APPIMAGE_DIR/nvim-home/data"

# 3. Copy binary, runtime, and config
echo "[3/6] Copying binary, runtime, and config..."
cp /tmp/nvim-linux-x86_64/bin/nvim "$APPIMAGE_DIR/usr/bin/"
cp -r /tmp/nvim-linux-x86_64/share/nvim/runtime/* "$APPIMAGE_DIR/usr/share/nvim/"
cp -r ~/.config/nvim/* "$APPIMAGE_DIR/nvim-home/config/"
cp -r ~/.local/share/nvim/* "$APPIMAGE_DIR/nvim-home/data/"

# 4. Copy fonts
echo "[4/6] Copying fonts..."
cp /usr/share/fonts/TTF/CaskaydiaCoveNerdFontMono-*.ttf "$APPIMAGE_DIR/usr/share/fonts/TTF/"
cp /usr/share/fonts/TTF/SymbolsNerdFont-Regular.ttf "$APPIMAGE_DIR/usr/share/fonts/TTF/"
cp /usr/share/fonts/TTF/SymbolsNerdFontMono-Regular.ttf "$APPIMAGE_DIR/usr/share/fonts/TTF/"
cp /usr/share/fonts/twemoji/twemoji.ttf "$APPIMAGE_DIR/usr/share/fonts/twemoji/"

# Copy fontconfig
cp ~/.config/fontconfig/fonts.conf "$APPIMAGE_DIR/nvim-home/config/"

# 5. Set rpath and bundle shared libs
echo "[5/6] Bundling shared libraries..."
patchelf --set-rpath '$ORIGIN/../lib' --force-rpath "$APPIMAGE_DIR/usr/bin/nvim"
for lib in $(ldd /tmp/nvim-linux-x86_64/bin/nvim | grep -oP '/\S+'); do
    cp -n "$lib" "$APPIMAGE_DIR/usr/lib/" 2>/dev/null || true
done

# 6. Create desktop file and icon
cp "$BUILD_DIR/nvim.desktop" "$APPIMAGE_DIR/"
cp /tmp/nvim-linux-x86_64/share/icons/hicolor/128x128/apps/nvim.png "$APPIMAGE_DIR/"

# Copy AppRun
cp "$BUILD_DIR/AppRun" "$APPIMAGE_DIR/"
chmod +x "$APPIMAGE_DIR/AppRun"

# 7. Build AppImage
echo "[6/6] Building AppImage..."

"$BUILD_DIR/linuxdeploy-x86_64.AppImage" \
    --appdir "$APPIMAGE_DIR" \
    --executable "$APPIMAGE_DIR/usr/bin/nvim" \
    --desktop-file "$APPIMAGE_DIR/nvim.desktop" \
    --icon-file "$APPIMAGE_DIR/nvim.png" \
    --output appimage

# Move output
mv Neovim-x86_64.AppImage "$OUTPUT_DIR/nvim-portable.appimage"

# Cleanup
rm -rf "$APPIMAGE_DIR" /tmp/nvim-linux-x86_64 /tmp/nvim-legacy.tar.gz

echo "=== Build complete! ==="
echo "Output: $OUTPUT_DIR/nvim-portable.appimage"
ls -lh "$OUTPUT_DIR/nvim-portable.appimage"
