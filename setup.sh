#!/usr/bin/env bash
# ==============================================================================
# Linux Productivity Desktop Setup Script
# Works on any standard Linux distribution running GNOME (Ubuntu, Fedora, Debian, Arch)
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Setting up Linux Productivity Workstation ===${NC}"

# 1. Environment & Dependency Check
if ! command -v gsettings >/dev/null 2>&1; then
  echo -e "${YELLOW}[!] 'gsettings' not found. This script requires a GNOME desktop environment.${NC}"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p ~/.local/share/icons ~/.local/share/backgrounds ~/.local/share/themes

# 2. Install modern-repack Icon Theme
echo -e "${GREEN}[1/5] Setting up 'modern-repack' icon theme...${NC}"
ICON_DEST="$HOME/.local/share/icons/modern-repack"

if [ ! -d "$ICON_DEST" ]; then
  if [ -f "$SCRIPT_DIR/modern-repack.tar.xz" ]; then
    echo "  -> Extracting from local archive..."
    tar -xf "$SCRIPT_DIR/modern-repack.tar.xz" -C ~/.local/share/icons/
  elif [ -f "$HOME/modern-repack.tar.xz" ]; then
    echo "  -> Extracting from home directory..."
    tar -xf "$HOME/modern-repack.tar.xz" -C ~/.local/share/icons/
  else
    echo "  -> Downloading modern-repack icons from mirror..."
    mkdir -p /tmp/icon-download
    if command -v curl >/dev/null 2>&1; then
      curl -sL "https://www.theaiserver.in/downloads/modern-repack.tar.xz" -o /tmp/icon-download/modern-repack.tar.xz
    elif command -v wget >/dev/null 2>&1; then
      wget -q "https://www.theaiserver.in/downloads/modern-repack.tar.xz" -O /tmp/icon-download/modern-repack.tar.xz
    fi
    if [ -f /tmp/icon-download/modern-repack.tar.xz ]; then
      tar -xf /tmp/icon-download/modern-repack.tar.xz -C ~/.local/share/icons/
      rm -rf /tmp/icon-download
    fi
  fi
fi

if [ -d "$ICON_DEST" ]; then
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "$ICON_DEST" 2>/dev/null || true
  fi
  gsettings set org.gnome.desktop.interface icon-theme 'modern-repack' 2>/dev/null || true
  echo "  ✓ Icon theme applied: modern-repack"
else
  echo -e "  ${YELLOW}[!] Note: Icon pack archive not found. Using default icons for now.${NC}"
fi

# 3. Download and Set Monterey Dark Wallpaper
echo -e "${GREEN}[2/5] Setting up Monterey Dark wallpaper...${NC}"
WALLPAPER_PATH="$HOME/.local/share/backgrounds/Monterey-dark.jpg"

if [ ! -f "$WALLPAPER_PATH" ]; then
  echo "  -> Downloading Monterey-dark 4K wallpaper..."
  if command -v curl >/dev/null 2>&1; then
    curl -sL "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/Monterey-dark.jpg" -o "$WALLPAPER_PATH" || true
  elif command -v wget >/dev/null 2>&1; then
    wget -q "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/Monterey-dark.jpg" -O "$WALLPAPER_PATH" || true
  fi
fi

if [ -f "$WALLPAPER_PATH" ]; then
  gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH" 2>/dev/null || true
  echo "  ✓ Wallpaper applied: Monterey-dark.jpg"
fi

# 4. Core GNOME Appearance & Typography
echo -e "${GREEN}[3/5] Applying visual styling and window ergonomics...${NC}"

# Dark Mode & Themes
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

# WhiteSur if installed, otherwise keeps clean dark defaults
if [ -d "$HOME/.themes/WhiteSur-Dark" ] || [ -d "/usr/share/themes/WhiteSur-Dark" ]; then
  gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark' 2>/dev/null || true
  gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark' 2>/dev/null || true
fi

# Cursor theme
if [ -d "$HOME/.icons/WhiteSur-cursors" ] || [ -d "/usr/share/icons/WhiteSur-cursors" ]; then
  gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors' 2>/dev/null || true
fi

# Typography & Readability (falls back to system fonts if SF Pro isn't installed)
gsettings set org.gnome.desktop.interface font-name 'SF Pro Display 10' 2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name 'SF Pro Display 10' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'SF Pro Display Bold 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface text-scaling-factor 1.2 2>/dev/null || true

# Window Controls & Ergonomics
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences focus-mode 'sloppy' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true 2>/dev/null || true
gsettings set org.gnome.desktop.interface show-battery-percentage true 2>/dev/null || true
echo "  ✓ Appearance, scaling, and window controls configured"

# 5. Extension Configurations (Pre-seeded into dconf so they apply instantly)
echo -e "${GREEN}[4/5] Pre-configuring extensions (Dock, Tiling, Clock)...${NC}"

if command -v dconf >/dev/null 2>&1; then
  # Dash to Dock (Floating frosted dock)
  dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height false 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/custom-background-color true 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/background-color "'#1c1c1e'" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/background-opacity 0.68 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/running-indicator-style "'DOTS'" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 50 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/dash-to-dock/click-action "'focus-minimize-or-previews'" 2>/dev/null || true

  # Modern Clock
  dconf write /org/gnome/shell/extensions/modernclock/date-format "'numeric'" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/modernclock/use-24h true 2>/dev/null || true

  # Tiling Shell (4px clean gaps & adaptive snapping)
  dconf write /org/gnome/shell/extensions/tilingshell/edge-tiling-mode "'adaptive'" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/tilingshell/inner-gaps "uint32 4" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/tilingshell/outer-gaps "uint32 4" 2>/dev/null || true

  # System Monitor (RAM and Swap only)
  dconf write /org/gnome/shell/extensions/system-monitor/show-cpu false 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/system-monitor/show-download false 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/system-monitor/show-upload false 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/system-monitor/show-memory true 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/system-monitor/show-swap true 2>/dev/null || true
  echo "  ✓ Dock, Tiling Shell, and widget parameters pre-seeded into dconf"
fi

# 6. Extensions Checklist Summary
echo -e "${GREEN}[5/5] Extensions Verification${NC}"
echo "  To complete the setup, enable these extensions (via GNOME Extensions app or web):"
echo "  - Dash to Dock:                 https://extensions.gnome.org/extension/307/dash-to-dock/"
echo "  - Tiling Shell:                 https://extensions.gnome.org/extension/7065/tiling-shell/"
echo "  - Modern Clock:                 https://extensions.gnome.org/extension/5125/modern-clock/"
echo "  - Dynamic Transparent Top Bar:  https://extensions.gnome.org/extension/3193/blur-my-shell/ (or dynamic-transparent-top-bar)"
echo "  - Compiz Magic Lamp Effect:     https://extensions.gnome.org/extension/4413/compiz-alike-magic-lamp-effect/"
echo "  - System Monitor:               https://extensions.gnome.org/extension/120/system-monitor/"
echo "  - Apps & Places Menu:           Pre-installed on Ubuntu / available on GNOME extensions"

echo ""
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}✓ Desktop customization applied successfully!${NC}"
echo -e "${BLUE}======================================================${NC}"
