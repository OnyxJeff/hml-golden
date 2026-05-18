#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "========================================="
echo " Setting up Remmina RDP Profiles"
echo "========================================="

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

mkdir -p "$REAL_HOME/.local/share/remmina"
mkdir -p "$REAL_HOME/Desktop"

# --------------------------------------------------
# SimulationCraft VM
# --------------------------------------------------

cat > "$REAL_HOME/.local/share/remmina/simc-vm.remmina" <<EOF
[remmina]
name=SimulationCraft VM
protocol=RDP
server=10.100.0.71
username=jmay
password=welcome123
resolution_mode=2
window_maximize=1
color-depth=16
security=negotiate
ignore-tls-errors=1
disableclipboard=0
sound=local
network=auto
EOF

# --------------------------------------------------
# Fixing Ownership
# --------------------------------------------------

sudo chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.config"
sudo chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.local"

# --------------------------------------------------
# Done
# --------------------------------------------------

echo ""
echo "[✓] Remmina profiles installed."