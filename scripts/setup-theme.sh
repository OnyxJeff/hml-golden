#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "========================================="
echo " Applying Workstation Theme"
echo "========================================="

# --------------------------------------------------
# GTK DARK THEME
# --------------------------------------------------

echo "[*] Installing dark themes..."

sudo apt-get install -y \
    arc-theme \
    papirus-icon-theme > /dev/null 2>&1

# GTK3 config directory
mkdir -p "$HOME/.config/gtk-3.0"

cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-application-prefer-dark-theme=1
EOF

# --------------------------------------------------
# QT DARK THEME
# --------------------------------------------------

mkdir -p "$HOME/.config/qt5ct"

cat > "$HOME/.config/qt5ct/qt5ct.conf" <<EOF
[Appearance]
icon_theme=Papirus-Dark
style=Fusion
EOF

# --------------------------------------------------
# WAYBAR THEME
# --------------------------------------------------

echo "[*] Configuring Waybar theme..."

mkdir -p "$HOME/.config/waybar"

cat > "$HOME/.config/waybar/style.css" <<EOF
* {
    border: none;
    border-radius: 0;
    font-family: Sans;
    font-size: 12px;
    min-height: 0;
}

window#waybar {
    background: rgba(20, 20, 20, 0.92);
    color: #ffffff;
}

#clock,
#custom-tailscale {
    padding: 0 10px;
    margin: 2px 4px;
}
EOF

cat > "$HOME/.config/waybar/config.jsonc" <<EOF
{
  "layer": "top",
  "position": "bottom",
  "height": 24,
  "modules-left": ["clock"],
  "modules-right": ["custom/tailscale"],

  "custom/tailscale": {
    "exec": "~/.config/waybar/tailscale-status.sh",
    "interval": 10,
    "return-type": "json"
  },

  "clock": {
    "format": "{:%Y-%m-%d %H:%M}"
  }
}
EOF

echo ""
echo "[✓] Theme configuration complete."