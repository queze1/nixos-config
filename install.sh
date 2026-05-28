#!/usr/bin/env bash

set -e

DEFAULT_HOSTNAME="able-archer"
DEFAULT_HOST_KEY_PATH="secrets/tmp/ssh_host_ed25519_key"

if [ -z "$1" ]; then
    echo "Usage: $0 <target-ip> [hostname] [ssh-host-key-path]"
    echo "Example: $0 192.168.1.100 $DEFAULT_HOSTNAME $DEFAULT_HOST_KEY_PATH"
    exit 1
fi

TARGET_IP=$1
HOSTNAME=${2:-$DEFAULT_HOSTNAME}
HOST_KEY_PATH=${3:-$DEFAULT_HOST_KEY_PATH}
HOST_KEY_NAME=$(basename "$HOST_KEY_PATH")
HOST_KEY_DIR=$(dirname "$HOST_KEY_PATH")
TMP_DIR="secrets/tmp"
STAGING_ETC_SSH_DIR="$TMP_DIR/etc/ssh"

# Helper to echo a command and then execute it
run_cmd() {
    local cmd="$1"
    echo "Running: $cmd"
    eval "$cmd"
}

# If host key is not found, generate a host key and prompt user to set it up 
if [ ! -f "$HOST_KEY_PATH" ]; then
    run_cmd "mkdir -p \"$HOST_KEY_DIR\""
    run_cmd "ssh-keygen -t ed25519 -f \"$HOST_KEY_PATH\" -N \"\" -C \"$HOSTNAME\""
    echo
    echo "Public key:"
    cat "${HOST_KEY_PATH}.pub"
    echo
    echo "Add the public key to secrets/secrets.nix, then re-encrypt the secrets:"
    shopt -s nullglob
    AGE_FILES=(secrets/*.age)
    shopt -u nullglob
    if [ ${#AGE_FILES[@]} -gt 0 ]; then
        echo "cd secrets"
        for age_file in "${AGE_FILES[@]}"; do
            echo "nix run github:ryantm/agenix -- -e $(basename "$age_file")"
        done
    else
        echo "No .age files found in secrets/"
    fi
    exit 0
fi

run_cmd "mkdir -p \"$STAGING_ETC_SSH_DIR\""
run_cmd "cp \"$HOST_KEY_PATH\" \"$STAGING_ETC_SSH_DIR/$HOST_KEY_NAME\""

# Remember to update this whenever the command is updated
cat <<EOF
Running: nix run github:nix-community/nixos-anywhere -- \\
    --flake \".#$HOSTNAME\" \\
    --extra-files \"$TMP_DIR\" \\
    --build-on remote \\
    \"root@$TARGET_IP\"

EOF

nix run github:nix-community/nixos-anywhere -- \
    --flake ".#$HOSTNAME" \
    --extra-files "$TMP_DIR" \
    --build-on remote \
    "root@$TARGET_IP"

# Clean up after a successful installation
run_cmd "rm -rf \"$TMP_DIR\""

