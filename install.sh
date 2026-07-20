#!/usr/bin/env bash

set -e

DEFAULT_COPY_TO_PERSISTENT=1

if [ -z "$2" ]; then
    echo "Usage: $0 <target-ip> <hostname> [copy-to-persistent]"
    echo "Example: $0 192.168.1.100 able-archer $DEFAULT_COPY_TO_PERSISTENT"
    exit 1
fi

TARGET_IP=$1
HOSTNAME=$2
COPY_TO_PERSISTENT=${3:-$DEFAULT_COPY_TO_PERSISTENT}

USER_RUN_DIR="/run/user/$(id -u)"
TMP_DIR=$(mktemp -d "$USER_RUN_DIR/nixos-anywhere-deploy.XXXXXX")

# Helper to echo a command and then execute it
run_cmd() {
    local cmd="$1"
    echo "Running: $cmd"
    eval "$cmd"
}

cleanup() {
    if [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

ETC_SSH_DIR="$TMP_DIR/etc/ssh"
PERSISTENT_ETC_SSH_DIR="$TMP_DIR/persistent/etc/ssh"
HOST_KEY_PATH="$ETC_SSH_DIR/ssh_host_ed25519_key"

echo "========================================================="
echo "Generating SSH host keys..."
echo "========================================================="

# Generate SSH host key in temp dir
run_cmd "mkdir -p \"$ETC_SSH_DIR\""
run_cmd "ssh-keygen -t ed25519 -f \"$HOST_KEY_PATH\" -N \"\" -q"
if [ "$COPY_TO_PERSISTENT" = "1" ]; then
    run_cmd "mkdir -p \"$PERSISTENT_ETC_SSH_DIR\""
    run_cmd "cp -r \"$ETC_SSH_DIR/.\" \"$PERSISTENT_ETC_SSH_DIR\""
fi

# Use ssh-to-age to generate a public key from the host key and print it
echo
echo "========================================================="
echo "Generating age public key..."
echo "========================================================="
AGE_PUBLIC_KEY=$(nix run nixpkgs#ssh-to-age -- -i "$HOST_KEY_PATH.pub")
echo "Key: $AGE_PUBLIC_KEY"
echo "Configure secrets for this key in the secrets repo and push the changes."
echo

deploy_cmd=(
    nix run github:nix-community/nixos-anywhere --
    --flake ".#$HOSTNAME"
    --extra-files "$TMP_DIR"
    --generate-hardware-config nixos-facter "./modules/hosts/$HOSTNAME/facter.json"
    --build-on remote
    "root@$TARGET_IP"
)

while true; do
    # Loop for updating secrets
    while true; do
        read -r -p "Update secrets input? (y/n): " choice_update
        case "$choice_update" in
            [Yy]* )
                run_cmd "nix flake update secrets"
                break
                ;;
            [Nn]* )
                echo "Please configure your secrets first." 
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done

    echo
    echo "========================================================="
    echo "Preparing to deploy..."
    echo "========================================================="
    echo "Target IP: $TARGET_IP"
    echo "Hostname:  $HOSTNAME"
    echo "Command to execute:"
    echo "  ${deploy_cmd[*]}"
    echo

    # Loop for starting deployment
    while true; do
        read -r -p "Start deploy? (y/n): " choice_deploy
        case "$choice_deploy" in
            [Yy]* )
                "${deploy_cmd[@]}"
                
                # Break out of both loops to exit
                break 2
                ;;
            [Nn]* )
                break
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done
done
