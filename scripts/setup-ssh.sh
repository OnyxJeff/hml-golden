#!/usr/bin/env bash

set -e

echo ""
echo "========================================="
echo " Configuring Modular SSH"
echo "========================================="

# Create structure
mkdir -p "$HOME/.ssh/config.d"
mkdir -p "$HOME/Homelab-SSH"

# Copy main config
cp "$(dirname "$0")/../ssh-config/config" "$HOME/.ssh/config"

chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/config"

# -------------------------
# CORE SERVERS
# -------------------------

cat > "$HOME/.ssh/config.d/core.conf" <<EOF
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

# -------------------------
# COMPUTE NODES
# -------------------------

cat > "$HOME/.ssh/config.d/compute.conf" <<EOF
# Compute Cluster

Host pp0
    HostName 10.100.0.10
    User potentpi0

Host pp1
    HostName 10.100.0.11
    User potentpi1

Host pp2
    HostName 10.100.0.12
    User potentpi2

Host pp3
    HostName 10.100.0.13
    User potentpi3

Host pp4
    HostName 10.100.0.14
    User potentpi4

Host pp5
    HostName 10.10.25.21
    User root

Host pp6
    HostName 10.10.25.20
    User potentpi6

Host simc
    HostName 10.100.0.50
    User root
EOF

# -------------------------
# OPTIONAL FUTURE CATEGORY
# -------------------------

cat > "$HOME/.ssh/config.d/gaming.conf" <<EOF
# Gaming / Media Nodes
# (expand later)

# Host gaming-pc
#     HostName 10.100.0.X
#     User jeff
EOF

# -------------------------
# USER NOTES
# -------------------------

cat > "$HOME/Homelab-SSH/README.txt" <<EOF
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
  ssh simc
EOF

echo ""
echo "[✓] Modular SSH configuration installed."