#!/usr/bin/env bash
set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_DIR="$SCRIPT_DIR/../wallpapers"

DEFAULT_WALLPAPER="homelab-default.jpg"
SELECTED_WALL="$WALLPAPER_DIR/$DEFAULT_WALLPAPER"

LABWC_AUTOSTART="$REAL_HOME/.config/labwc/autostart"
DEST_DIR="$REAL_HOME/Pictures"

echo ""
echo "========================================="
echo " Wallpaper Setup (Labwc Native)"
echo "========================================="
echo ""

# --------------------------------------------------
# Resolve wallpaper
# --------------------------------------------------

if [[ ! -f "$SELECTED_WALL" ]]; then
    echo "[!] Default wallpaper not found"
    SELECTED_WALL=$(find "$WALLPAPER_DIR" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.png" \) | sort | head -n 1)
fi

[[ -z "$SELECTED_WALL" ]] && echo "[✖] No wallpaper found" && exit 1

echo "[*] Using: $(basename "$SELECTED_WALL")"

# --------------------------------------------------
# Copy wallpaper
# --------------------------------------------------

mkdir -p "$DEST_DIR"

EXT="${SELECTED_WALL##*.}"
FINAL_WALL="$DEST_DIR/homelab-wallpaper.$EXT"

cp -f "$SELECTED_WALL" "$FINAL_WALL"

# --------------------------------------------------
# Ensure labwc autostart exists
# --------------------------------------------------

mkdir -p "$(dirname "$LABWC_AUTOSTART")"
touch "$LABWC_AUTOSTART"

# remove old wallpaper lines if any
grep -v "swaybg" "$LABWC_AUTOSTART" > "${LABWC_AUTOSTART}.tmp" || true
mv "${LABWC_AUTOSTART}.tmp" "$LABWC_AUTOSTART"

# add correct wallpaper command
cat >> "$LABWC_AUTOSTART" <<EOF
swaybg -i $FINAL_WALL -m fill &
EOF

# --------------------------------------------------
# ownership fix
# --------------------------------------------------

chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/Pictures"
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config/labwc"

# --------------------------------------------------
# restart wallpaper safely (no desktop disruption)
# --------------------------------------------------

pkill swaybg || true
nohup sudo -u "$REAL_USER" swaybg -i "$FINAL_WALL" -m fill >/dev/null 2>&1 &

echo ""
echo "[✓] Wallpaper applied via swaybg (labwc-native)"
echo "[!] Will persist after reboot via labwc autostart"