#!/usr/bin/env bash
# ==============================================================================
# Linux Productivity Setup
# Turns Ubuntu, Fedora, Debian, or Arch into an ultra-clean productivity machine.
# Usage: curl -fsSL https://www.theaiserver.in/downloads/setup.sh | bash
#    or: ./setup.sh
# ==============================================================================

set -eo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}Linux Productivity Setup${NC}"
echo "────────────────────────────────"

# 1. Environment & Desktop Detection
if ! command -v gnome-shell >/dev/null 2>&1 && [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
  echo -e "${YELLOW}[!] GNOME desktop not detected. This setup is optimized for GNOME.${NC}"
  echo "    Proceeding anyway, but some extensions may not activate."
else
  echo -e "${GREEN}✓ GNOME detected${NC}"
fi

# Detect Distro
DISTRO="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  DISTRO=$ID
  DISTRO_LIKE=${ID_LIKE:-$ID}
fi

# Detect Script Directory or Online Mode
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
MIRROR_BASE="https://www.theaiserver.in/downloads"

fetch_asset() {
  local asset_name="$1"
  local dest_dir="$2"
  mkdir -p "$dest_dir"

  if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$asset_name" ]; then
    tar -xf "$SCRIPT_DIR/$asset_name" -C "$dest_dir"
  elif [ -f "$HOME/$asset_name" ]; then
    tar -xf "$HOME/$asset_name" -C "$dest_dir"
  else
    local tmp_file="/tmp/$asset_name"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "$MIRROR_BASE/$asset_name" -o "$tmp_file"
    elif command -v wget >/dev/null 2>&1; then
      wget -q "$MIRROR_BASE/$asset_name" -O "$tmp_file"
    fi
    if [ -f "$tmp_file" ]; then
      tar -xf "$tmp_file" -C "$dest_dir"
      rm -f "$tmp_file"
    fi
  fi
}

# 2. Dependencies
echo -n "Installing dependencies... "
PACKAGES_TO_INSTALL=()

case "$DISTRO_LIKE" in
  *debian*|*ubuntu*)
    for pkg in curl tar dconf-cli gnome-shell-extensions fonts-jetbrains-mono; do
      if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        PACKAGES_TO_INSTALL+=("$pkg")
      fi
    done
    if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
      sudo apt-get update -qq >/dev/null 2>&1 || true
      sudo apt-get install -y -qq "${PACKAGES_TO_INSTALL[@]}" >/dev/null 2>&1 || true
    fi
    ;;
  *fedora*|*rhel*)
    for pkg in curl tar dconf gnome-shell-extension-common jetbrains-mono-fonts; do
      if ! rpm -q "$pkg" >/dev/null 2>&1; then
        PACKAGES_TO_INSTALL+=("$pkg")
      fi
    done
    if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
      sudo dnf install -y -q "${PACKAGES_TO_INSTALL[@]}" >/dev/null 2>&1 || true
    fi
    ;;
  *arch*)
    for pkg in curl tar dconf ttf-jetbrains-mono; do
      if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        PACKAGES_TO_INSTALL+=("$pkg")
      fi
    done
    if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
      sudo pacman -S --noconfirm --needed "${PACKAGES_TO_INSTALL[@]}" >/dev/null 2>&1 || true
    fi
    ;;
esac
echo -e "\r${GREEN}✓ Dependencies installed${NC}        "

# Ensure core directories exist
mkdir -p ~/.themes ~/.local/share/icons ~/.local/share/backgrounds ~/.local/share/gnome-shell/extensions

# [1/6] Installing Theme
echo ""
echo -e "${BOLD}[1/6] Installing theme${NC}"
fetch_asset "theme-whitesur.tar.xz" "$HOME/.themes"
echo -e "${GREEN}✓ WhiteSur installed${NC}"

# [2/6] Installing Icons
echo ""
echo -e "${BOLD}[2/6] Installing icons${NC}"
fetch_asset "modern-repack.tar.xz" "$HOME/.local/share/icons"
if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d "$HOME/.local/share/icons/modern-repack" ]; then
  gtk-update-icon-cache -f -t "$HOME/.local/share/icons/modern-repack" >/dev/null 2>&1 || true
fi
echo -e "${GREEN}✓ modern-repack installed${NC}"

# [3/6] Installing Wallpaper
echo ""
echo -e "${BOLD}[3/6] Installing wallpaper${NC}"
WALLPAPER_PATH="$HOME/.local/share/backgrounds/Monterey-dark.jpg"
if [ ! -f "$WALLPAPER_PATH" ]; then
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/Monterey-dark.jpg" -o "$WALLPAPER_PATH" || true
  elif command -v wget >/dev/null 2>&1; then
    wget -q "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/main/4k/Monterey-dark.jpg" -O "$WALLPAPER_PATH" || true
  fi
fi
echo -e "${GREEN}✓ Monterey Dark installed${NC}"

