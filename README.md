# nvim-portable

Self-contained Neovim AppImage with bundled config, plugins, fonts, and fontconfig.

## What's Included

- Neovim v0.11.6 (legacy build, glibc 2.17 compatible)
- Your config (`~/.config/nvim/`)
- Your plugins and data (`~/.local/share/nvim/`)
- CaskaydiaCove Nerd Font Mono, Twemoji, Symbols Nerd Font
- Your fontconfig setup

## Quick Build

```bash
./build/build.sh
```

Output: `nvim-portable.appimage`

## Usage

```bash
chmod +x nvim-portable.appimage
./nvim-portable.appimage
```

### First Run

On first run, the AppImage will:
1. Install fonts to `~/.local/share/fonts/nvim-portable/`
2. Set up fontconfig at `~/.config/fontconfig/fonts.conf`
3. Copy config to `~/.nvim-portable/config/nvim/`
4. Copy plugins to `~/.nvim-portable/data/nvim/`
5. Prompt you to restart your terminal for fonts

### Editing Config

After first run, edit the live copy:
```bash
vim ~/.nvim-portable/config/nvim/init.lua
```

Or rebuild with updated source config:
```bash
./build/build.sh
```

## Requirements

- Linux x86_64
- FUSE (for AppImage) - if unavailable, extract with `--appimage-extract`
- `patchelf` (for build)

## Build Dependencies

- `curl`
- `patchelf`

## How It Works

1. Downloads legacy Neovim binary (glibc 2.17)
2. Copies your config, plugins, fonts
3. Bundles shared libraries (`libc.so.6`, `libm.so.6`, etc.)
4. Sets binary rpath to find bundled libs
5. Packages everything into single AppImage

## Directory Structure

```
build/
├── AppRun              # Launcher script (sane checks, font setup)
├── build.sh            # Build script
├── linuxdeploy-*.AppImage  # AppImage tool
└── nvim.desktop        # Desktop entry
```
