#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export APT_LISTCHANGES_FRONTEND=none

echo "[packages] fixing dpkg state if needed..."
sudo dpkg --configure -a || true
sudo apt install -f -y || true

echo "[packages] updating..."
sudo apt update -y -qq &&
sudo apt-get --fix-broken install -qq

echo "[packages] upgrading..."
sudo apt upgrade -y -qq
sudo apt-get autoremove -qq &&
sudo apt-get clean -qq &&
sudo apt-get autoclean -qq

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

echo "[packages] verifying repositories are up to date..."
sudo apt update -y -qq
