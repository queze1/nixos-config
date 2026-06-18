#!/usr/bin/env bash

set -e

DEFAULT_HOSTNAME="able-archer"
DEFAULT_HOST_KEY_PATH="secrets/tmp/ssh_host_ed25519_key"
DEFAULT_COPY_TO_PERSISTENT=1

if [ -z "$1" ]; then
    echo "Usage: $0 <target-ip> [hostname] [ssh-host-key-path] [copy-to-persistent]"
    echo "Example: $0 192.168.1.100 $DEFAULT_HOSTNAME $DEFAULT_HOST_KEY_PATH $DEFAULT_COPY_TO_PERSISTENT"
    exit 1
fi

TARGET_IP=$1
HOSTNAME=${2:-$DEFAULT_HOSTNAME}
HOST_KEY_PATH=${3:-$DEFAULT_HOST_KEY_PATH}
COPY_TO_PERSISTENT=${4:-$DEFAULT_COPY_TO_PERSISTENT}
HOST_KEY_NAME=$(basename "$HOST_KEY_PATH")
HOST_KEY_DIR=$(dirname "$HOST_KEY_PATH")

# Temporary directories
TMP_DIR="secrets/tmp"
STAGING_DIR="$TMP_DIR/staging"
STAGING_ETC_SSH_DIR="$STAGING_DIR/etc/ssh"
STAGING_PERSISTENT_ETC_SSH_DIR="$STAGING_DIR/persistent/etc/ssh"

# Helper to echo a command and then execute it
run_cmd() {
    local cmd="$1"
    echo "Running: $cmd"
    eval "$cmd"
}

# If host key is not found, ask the user to generate it first
if [ ! -f "$HOST_KEY_PATH" ]; then
    echo "Host key not found at $HOST_KEY_PATH."
    echo "Please run ./gen-host-key.sh to generate it, then re-run install.sh."
    exit 1
fi


run_cmd "mkdir -p \"$STAGING_ETC_SSH_DIR\""
run_cmd "cp \"$HOST_KEY_PATH\" \"$STAGING_ETC_SSH_DIR/$HOST_KEY_NAME\""

if [ "$COPY_TO_PERSISTENT" = "1" ]; then
    run_cmd "mkdir -p \"$STAGING_PERSISTENT_ETC_SSH_DIR\""
    run_cmd "cp \"$HOST_KEY_PATH\" \"$STAGING_PERSISTENT_ETC_SSH_DIR/$HOST_KEY_NAME\""
fi

# Remember to update this whenever the command is updated
cat <<EOF
Running: nix run github:nix-community/nixos-anywhere -- \\
    --flake ".#$HOSTNAME" \\
    --extra-files "$STAGING_DIR" \\
    --build-on remote \\
    "root@$TARGET_IP"

EOF

nix run github:nix-community/nixos-anywhere -- \
    --flake ".#$HOSTNAME" \
    --extra-files "$STAGING_DIR" \
    --build-on remote \
    "root@$TARGET_IP" &&
echo &&
echo "To clean up the key, run: ./gen-host-key.sh --delete"

