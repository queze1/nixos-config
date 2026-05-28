#!/usr/bin/env bash

set -e

REPO_URL="github:queze1/nix-on-droid-config"
DEFAULT_HOSTNAME="able-archer"

if [ -z "$1" ]; then
    echo "Usage: $0 <target-ip> [hostname]"
    echo "Example: $0 192.168.1.100 able-archer"
    exit 1
fi

TARGET_IP=$1
HOSTNAME=${2:-$DEFAULT_HOSTNAME}

nix run github:nix-community/nixos-anywhere -- \
    --flake "$REPO_URL#$HOSTNAME" \
    --copy-host-keys \
    --build-on remote \
    "root@$TARGET_IP"

