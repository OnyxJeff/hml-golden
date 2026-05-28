#!/usr/bin/env bash
set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

GTK3_DIR="$REAL_HOME/.config/gtk-3.0"
LX_DIR="$REAL_HOME/.config/lxsession/LXDE-pi"

echo ""
echo "========================================="
echo " Theme Configuration (Stable Mode)"
echo "========================================="
echo "[*] User: $REAL_USER"
echo ""

# --------------------------------------------------
# GTK FALLBACK CONFIG (always safe)
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
# MODERN SESSION THEMING (safe attempt only)
# --------------------------------------------------

echo "[*] Attempting gsettings (if session supports it)..."

if command -v gsettings >/dev/null 2>&1; then

    # Only works if user session bus exists
    if [[ -S "/run/user/$(id -u "$REAL_USER")/bus" ]]; then

        sudo -u "$REAL_USER" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$REAL_USER")/bus" \
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

        sudo -u "$REAL_USER" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$REAL_USER")/bus" \
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true

        sudo -u "$REAL_USER" \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u "$REAL_USER")/bus" \
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true

    else
        echo "[*] No active D-Bus session → skipping gsettings (expected in bootstrap)"
    fi
fi

# --------------------------------------------------
# OWNERSHIP FIX
# --------------------------------------------------

chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config"

echo ""
echo "[✓] Theme config written (may require relogin to fully apply)"