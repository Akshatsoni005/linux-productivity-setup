#!/usr/bin/env bash
set -e

echo "=== Setting up Linux Productivity Desktop ==="

# 1. Apply Appearance Settings
echo "--> Configuring GNOME appearance..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'modern-repack' 2>/dev/null || true

# Typography
gsettings set org.gnome.desktop.interface font-name 'SF Pro Display 10' 2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name 'SF Pro Display 10' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'SF Pro Display Bold 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface text-scaling-factor 1.2

# Window behavior & buttons
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
gsettings set org.gnome.desktop.wm.preferences focus-mode 'sloppy'
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
gsettings set org.gnome.desktop.interface show-battery-percentage true

# 2. Dock Setup (Dash to Dock)
echo "--> Configuring floating dock..."
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#1c1c1e' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.68 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 50 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-minimize-or-previews' 2>/dev/null || true

# 3. Desktop Clock & Tiling
echo "--> Configuring widgets & window tiling..."
gsettings set org.gnome.shell.extensions.modernclock date-format 'numeric' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.modernclock use-24h true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.tilingshell edge-tiling-mode 'adaptive' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.tilingshell inner-gaps 4 2>/dev/null || true
gsettings set org.gnome.shell.extensions.tilingshell outer-gaps 4 2>/dev/null || true

# 4. Topbar System Monitor
gsettings set org.gnome.shell.extensions.system-monitor show-cpu false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.system-monitor show-download false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.system-monitor show-upload false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.system-monitor show-memory true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.system-monitor show-swap true 2>/dev/null || true

echo "=== Setup applied successfully! ==="
