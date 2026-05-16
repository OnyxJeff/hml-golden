#!/usr/bin/env bash

set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

mkdir -p "$REAL_HOME/.config/waybar"

# --------------------------------------------------
# CONFIG
# --------------------------------------------------

cat > "$REAL_HOME/.config/waybar/config.jsonc" <<EOF
{
  "layer": "top",
  "position": "top",

  "modules-right": [
    "custom/tailscale",
    "clock"
  ],

  "custom/tailscale": {
    "exec": "~/.config/waybar/tailscale-status.sh",
    "interval": 10,
    "return-type": "json",
    "on-click": "gnome-terminal -- tailscale status"
  },

  "clock": {
    "format": "{:%Y-%m-%d %H:%M}"
  }
}
EOF

# --------------------------------------------------
# SAFE TAILSCALE SCRIPT (MAJOR FIX)
# --------------------------------------------------

cat > "$REAL_HOME/.config/waybar/tailscale-status.sh" <<'EOF'
#!/usr/bin/env bash

# Failsafe output ALWAYS returned
if ! command -v tailscale >/dev/null 2>&1; then
    echo '{"text":"⚪ TS","tooltip":"Tailscale not installed"}'
    exit 0
fi

STATUS=$(tailscale status --json 2>/dev/null || true)

if command -v jq >/dev/null 2>&1 && echo "$STATUS" | jq -e '.BackendState == "Running"' >/dev/null 2>&1; then
    echo '{"text":"🟢 TS","tooltip":"Connected"}'
else
    echo '{"text":"🔴 TS","tooltip":"Disconnected"}'
fi
EOF

chmod +x "$REAL_HOME/.config/waybar/tailscale-status.sh"

# --------------------------------------------------
# LABWC AUTOSTART (IDEMPOTENT FIX)
# --------------------------------------------------

mkdir -p "$REAL_HOME/.config/labwc"
AUTOSTART="$REAL_HOME/.config/labwc/autostart"

touch "$AUTOSTART"

grep -qxF "waybar &" "$AUTOSTART" || echo "waybar &" >> "$AUTOSTART"