#!/usr/bin/env bash
set -euo pipefail

# ============================
# CONFIG
# ============================

REPO_URL="https://github.com/OnyxJeff/hml-golden.git"
REPO_NAME="hml-golden"
BASE_DIR="$HOME"
LOG_FILE="$HOME/hml-golden-bootstrap.log"

# Prevent Git credential prompts (IMPORTANT)
export GIT_TERMINAL_PROMPT=0

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

err() {
    echo -e "${RED}✖${NC} $1"
}

pause() {
    sleep 0.5
}

# ============================
# SPINNER (hardened)
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

    # HARDENED: silence EVERYTHING
    "$@" > /dev/null 2>&1 &
    local pid=$!

    spinner "$pid" "$msg"
    wait "$pid"
}

# ============================
# START
# ============================

section "HML-GOLDEN BOOTSTRAP"

echo -e "${CYAN}Log file:${NC} $LOG_FILE"
pause

# ============================
# STEP 1 - DEPENDENCIES
# ============================

section "SYSTEM CHECKS"

step "Checking dependencies"

# Single silent apt update (avoid spam)
run_with_spinner "Refreshing package index" bash -c '
    apt-get update -qq
'

command -v git >/dev/null 2>&1 || {
    run_with_spinner "Installing git" bash -c '
        apt-get install -y -qq git
    '
}

command -v curl >/dev/null 2>&1 || {
    run_with_spinner "Installing curl" bash -c '
        apt-get install -y -qq curl
    '
}

ok "Dependencies ready"

# ============================
# STEP 2 - REPO SETUP
# ============================

section "REPOSITORY SETUP"

cd "$BASE_DIR"

step "Checking repository access"

if ! git ls-remote "$REPO_URL" >/dev/null 2>&1; then
    err "Cannot access repo: $REPO_URL"
    err "Likely: private repo, wrong URL, or missing access"
    exit 1
fi

step "Cloning repository"

if [ ! -d "$REPO_NAME" ]; then
    run_with_spinner "Cloning repository" git clone --depth 1 "$REPO_URL"
else
    step "Updating repository"
    cd "$REPO_NAME"
    run_with_spinner "Pulling latest changes" git pull --ff-only
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
    err "Missing scripts/firstboot.sh"
    exit 1
fi

ok "Structure valid"

# ============================
# STEP 4 - FIRSTBOOT
# ============================

section "SYSTEM CONFIGURATION"

step "Running firstboot configuration"

FIRSTBOOT_LOG="$HOME/firstboot.log"

# Run firstboot directly (no spinner, no subshell)
bash scripts/firstboot.sh 2>&1 | tee "$FIRSTBOOT_LOG"
rc=${PIPESTATUS[0]}

if [[ $rc -ne 0 ]]; then
    err "firstboot.sh failed (exit $rc)"
    exit $rc
fi

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