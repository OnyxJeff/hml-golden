#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export APT_LISTCHANGES_FRONTEND=none

echo "[packages] fixing dpkg state if needed..."
dpkg --configure -a || true
apt-get install -f -y || true

echo "[packages] updating..."
apt-get update -y -qq

echo "[packages] upgrading..."
apt-get upgrade -y -qq

echo "[packages] installing base tools..."
apt-get install -y -qq \
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
    dbus-user-session