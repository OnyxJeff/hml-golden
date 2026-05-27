#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "========================================="
echo " Configuring Modular SSH"
echo "========================================="

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

mkdir -p "$REAL_HOME/.ssh/config.d"
mkdir -p "$REAL_HOME/Homelab-SSH"

# --------------------------------------------------
# MAIN CONFIG
# --------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CONFIG="$SCRIPT_DIR/../ssh-config/config"

if [[ -f "$BASE_CONFIG" ]]; then
    cp "$BASE_CONFIG" "$REAL_HOME/.ssh/config"
else
    echo "[!] Missing base SSH config, skipping copy"
fi

chmod 700 "$REAL_HOME/.ssh"
touch "$REAL_HOME/.ssh/config"
chmod 600 "$REAL_HOME/.ssh/config"

# --------------------------------------------------
# CORE SERVERS
# --------------------------------------------------

cat > "$REAL_HOME/.ssh/config.d/core.conf" <<EOF
# Core Infrastructure

Host truenas
    HostName 10.100.0.15
    User truenas_admin

Host aesir
    HostName 10.100.0.30
    User root

Host vanir
    HostName 10.100.0.61
    User root
EOF

# --------------------------------------------------
# COMPUTE NODES
# --------------------------------------------------

cp -rv $REAL_HOME/hml-golden/ssh-config/compute.conf $REAL_HOME/.ssh/config.d/compute.conf

# --------------------------------------------------
# README
# --------------------------------------------------

cat > "$REAL_HOME/Homelab-SSH/README.txt" <<EOF
SSH Aliases Available:

Core:
  ssh truenas
  ssh aesir
  ssh vanir

Compute:
  ssh pp0
  ssh pp1
  ssh pp2
  ssh pp3
  ssh pp4
  ssh pp5
  ssh pp6
  ssh workstation
EOF

# --------------------------------------------------
# Fix ownership (CRITICAL when run via sudo)
# --------------------------------------------------

sudo chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/.ssh"
sudo chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/Homelab-SSH"

echo ""
echo "[✓] Modular SSH configuration installed."