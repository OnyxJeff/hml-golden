#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_DIR="$SCRIPT_DIR/../wallpapers"

echo ""
echo "========================================="
echo " Wallpaper Selection"
echo "========================================="
echo ""

# Build wallpaper list
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.png" \) | sort)

# Check if wallpapers exist
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "[!] No wallpapers found in:"
    echo "    $WALLPAPER_DIR"
    exit 1
fi

# Display wallpapers
for i in "${!WALLPAPERS[@]}"; do
    BASENAME=$(basename "${WALLPAPERS[$i]}")
    echo "[$((i+1))] $BASENAME"
done

echo ""
read -rp "Choose wallpaper number: " CHOICE

INDEX=$((CHOICE - 1))

# Validate selection
if [ ! "${WALLPAPERS[$INDEX]+exists}" ]; then
    echo "[!] Invalid selection."
    exit 1
fi

SELECTED_WALLPAPER="${WALLPAPERS[$INDEX]}"

echo ""
echo "[*] Using wallpaper:"
echo "    $(basename "$SELECTED_WALLPAPER")"

# Destination
mkdir -p "$HOME/Pictures"

DEST="$HOME/Pictures/homelab-wallpaper$(basename "$SELECTED_WALLPAPER" | sed 's/.*\(\.[^.]*\)$/\1/')"

cp "$SELECTED_WALLPAPER" "$DEST"

# Configure wallpaper
mkdir -p "$HOME/.config/pcmanfm/LXDE-pi"

cat > "$HOME/.config/pcmanfm/LXDE-pi/desktop-items-0.conf" <<EOF
[*]
wallpaper=$DEST
wallpaper_mode=fit
desktop_bg=#000000
EOF

echo ""
echo "[✓] Wallpaper configured."