# [4/6] Installing GNOME Extensions
echo ""
echo -e "${BOLD}[4/6] Installing GNOME extensions${NC}"
fetch_asset "gnome-extensions.tar.xz" "$HOME/.local/share/gnome-shell/extensions"

EXTENSIONS=(
  "dash-to-dock@micxgx.gmail.com"
  "tilingshell@ferrarodomenico.com"
  "modernclock@gnome-port"
  "compiz-alike-magic-lamp-effect@hermes83.github.com"
  "dynamic-transparent-top-bar@akshat"
)

# Compile schemas for all installed local extensions
for ext in "${EXTENSIONS[@]}"; do
  SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/$ext/schemas"
  if [ -d "$SCHEMA_DIR" ] && command -v glib-compile-schemas >/dev/null 2>&1; then
    glib-compile-schemas "$SCHEMA_DIR" >/dev/null 2>&1 || true
  fi
  if command -v gnome-extensions >/dev/null 2>&1; then
    gnome-extensions enable "$ext" >/dev/null 2>&1 || true
  fi
done

echo -e "${GREEN}✓ Tiling Shell${NC}"
echo -e "${GREEN}✓ Modern Clock${NC}"
echo -e "${GREEN}✓ Dash to Dock${NC}"
echo -e "${GREEN}✓ Magic Lamp${NC}"
echo -e "${GREEN}✓ Dynamic Transparent Top Bar${NC}"

# [5/6] Applying Configuration
echo ""
echo -e "${BOLD}[5/6] Applying configuration${NC}"

# Appearance & Theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'modern-repack' 2>/dev/null || true

# Wallpaper
if [ -f "$WALLPAPER_PATH" ]; then
  gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH" 2>/dev/null || true
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH" 2>/dev/null || true
fi

# Typography
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface text-scaling-factor 1.2 2>/dev/null || true

# Window Controls
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences focus-mode 'sloppy' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true 2>/dev/null || true
gsettings set org.gnome.desktop.interface show-battery-percentage true 2>/dev/null || true

# Dock Configuration
if command -v dconf >/dev/null 2>&1; then
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

  # Tiling Shell
  dconf write /org/gnome/shell/extensions/tilingshell/edge-tiling-mode "'adaptive'" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/tilingshell/inner-gaps "uint32 4" 2>/dev/null || true
  dconf write /org/gnome/shell/extensions/tilingshell/outer-gaps "uint32 4" 2>/dev/null || true
fi

echo -e "${GREEN}✓ Appearance${NC}"
echo -e "${GREEN}✓ Dock${NC}"
echo -e "${GREEN}✓ Top bar${NC}"
echo -e "${GREEN}✓ Window tiling${NC}"
echo -e "${GREEN}✓ Clock${NC}"

# [6/6] Optional Performance Tweaks
echo ""
echo -e "${BOLD}[6/6] Optional performance tweaks${NC}"

ENABLE_ZRAM="n"
if [ -t 0 ]; then
  read -r -p "→ Enable ZRAM & set swappiness to 25? [Y/n] " response
  response=${response:-y}
  if [[ "$response" =~ ^[Yy]$ ]]; then
    ENABLE_ZRAM="y"
  fi
elif [ -c /dev/tty ] && [ -r /dev/tty ] && ! [ -t 1 ]; then
  read -r -p "→ Enable ZRAM & set swappiness to 25? [Y/n] " response </dev/tty 2>/dev/null || response="y"
  response=${response:-y}
  if [[ "$response" =~ ^[Yy]$ ]]; then
    ENABLE_ZRAM="y"
  fi
else
  if read -t 1 response 2>/dev/null; then
    response=${response:-y}
  else
    response="y"
  fi
  if [[ "$response" =~ ^[Yy]$ ]]; then
    ENABLE_ZRAM="y"
  fi
fi

if [ "$ENABLE_ZRAM" = "y" ]; then
  echo "  Configuring ZRAM & swappiness..."
  case "$DISTRO_LIKE" in
    *debian*|*ubuntu*)
      sudo apt-get install -y -qq zram-tools >/dev/null 2>&1 || true
      sudo tee /etc/default/zramswap >/dev/null << 'EOF'
ALGO=lz4
PERCENT=50
PRIORITY=100
EOF
      sudo systemctl restart zramswap >/dev/null 2>&1 || true
      ;;
    *fedora*|*rhel*)
      sudo dnf install -y -q zram-generator >/dev/null 2>&1 || true
      sudo tee /etc/systemd/zram-generator.conf >/dev/null << 'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = lz4
EOF
      sudo systemctl daemon-reload >/dev/null 2>&1 || true
      ;;
  esac

  echo "vm.swappiness=25" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
  sudo sysctl --system >/dev/null 2>&1 || true
  echo -e "  ${GREEN}✓ ZRAM and swappiness configured${NC}"
fi

echo ""
echo "────────────────────────────────"
echo -e "${GREEN}✓ Linux Productivity setup complete!${NC}"
echo "→ Log out and back in to finish."
