#!/usr/bin/env bash
set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

echo ""
echo "========================================="
echo " Theme + Desktop Configuration"
echo "========================================="
echo "[*] User: $REAL_USER"
echo ""

# --------------------------------------------------
# PACKAGES
# --------------------------------------------------
echo "[*] Installing themes + tools..."

apt-get update -qq
apt-get install -y \
    arc-theme \
    papirus-icon-theme \
    lxappearance \
    waybar \
    jq \
    gnome-terminal \
    > /dev/null 2>&1 || true

# --------------------------------------------------
# GTK THEME (LXDE SAFE PATH)
# --------------------------------------------------
mkdir -p "$REAL_HOME/.config/gtk-3.0"

cat > "$REAL_HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-application-prefer-dark-theme=1
EOF

# ALSO set LXDE config (THIS is the important part)
mkdir -p "$REAL_HOME/.config/lxsession/LXDE-pi"

cat > "$REAL_HOME/.config/lxsession/LXDE-pi/desktop.conf" <<EOF
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
EOF

# --------------------------------------------------
# WAYBAR CONFIG
# --------------------------------------------------
mkdir -p "$REAL_HOME/.config/waybar"

cat > "$REAL_HOME/.config/waybar/style.css" <<EOF
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

cat > "$REAL_HOME/.config/waybar/config.jsonc" <<EOF
{
  "layer": "top",
  "position": "bottom",
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

# --------------------------------------------------
# WAYBAR AUTOSTART (CRITICAL FIX)
# --------------------------------------------------
mkdir -p "$REAL_HOME/.config/labwc"

AUTOSTART="$REAL_HOME/.config/labwc/autostart"

touch "$AUTOSTART"

if ! grep -q "waybar" "$AUTOSTART"; then
    echo "waybar &" >> "$AUTOSTART"
fi

# fallback for LXDE
mkdir -p "$REAL_HOME/.config/lxsession/LXDE-pi"

if ! grep -q "waybar" "$REAL_HOME/.config/lxsession/LXDE-pi/autostart" 2>/dev/null; then
    echo "@waybar" >> "$REAL_HOME/.config/lxsession/LXDE-pi/autostart"
fi

# --------------------------------------------------
# FIX OWNERSHIP
# --------------------------------------------------
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config"

echo ""
echo "[✓] Theme + Waybar configuration applied"
echo "[!] Reboot required for full effect"