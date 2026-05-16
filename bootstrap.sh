#!/usr/bin/env bash
set -euo pipefail

# ============================
# CONFIG
# ============================

REPO_URL="https://github.com/YOUR_USER/hml-golden.git"
REPO_NAME="hml-golden"
BASE_DIR="$HOME"
LOG_FILE="$HOME/hml-golden-bootstrap.log"

# ============================
# LOGGING
# ============================

exec > >(tee -a "$LOG_FILE") 2>&1

# ============================
# COLORS
# ============================

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

# ============================
# UI HELPERS
# ============================

TOTAL_STEPS=6
CURRENT_STEP=0

section() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${CYAN}[ $1 ]${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "${YELLOW}[ ${CURRENT_STEP} / ${TOTAL_STEPS} ]${NC} → $1"
}

ok() {
    echo -e "${GREEN}✔${NC} $1"
}

fail() {
    echo -e "${RED}✖${NC} $1"
}

pause() {
    sleep 1
}

# ============================
# SPINNER
# ============================

spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    echo -ne "${CYAN}$msg${NC} "

    while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 9); do
            echo -ne "\b${spin:$i:1}"
            sleep 0.1
        done
    done

    echo -ne "\b"
    echo -e "${GREEN}✔${NC}"
}

run_with_spinner() {
    local msg=$1
    shift

    "$@" &
    local pid=$!

    spinner "$pid" "$msg"
    wait "$pid"
}

# ============================
# START
# ============================

section "HML-GOLDEN BOOTSTRAP"

echo -e "${CYAN}Log file:${NC} $LOG_FILE"

# ============================
# STEP 1 - DEPENDENCIES
# ============================

section "SYSTEM CHECKS"

step "Checking dependencies"

command -v git >/dev/null 2>&1 || {
    run_with_spinner "Installing git" sudo apt update
    run_with_spinner "Installing git" sudo apt install -y git
}

command -v curl >/dev/null 2>&1 || {
    run_with_spinner "Installing curl" sudo apt update
    run_with_spinner "Installing curl" sudo apt install -y curl
}

ok "Dependencies ready"

# ============================
# STEP 2 - REPO SETUP
# ============================

section "REPOSITORY SETUP"

cd "$BASE_DIR"

step "Ensuring repository exists"

if [ ! -d "$REPO_NAME" ]; then
    run_with_spinner "Cloning repository" git clone "$REPO_URL"
else
    step "Updating repository"
    cd "$REPO_NAME"
    run_with_spinner "Pulling latest changes" git pull
    cd "$BASE_DIR"
fi

cd "$BASE_DIR/$REPO_NAME"

ok "Repository ready"

# ============================
# STEP 3 - VALIDATION
# ============================

section "VALIDATION"

step "Checking project structure"

if [ ! -f "scripts/firstboot.sh" ]; then
    fail "Missing scripts/firstboot.sh"
    exit 1
fi

ok "Structure valid"

# ============================
# STEP 4 - FIRSTBOOT
# ============================

section "SYSTEM CONFIGURATION"

step "Running firstboot configuration"

run_with_spinner "Executing firstboot.sh" bash scripts/firstboot.sh

ok "System configuration complete"

# ============================
# FINISH
# ============================

section "COMPLETE"

echo ""
echo -e "${GREEN}✔ Bootstrap finished successfully${NC}"
echo -e "${CYAN}✔ Log:${NC} $LOG_FILE"
echo ""
echo "Recommended next steps:"
echo "  1. Review the log file for any issues."
echo "  2. run: sudo tailscale set --operator=$USER"
echo "  3. run: tailscale up"
echo "  4. Authenticate to your tailnet"
echo "  5. Reboot the system to apply all changes."
echo "  6. Enjoy your new Pi workstation!"
echo ""