#!/usr/bin/env bash

set -euo pipefail

DESKTOP_DIR="$HOME/Desktop"

mkdir -p "$DESKTOP_DIR"

# --------------------------------------------------
# LibreOffice Calc
# --------------------------------------------------

cat > "$DESKTOP_DIR/Calc.desktop" <<EOF
[Desktop Entry]
Name=Calc Spreadsheet
Exec=libreoffice --calc
Icon=libreoffice-calc
Type=Application
Terminal=false
EOF

# --------------------------------------------------
# Windows VM (RDP)
# --------------------------------------------------

cat > "$DESKTOP_DIR/Windows-VM.desktop" <<EOF
[Desktop Entry]
Name=Windows VM (RDP)
Exec=remmina
Icon=remmina
Type=Application
Terminal=false
EOF

# --------------------------------------------------
# Homarr Portal (SAFE FIX)
# --------------------------------------------------

PORTAL_URL="${PORTAL_URL:-https://home.onyxnethq.site}"

cat > "$DESKTOP_DIR/Homarr-Portal.desktop" <<EOF
[Desktop Entry]
Name=Homarr Portal
Exec=chromium "$PORTAL_URL"
Icon=chromium
Type=Application
Terminal=false
EOF

# --------------------------------------------------
# SSH Terminal
# --------------------------------------------------

cat > "$DESKTOP_DIR/SSH-Terminal.desktop" <<EOF
[Desktop Entry]
Name=SSH Terminal
Exec=gnome-terminal
Icon=utilities-terminal
Type=Application
Terminal=false
EOF

# --------------------------------------------------
# Steam Link (safe install guard)
# --------------------------------------------------

if [[ -x /usr/bin/steamlink ]]; then
cat > "$DESKTOP_DIR/SteamLink.desktop" <<EOF
[Desktop Entry]
Name=Steam Link
Exec=/usr/bin/steamlink %u
Icon=steamlink
Terminal=false
Type=Application
Categories=Game;
MimeType=x-scheme-handler/steamlink;
EOF
fi

# --------------------------------------------------
# Tailscale Status
# --------------------------------------------------

cat > "$DESKTOP_DIR/Tailscale-Status.desktop" <<EOF
[Desktop Entry]
Name=Tailscale Status
Exec=gnome-terminal -- tailscale status
Icon=network-vpn
Type=Application
Terminal=false
EOF

chmod +x "$DESKTOP_DIR"/*.desktop