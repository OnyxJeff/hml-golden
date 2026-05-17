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
# INSTALL REQUIRED PACKAGES
# --------------------------------------------------

echo "[*] Installing theme + desktop packages..."

apt-get update -qq

apt-get install -y -qq \
    papirus-icon-theme \
    lxappearance \
    waybar \
    jq \
    gnome-terminal \
    > /dev/null 2>&1 || true

# --------------------------------------------------
# GTK THEME CONFIG
# --------------------------------------------------

echo "[*] Configuring GTK theme..."

mkdir -p "$REAL_HOME/.config/gtk-3.0"
mkdir -p "$REAL_HOME/.config/gtk-4.0"

cat > "$REAL_HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-application-prefer-dark-theme=1
EOF

cat > "$REAL_HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-application-prefer-dark-theme=1
EOF

# --------------------------------------------------
# LXSESSION FALLBACK CONFIG
# --------------------------------------------------

echo "[*] Configuring LXSession fallback..."

mkdir -p "$REAL_HOME/.config/lxsession/LXDE-pi"

cat > "$REAL_HOME/.config/lxsession/LXDE-pi/desktop.conf" <<EOF
[GTK]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
EOF

# --------------------------------------------------
# WAYBAR CONFIG
# --------------------------------------------------

echo "[*] Configuring Waybar..."

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

    "modules-left": [
        "clock"
    ],

    "modules-right": [
        "custom/tailscale"
    ],

    "clock": {
        "format": "{:%Y-%m-%d %H:%M}"
    },

    "custom/tailscale": {
        "exec": "/home/$REAL_USER/.config/waybar/tailscale-status.sh",
        "interval": 10,
        "return-type": "json"
    }
}
EOF

# --------------------------------------------------
# TAILSCALE STATUS SCRIPT
# --------------------------------------------------

echo "[*] Creating Tailscale status script..."

cat > "$REAL_HOME/.config/waybar/tailscale-status.sh" <<'EOF'
#!/usr/bin/env bash

if tailscale status >/dev/null 2>&1; then
    echo '{"text":"󰖂 Connected","class":"connected"}'
else
    echo '{"text":"󰖂 Offline","class":"disconnected"}'
fi
EOF

chmod +x "$REAL_HOME/.config/waybar/tailscale-status.sh"

# --------------------------------------------------
# LABWC AUTOSTART
# --------------------------------------------------

echo "[*] Configuring Waybar autostart..."

mkdir -p "$REAL_HOME/.config/labwc"

AUTOSTART="$REAL_HOME/.config/labwc/autostart"

touch "$AUTOSTART"

if ! grep -q "^waybar" "$AUTOSTART"; then
    echo "waybar &" >> "$AUTOSTART"
fi

# --------------------------------------------------
# LXSESSION FALLBACK AUTOSTART
# --------------------------------------------------

LX_AUTOSTART="$REAL_HOME/.config/lxsession/LXDE-pi/autostart"

touch "$LX_AUTOSTART"

if ! grep -q "^@waybar" "$LX_AUTOSTART"; then
    echo "@waybar" >> "$LX_AUTOSTART"
fi

# --------------------------------------------------
# OWNERSHIP FIX
# --------------------------------------------------

echo "[*] Fixing permissions..."

chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config"

# --------------------------------------------------
# COMPLETE
# --------------------------------------------------

echo ""
echo "[✓] Theme + desktop configuration applied"
echo "[!] Reboot recommended"
echo ""