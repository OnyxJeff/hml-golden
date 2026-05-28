#!/usr/bin/env bash
set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_DIR="$SCRIPT_DIR/../wallpapers"

DEFAULT_WALLPAPER="homelab-default.jpg"
SELECTED_WALL=""

LABWC_AUTOSTART="$REAL_HOME/.config/labwc/autostart"
DEST_DIR="$REAL_HOME/Pictures"

echo ""
echo "========================================="
echo " Wallpaper Setup (Pi OS 13 / Labwc Safe)"
echo "========================================="
echo ""

# --------------------------------------------------
# Resolve wallpaper
# --------------------------------------------------

if [[ -f "$WALLPAPER_DIR/$DEFAULT_WALLPAPER" ]]; then
    SELECTED_WALL="$WALLPAPER_DIR/$DEFAULT_WALLPAPER"
else
    SELECTED_WALL=$(find "$WALLPAPER_DIR" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.png" \) | sort | head -n 1)
fi

if [[ -z "$SELECTED_WALL" ]]; then
    echo "[✖] No wallpaper found"
    exit 1
fi

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

# Remove any existing wallpaper lines safely
grep -v "swaybg" "$LABWC_AUTOSTART" > "$LABWC_AUTOSTART.tmp" 2>/dev/null || true
mv "$LABWC_AUTOSTART.tmp" "$LABWC_AUTOSTART" 2>/dev/null || true

# Add correct persistent wallpaper rule
echo "swaybg -i \"$FINAL_WALL\" -m fill &" >> "$LABWC_AUTOSTART"

# --------------------------------------------------
# Permissions
# --------------------------------------------------

chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/Pictures"
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config/labwc"

# --------------------------------------------------
# IMPORTANT NOTE
# --------------------------------------------------

echo ""
echo "[✓] Wallpaper configured for labwc autostart"
echo "[✓] Will apply on next session restart (NOT SSH session)"
echo "[!] Run: labwc-restart or reboot to see it"