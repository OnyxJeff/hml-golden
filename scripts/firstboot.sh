#!/usr/bin/env bash
set -euo pipefail

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
# STEP TRACKING
# ============================

TOTAL_STEPS=5
CURRENT_STEP=0

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "${YELLOW}[ ${CURRENT_STEP} / ${TOTAL_STEPS} ]${NC} → $1"
}

ok() {
    echo -e "${GREEN}✔${NC} $1"
}

section() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${CYAN}[ $1 ]${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

pause() {
    sleep 1
}

# ============================
# SPINNER (shared style)
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

section "FIRSTBOOT CONFIGURATION"

echo -e "${CYAN}Starting system configuration...${NC}"
pause

# ============================
# STEP 1 - PACKAGES
# ============================

section "SYSTEM PACKAGES"

run_with_spinner "Updating package lists" bash -c "
    export DEBIAN_FRONTEND=noninteractive
    sudo apt update -qq
"

run_with_spinner "Upgrading packages" bash -c "
    export DEBIAN_FRONTEND=noninteractive
    sudo apt upgrade -y -qq
"

run_with_spinner "Cleaning up packages" bash -c "
    sudo apt autoremove -y -qq
"

step "Installing core apps"

run_with_spinner "Installing LibreOffice" sudo apt install -y libreoffice
run_with_spinner "Installing Remmina" sudo apt install -y remmina
run_with_spinner "Installing Chromium" sudo apt install -y chromium
run_with_spinner "Installing Steam Link" sudo apt install -y steamlink || true

ok "Core applications installed"

# ============================
# STEP 2 - TAILSCALE
# ============================

section "TAILSCALE"

step "Installing Tailscale"

run_with_spinner "Installing Tailscale" curl -fsSL https://tailscale.com/install.sh | sh

ok "Tailscale installed (run 'sudo tailscale up' if needed)"

# ============================
# STEP 3 - SSH CONFIG
# ============================

section "SSH CONFIGURATION"

step "Applying SSH configuration"

if [ -f "$HOME/hml-golden/scripts/setup-ssh.sh" ]; then
    run_with_spinner "Configuring SSH" bash "$HOME/hml-golden/scripts/setup-ssh.sh"
    ok "SSH configured"
else
    echo -e "${YELLOW}⚠ SSH script not found (skipping)${NC}"
fi

# ============================
# STEP 4 - REMMINA
# ============================

section "RDP PROFILES"

step "Setting up Remmina profiles"

if [ -f "$HOME/hml-golden/scripts/setup-remmina.sh" ]; then
    run_with_spinner "Configuring Remmina" bash "$HOME/hml-golden/scripts/setup-remmina.sh"
    ok "Remmina configured"
else
    echo -e "${YELLOW}⚠ Remmina script not found (skipping)${NC}"
fi

# ============================
# STEP 5 - DESKTOP SETUP
# ============================

section "DESKTOP CONFIG"

step "Applying desktop configuration"

# Placeholder for your theme/wallpaper system
if [ -f "$HOME/hml-golden/scripts/setup-theme.sh" ]; then
    run_with_spinner "Applying theme" bash "$HOME/hml-golden/scripts/setup-theme.sh"
fi

if [ -f "$HOME/hml-golden/scripts/setup-wallpaper.sh" ]; then
    run_with_spinner "Setting wallpaper" bash "$HOME/hml-golden/scripts/setup-wallpaper.sh"
fi

ok "Desktop configured"

# ============================
# FINISH
# ============================

section "COMPLETE"

echo ""
echo -e "${GREEN}✔ Firstboot completed successfully${NC}"
echo ""