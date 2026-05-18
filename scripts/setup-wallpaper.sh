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
echo " Wallpaper Setup (Default Mode)"
echo "========================================="
echo ""

# --------------------------------------------------
# Validate wallpaper
# --------------------------------------------------

if [[ ! -f "$SELECTED_WALLPAPER" ]]; then
    echo "[!] Default wallpaper not found"
    SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.png" \) | sort | head -n 1)

    [[ -z "$SELECTED_WALLPAPER" ]] && exit 1
fi

echo "[*] Using wallpaper: $(basename "$SELECTED_WALLPAPER")"

# --------------------------------------------------
# Copy wallpaper
# --------------------------------------------------

mkdir -p "$REAL_HOME/Pictures"

EXT="${SELECTED_WALLPAPER##*.}"
DEST="$REAL_HOME/Pictures/homelab-wallpaper.$EXT"

cp "$SELECTED_WALLPAPER" "$DEST"

# --------------------------------------------------
# Apply wallpaper (LXDE / pcmanfm)
# --------------------------------------------------

mkdir -p "$REAL_HOME/.config/pcmanfm/LXDE-pi"

# Most reliable filename for LXDE sessions
CONF_FILE="$REAL_HOME/.config/pcmanfm/LXDE-pi/desktop-items-0.conf"

cat > "$CONF_FILE" <<EOF
[*]
wallpaper=$DEST
wallpaper_mode=fit
desktop_bg=#000000
show_wm_menu=0
desktop_font=Sans 10
EOF

# Ensure ownership is correct (VERY important when run via sudo)
sudo chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config/pcmanfm" "$REAL_HOME/Pictures"

# --------------------------------------------------
# FORCE reload (important fix)
# --------------------------------------------------

if command -v pcmanfm >/dev/null 2>&1; then
    pcmanfm --reconfigure >/dev/null 2>&1 || true
fi

echo ""
echo "[✓] Wallpaper configured successfully."