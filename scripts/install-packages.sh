#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export APT_LISTCHANGES_FRONTEND=none

wait_for_apt() {
    echo "[packages] waiting for apt/dpkg lock..."

    while sudo lsof /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          sudo lsof /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          sudo lsof /var/cache/apt/archives/lock >/dev/null 2>&1; do
        echo "[packages] apt is busy..."
        sleep 5
    done

    echo "[packages] apt is available"
}

echo "[packages] fixing dpkg state if needed..."
wait_for_apt
sudo dpkg --configure -a || true
sudo apt install -f -y || true

echo "[packages] updating..."
sudo apt update -y -qq &&
sudo apt-get --fix-broken install -qq

echo "[packages] upgrading..."
sudo apt upgrade -y -qq

echo "[packages] installing base tools..."
sudo apt install -y -qq \
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

echo "[packages] cleaning up..."
sudo apt-get autoremove -qq &&
sudo apt-get clean -qq &&
sudo apt-get autoclean -qq