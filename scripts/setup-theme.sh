#!/usr/bin/env bash

set -e

echo ""
echo "========================================="
echo " Applying Workstation Theme"
echo "========================================="

# --------------------------------------------------
# GTK DARK THEME
# --------------------------------------------------

echo "[*] Installing dark themes..."

sudo apt install -y \
    arc-theme \
    papirus-icon-theme

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
# QT DARK THEME (helps some apps behave)
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

# --------------------------------------------------
# WAYBAR POSITION + SIZE
# --------------------------------------------------

cat > "$HOME/.config/waybar/config.jsonc" <<EOF
{
  "layer": "top",
  "position": "bottom",
  "height": 24,

  "modules-left": [
    "clock"
  ],

  "modules-right": [
    "custom/tailscale"
  ],

  "custom/tailscale": {
    "exec": "~/.config/waybar/tailscale-status.sh",
    "interval": 10,
    "return-type": "json",
    "on-click": "gnome-terminal -- tailscale status"
  },

  "clock": {
    "format": "{:%Y-%m-%d %H:%M}"
  }
}
EOF

# --------------------------------------------------
# DESKTOP ICON SIZING / APPEARANCE
# --------------------------------------------------

echo "[*] Configuring desktop appearance..."

mkdir -p "$HOME/.config/pcmanfm/LXDE-pi"

cat > "$HOME/.config/pcmanfm/LXDE-pi/desktop-items-0.conf" <<EOF
[*]
desktop_bg=#000000
desktop_fg=#ffffff
desktop_shadow=#000000
wallpaper_mode=fit
show_wm_menu=0
desktop_font=Sans 10
EOF

# --------------------------------------------------
# CHROMIUM DARK MODE
# --------------------------------------------------

echo "[*] Enabling Chromium dark mode..."

mkdir -p "$HOME/.config/chromium-flags.conf.d"

cat > "$HOME/.config/chromium-flags.conf" <<EOF
--force-dark-mode
--enable-features=WebUIDarkMode
EOF

# --------------------------------------------------
# CURSOR CLEANUP
# --------------------------------------------------

mkdir -p "$HOME/.icons/default"

cat > "$HOME/.icons/default/index.theme" <<EOF
[Icon Theme]
Inherits=Adwaita
EOF

# --------------------------------------------------
# COMPLETE
# --------------------------------------------------

echo ""
echo "[✓] Theme configuration complete."
echo ""
echo "Reboot recommended."