#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export APT_LISTCHANGES_FRONTEND=none

echo "[packages] fixing dpkg state if needed..."
sudo dpkg --configure -a || true
sudo apt install -f -y || true

echo "[packages] updating..."
sudo apt update -y &&
sudo apt-get --fix-broken install

echo "[packages] upgrading..."
sudo apt upgrade -y
sudo apt-get autoremove &&
sudo apt-get clean &&
sudo apt-get autoclean

echo "[packages] installing base tools..."
sudo apt install -y \
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
