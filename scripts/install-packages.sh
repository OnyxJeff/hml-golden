#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export APT_LISTCHANGES_FRONTEND=none

APT_FLAGS=(
    -y
    -o Dpkg::Use-Pty=0
    -o Acquire::Retries=3
    -o APT::Install-Recommends=false
)

# ============================
# WAIT FOR SYSTEMD STARTUP
# ============================

wait_for_system() {
    echo "[system] waiting for system initialization..."

    while [[ "$(systemctl is-system-running 2>/dev/null || true)" == "starting" ]]; do
        echo "[system] still starting..."
        sleep 5
    done

    echo "[system] initialization complete"
}

# ============================
# WAIT FOR APT LOCKS
# ============================

wait_for_apt() {
    echo "[packages] waiting for apt/dpkg lock..."

    while \
        sudo lsof /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
        sudo lsof /var/lib/dpkg/lock >/dev/null 2>&1 || \
        sudo lsof /var/lib/apt/lists/lock >/dev/null 2>&1 || \
        sudo lsof /var/cache/apt/archives/lock >/dev/null 2>&1
    do
        echo "[packages] apt is busy..."
        sleep 5
    done

    echo "[packages] apt is available"
}

# ============================
# SYSTEM PREP
# ============================

wait_for_system
wait_for_apt

echo "[packages] repairing package state..."

sudo dpkg --configure -a || true
sudo apt-get install -f "${APT_FLAGS[@]}" || true

wait_for_apt

# ============================
# UPDATE
# ============================

echo "[packages] updating repositories..."

sudo apt-get update

wait_for_apt

# ============================
# UPGRADE
# ============================

echo "[packages] upgrading installed packages..."

sudo apt-get upgrade "${APT_FLAGS[@]}"

wait_for_apt

# ============================
# INSTALL PACKAGES
# ============================

echo "[packages] installing workstation packages..."

sudo apt-get install "${APT_FLAGS[@]}" \
    libreoffice-calc \
    remmina \
    chromium \
    git \
    curl \
    wget \
    tmux \
    htop \
    btop \
    openssh-server \
    gnome-terminal \
    network-manager \
    jq \
    waybar \
    unclutter \
    xterm \
    ca-certificates \
    gnupg \
    dbus-user-session \
    steamlink

wait_for_apt

# ============================
# CLEANUP
# ============================

echo "[packages] cleaning up..."

sudo apt-get autoremove -y || true
sudo apt-get autoclean -y || true
sudo apt-get clean || true

echo "[packages] complete"