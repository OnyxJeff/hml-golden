#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# ============================
# SUDO GUARD
# ============================

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: firstboot must be run as root (called by bootstrap)"
    exit 1
fi

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

err() {
    echo -e "${RED}✖${NC} $1"
}

section() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${CYAN}[ $1 ]${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

pause() {
    sleep 0.5
}

# ============================
# SPINNER WRAPPER (single source of truth)
# ============================

spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    echo -ne "${CYAN}$msg${NC} "

    while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 9); do
            printf "\b%s" "${spin:$i:1}"
            sleep 0.1
        done
    done

    printf "\b"
    echo -e "${GREEN}✔${NC}"
}

run_with_spinner() {
    local msg=$1
    shift

    timeout 300 "$@" > /dev/null 2>&1 &
    local pid=$!

    spinner "$pid" "$msg"

    wait "$pid"
    return $?
}

# ============================
# START
# ============================

section "FIRSTBOOT CONFIGURATION"
echo -e "${CYAN}Starting system configuration...${NC}"
pause

# ============================
# STEP 1 - PACKAGES (NOW MODULE-DRIVEN)
# ============================

section "SYSTEM PACKAGES"
step "Running package installer"

if [[ -f "$HOME/hml-golden/scripts/install-packages.sh" ]]; then
    run_with_spinner "Installing system packages" bash "$HOME/hml-golden/scripts/install-packages.sh"
    ok "System packages installed"
else
    err "install-packages.sh missing"
    exit 1
fi

# ============================
# STEP 2 - TAILSCALE (MODULE)
# ============================

section "TAILSCALE"
step "Installing Tailscale"

if [[ -f "$HOME/hml-golden/scripts/setup-tailscale.sh" ]]; then
    run_with_spinner "Setting up Tailscale" bash "$HOME/hml-golden/scripts/setup-tailscale.sh"
    ok "Tailscale configured"
else
    err "setup-tailscale.sh missing"
    exit 1
fi

# ============================
# STEP 3 - SSH CONFIG
# ============================

section "SSH CONFIGURATION"
step "Applying SSH configuration"

if [[ -f "$HOME/hml-golden/scripts/setup-ssh.sh" ]]; then
    run_with_spinner "Configuring SSH" bash "$HOME/hml-golden/scripts/setup-ssh.sh"
    ok "SSH configured"
else
    err "setup-ssh.sh missing"
fi

# ============================
# STEP 4 - REMMINA
# ============================

section "RDP PROFILES"
step "Setting up Remmina profiles"

if [[ -f "$HOME/hml-golden/scripts/setup-remmina.sh" ]]; then
    run_with_spinner "Configuring Remmina" bash "$HOME/hml-golden/scripts/setup-remmina.sh"
    ok "Remmina configured"
else
    err "setup-remmina.sh missing"
fi

# ============================
# STEP 5 - DESKTOP CONFIG
# ============================

section "DESKTOP CONFIG"
step "Applying desktop configuration"

if [[ -f "$HOME/hml-golden/scripts/setup-theme.sh" ]]; then
    run_with_spinner "Applying theme" timeout 60 bash "$HOME/hml-golden/scripts/setup-theme.sh" || true
fi

if [[ -f "$HOME/hml-golden/scripts/setup-wallpaper.sh" ]]; then
    run_with_spinner "Setting wallpaper" timeout 60 bash "$HOME/hml-golden/scripts/setup-wallpaper.sh" || true
fi

if [[ -f "$HOME/hml-golden/scripts/setup-waybar.sh" ]]; then
    run_with_spinner "Configuring Waybar" bash "$HOME/hml-golden/scripts/setup-waybar.sh" || true
fi

ok "Desktop configured"

# ============================
# FINISH
# ============================

section "COMPLETE"
echo ""
echo -e "${GREEN}✔ Firstboot completed successfully${NC}"
exit 0