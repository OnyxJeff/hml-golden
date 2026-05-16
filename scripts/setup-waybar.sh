#!/usr/bin/env bash
set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(eval echo "~$REAL_USER")"

WAYBAR_DIR="$REAL_HOME/.config/waybar"
LABWC_DIR="$REAL_HOME/.config/labwc"

mkdir -p "$WAYBAR_DIR"
mkdir -p "$LABWC_DIR"

# ============================
# WAYBAR CONFIG
# ============================

cat > "$WAYBAR_DIR/config.jsonc" <<'EOF'
{
  "layer": "top",
  "position": "bottom",
  "height": 28,

  "modules-left": [
    "clock"
  ],

  "modules-right": [
    "custom/tailscale"
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

# ============================
# WAYBAR STYLE
# ============================

cat > "$WAYBAR_DIR/style.css" <<'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: Sans;
    font-size: 12px;
    min-height: 0;
}

window#waybar {
    background: rgba(20, 20, 20, 0.92);
    color: #ffffff;
}

/* Clock */

#clock {
    padding: 0 10px;
    margin: 2px 4px;
}

/* Tailscale */

#custom-tailscale {
    padding: 0 10px;
    margin: 2px 4px;
    font-weight: bold;
}

#custom-tailscale.connected {
    color: #00ff88;
}

#custom-tailscale.disconnected {
    color: #ff5555;
}
EOF

# ============================
# TAILSCALE STATUS SCRIPT
# ============================

cat > "$WAYBAR_DIR/tailscale-status.sh" <<'EOF'
#!/usr/bin/env bash

if ! command -v tailscale >/dev/null 2>&1; then
    echo '{"text":"TS","class":"disconnected","tooltip":"Tailscale not installed"}'
    exit 0
fi

STATUS=$(tailscale status --json 2>/dev/null || true)

if command -v jq >/dev/null 2>&1 && \
   echo "$STATUS" | jq -e '.BackendState == "Running"' >/dev/null 2>&1; then

    echo '{"text":"● TS","class":"connected","tooltip":"Tailscale Connected"}'
else
    echo '{"text":"● TS","class":"disconnected","tooltip":"Tailscale Disconnected"}'
fi
EOF

chmod +x "$WAYBAR_DIR/tailscale-status.sh"

# ============================
# LABWC AUTOSTART
# ============================

AUTOSTART="$LABWC_DIR/autostart"

touch "$AUTOSTART"

grep -qxF "waybar &" "$AUTOSTART" || echo "waybar &" >> "$AUTOSTART"

# ============================
# OWNERSHIP FIX
# ============================

chown -R "$REAL_USER:$REAL_USER" "$WAYBAR_DIR"

echo ""
echo "[✓] Waybar configured successfully"