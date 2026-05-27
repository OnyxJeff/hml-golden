#!/usr/bin/env bash
set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

GTK3_DIR="$REAL_HOME/.config/gtk-3.0"
LX_DIR="$REAL_HOME/.config/lxsession/LXDE-pi"

echo ""
echo "========================================="
echo " Theme Configuration"
echo "========================================="
echo "[*] User: $REAL_USER"
echo ""

# --------------------------------------------------
# GTK FALLBACK CONFIG
# --------------------------------------------------

mkdir -p "$GTK3_DIR"

cat > "$GTK3_DIR/settings.ini" <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-application-prefer-dark-theme=1
EOF

# --------------------------------------------------
# LXDE FALLBACK
# --------------------------------------------------

mkdir -p "$LX_DIR"

cat > "$LX_DIR/desktop.conf" <<EOF
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
EOF

# --------------------------------------------------
# MODERN DARK MODE (gsettings)
# --------------------------------------------------

echo "[*] Applying system theme (gsettings)..."

USER_ID="$(id -u "$REAL_USER")"
DBUS_ADDR="unix:path=/run/user/$USER_ID/bus"

sudo -u "$REAL_USER" \
DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" \
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true

sudo -u "$REAL_USER" \
DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" \
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || true

sudo -u "$REAL_USER" \
DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" \
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' || true

# --------------------------------------------------
# PERMISSIONS
# --------------------------------------------------

chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config"

echo ""
echo "[✓] Theme configured successfully"