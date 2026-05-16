#!/usr/bin/env bash

curl -fsSL https://tailscale.com/install.sh | sh

sudo systemctl enable tailscaled