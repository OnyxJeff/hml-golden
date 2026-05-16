#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo " Pi Workstation Provisioner"
echo "========================================="

bash "$SCRIPT_DIR/install-packages.sh"
bash "$SCRIPT_DIR/setup-wallpaper.sh"
bash "$SCRIPT_DIR/setup-theme.sh"
bash "$SCRIPT_DIR/setup-desktop.sh"
bash "$SCRIPT_DIR/setup-waybar.sh"
bash "$SCRIPT_DIR/setup-tailscale.sh"
bash "$SCRIPT_DIR/setup-ssh.sh"
bash "$SCRIPT_DIR/setup-remmina.sh"

echo ""
echo "========================================="
echo " COMPLETE"
echo "========================================="
echo ""
echo "Run:"
echo "   1.) sudo tailscale set --operator=$USER"
echo "   2.) tailscale up"
echo "   3.) Authenticate to your tailnet"
echo ""
echo "Then reboot."
echo ""
echo "Enjoy your Pi workstation!"