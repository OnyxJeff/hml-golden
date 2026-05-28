#!/usr/bin/env bash
set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_DIR="$SCRIPT_DIR/../wallpapers"

DEFAULT_WALLPAPER="homelab-default.jpg"
SELECTED_WALLPAPER="$WALLPAPER_DIR/$DEFAULT_WALLPAPER"

echo ""
echo "========================================="
echo " Wallpaper Setup (Auto-Detect Mode)"
echo "========================================="
echo ""

# --------------------------------------------------
# Validate wallpaper
# --------------------------------------------------

if [[ ! -f "$SELECTED_WALLPAPER" ]]; then
    echo "[!] Default wallpaper not found, searching fallback..."

    SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 \
        \( -iname "*.jpg" -o -iname "*.png" \) | sort | head -n 1)

    if [[ -z "${SELECTED_WALLPAPER:-}" ]]; then
        echo "[✖] No wallpaper found"
        exit 1
    fi
fi

echo "[*] Using wallpaper: $(basename "$SELECTED_WALLPAPER")"

# --------------------------------------------------
# Copy wallpaper to stable location
# --------------------------------------------------

mkdir -p "$REAL_HOME/Pictures/wallpapers"

EXT="${SELECTED_WALLPAPER##*.}"
DEST="$REAL_HOME/Pictures/wallpapers/homelab-wallpaper.$EXT"

cp "$SELECTED_WALLPAPER" "$DEST"
chown "$REAL_USER:$REAL_USER" "$DEST"

echo "[*] Copied to: $DEST"

# --------------------------------------------------
# Detect session type
# --------------------------------------------------

SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"

echo "[*] Session type: $SESSION_TYPE"

# --------------------------------------------------
# WAYLAND / LABWC PATH
# --------------------------------------------------

if pgrep labwc >/dev/null 2>&1 || [[ "$SESSION_TYPE" == "wayland" ]]; then

    echo "[*] Applying wallpaper via swaybg (Wayland)"

    if command -v swaybg >/dev/null 2>&1; then
        pkill swaybg || true

        nohup swaybg -i "$DEST" -m fill >/dev/null 2>&1 &

        echo "[✓] Wallpaper applied (Wayland)"
    else
        echo "[!] swaybg not installed - install it for live wallpaper"
    fi

# --------------------------------------------------
# LXDE / X11 PATH
# --------------------------------------------------

elif command -v pcmanfm >/dev/null 2>&1; then

    echo "[*] Applying wallpaper via pcmanfm (LXDE)"

    CONF_DIR="$REAL_HOME/.config/pcmanfm/LXDE-pi"
    mkdir -p "$CONF_DIR"

    cat > "$CONF_DIR/desktop-items-0.conf" <<EOF
[*]
wallpaper=$DEST
wallpaper_mode=fit
desktop_bg=#000000
show_wm_menu=0
desktop_font=Sans 10
EOF

    chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config/pcmanfm"

    pcmanfm --reconfigure >/dev/null 2>&1 || true

    echo "[✓] Wallpaper applied (LXDE)"

else
    echo "[✖] No supported desktop environment found"
    exit 1
fi

# --------------------------------------------------
# COMPLETE
# --------------------------------------------------

echo ""
echo "[✓] Wallpaper setup complete"