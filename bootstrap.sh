#!/usr/bin/env bash
set -euo pipefail

# ============================
# CONFIG
# ============================

REPO_URL="https://github.com/OnyxJeff/hml-golden.git"
REPO_NAME="hml-golden"
BASE_DIR="$HOME"

LOG_FILE="$HOME/hml-golden-bootstrap.log"

# ============================
# LOGGING
# ============================

exec > >(tee -a "$LOG_FILE") 2>&1

echo ""
echo "========================================="
echo " hml-golden BOOTSTRAP START"
echo "========================================="
echo "Log: $LOG_FILE"
echo ""

# ============================
# DEPENDENCY CHECKS
# ============================

echo "[*] Checking dependencies..."

command -v git >/dev/null 2>&1 || {
    echo "[!] git not found. Installing..."
    sudo apt update && sudo apt install -y git
}

command -v curl >/dev/null 2>&1 || {
    echo "[!] curl not found. Installing..."
    sudo apt update && sudo apt install -y curl
}

# ============================
# REPO SETUP
# ============================

cd "$BASE_DIR"

if [ ! -d "$REPO_NAME" ]; then
    echo "[*] Repo not found. Cloning..."
    git clone "$REPO_URL"
else
    echo "[*] Repo exists. Updating..."
    cd "$REPO_NAME"
    git pull
    cd "$BASE_DIR"
fi

# ============================
# ENTER REPO
# ============================

cd "$BASE_DIR/$REPO_NAME"

echo "[*] Working directory: $(pwd)"

# ============================
# SAFETY CHECK
# ============================

if [ ! -f "scripts/firstboot.sh" ]; then
    echo "[!] Missing scripts/firstboot.sh"
    echo "    Repo may be corrupted or incomplete"
    exit 1
fi

# ============================
# EXECUTE FIRSTBOOT
# ============================

echo "[*] Running firstboot..."
bash scripts/firstboot.sh

# ============================
# DONE
# ============================

echo ""
echo "========================================="
echo " BOOTSTRAP COMPLETE"
echo "========================================="
echo ""
echo "Next steps:"
echo "  - Run:"
echo "      1.) sudo tailscale set --operator=$USER"
echo "      2.) tailscale up"
echo "      3.) Authenticate to your tailnet"
echo "      4.) reboot (recommended) or log out/in for desktop changes"
echo ""
echo "Enjoy your Pi workstation!"