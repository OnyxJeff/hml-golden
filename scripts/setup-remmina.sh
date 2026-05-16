#!/usr/bin/env bash

set -e

echo ""
echo "========================================="
echo " Setting up Remmina RDP Profiles"
echo "========================================="

mkdir -p "$HOME/.local/share/remmina"
mkdir -p "$HOME/Desktop"

# --------------------------------------------------
# SimulationCraft VM
# --------------------------------------------------

cat > "$HOME/.local/share/remmina/simc-vm.remmina" <<EOF
[remmina]
name=SimulationCraft VM
protocol=RDP
server=10.100.0.50
username=jeff
password=
resolution_mode=2
color-depth=32
window_maximize=1
disableclipboard=0
sound=local
EOF

# --------------------------------------------------
# Desktop shortcuts (click to launch directly)
# --------------------------------------------------

cat > "$HOME/Desktop/SimC-VM.desktop" <<EOF
[Desktop Entry]
Name=SimulationCraft VM
Exec=remmina -c $HOME/.local/share/remmina/simc-vm.remmina
Icon=remmina
Type=Application
Terminal=false
EOF

chmod +x "$HOME/Desktop/"*.desktop

echo ""
echo "[✓] Remmina profiles installed."