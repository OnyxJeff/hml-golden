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
# Validate default wallpaper exists
# --------------------------------------------------

if [[ ! -f "$SELECTED_WALLPAPER" ]]; then
    echo "[!] Default wallpaper not found:"
    echo "    $SELECTED_WALLPAPER"
    echo "[!] Falling back to first available image..."

    SELECTED_WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 1 \
        \( -iname "*.jpg" -o -iname "*.png" \) | sort | head -n 1)

    if [[ -z "$SELECTED_WALLPAPER" ]]; then
        echo "[!] No wallpapers available. Exiting."
        exit 1
    fi
fi

echo "[*] Using wallpaper:"
echo "    $(basename "$SELECTED_WALLPAPER")"

# --------------------------------------------------
# Copy wallpaper into user space
# --------------------------------------------------

mkdir -p "$REAL_HOME/Pictures"

EXT="${SELECTED_WALLPAPER##*.}"
DEST="$REAL_HOME/Pictures/homelab-wallpaper.$EXT"

cp "$SELECTED_WALLPAPER" "$DEST"

# --------------------------------------------------
# Apply wallpaper (LXDE / pcmanfm)
# --------------------------------------------------

mkdir -p "$REAL_HOME/.config/pcmanfm/LXDE-pi"

cat > "$REAL_HOME/.config/pcmanfm/LXDE-pi/desktop-items-0.conf" <<EOF
[*]
wallpaper=$DEST
wallpaper_mode=fit
desktop_bg=#000000
EOF

echo ""
echo "[✓] Wallpaper configured successfully."