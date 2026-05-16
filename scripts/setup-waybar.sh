#!/usr/bin/env bash

mkdir -p "$HOME/.config/waybar"

cat > "$HOME/.config/waybar/config.jsonc" <<EOF
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

cat > "$HOME/.config/waybar/tailscale-status.sh" <<'EOF'
#!/usr/bin/env bash

STATUS=$(tailscale status --json 2>/dev/null)

if echo "$STATUS" | jq -e '.BackendState == "Running"' >/dev/null; then
    echo '{"text":"🟢 TS","tooltip":"Connected"}'
else
    echo '{"text":"🔴 TS","tooltip":"Disconnected"}'
fi
EOF

chmod +x "$HOME/.config/waybar/tailscale-status.sh"

mkdir -p "$HOME/.config/labwc"

AUTOSTART="$HOME/.config/labwc/autostart"

touch "$AUTOSTART"

if ! grep -q "waybar" "$AUTOSTART"; then
    echo "waybar &" >> "$AUTOSTART"
fi