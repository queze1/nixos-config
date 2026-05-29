#!/usr/bin/env bash

set -euo pipefail

DEFAULT_HOST_KEY_PATH="secrets/tmp/ssh_host_ed25519_key"

show_usage() {
    cat <<EOF
Usage: $0 [--replace] [--delete] [ssh-host-key-path]

Options:
  --replace   Replace existing key without prompting.
  --delete    Delete the tmp folder and exit.

Arguments:
  ssh-host-key-path   Path to host key (default: $DEFAULT_HOST_KEY_PATH)
EOF
}

REPLACE=0
DELETE=0
POSITIONAL=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        --replace)
            REPLACE=1
            shift
            ;;
        --delete)
            DELETE=1
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

HOST_KEY_PATH=${POSITIONAL[0]:-$DEFAULT_HOST_KEY_PATH}
HOST_KEY_DIR=$(dirname "$HOST_KEY_PATH")
TMP_DIR="secrets/tmp"

# Helper to echo a command and then execute it
run_cmd() {
    local cmd="$1"
    echo "Running: $cmd"
    eval "$cmd"
}

if [ "$DELETE" -eq 1 ]; then
    if [ -d "$TMP_DIR" ]; then
        run_cmd "rm -rf \"$TMP_DIR\""
        echo "Deleted $TMP_DIR"
    else
        echo "$TMP_DIR does not exist."
    fi
    exit 0
fi

if [ -f "$HOST_KEY_PATH" ]; then
    if [ "$REPLACE" -eq 1 ]; then
        if [ -d "$TMP_DIR" ]; then
            run_cmd "rm -rf \"$TMP_DIR\""
        fi
    else
        read -r -p "Host key already exists at $HOST_KEY_PATH. Replace it? [y/N] " RESPONSE
        case "$RESPONSE" in
            y|Y|yes|YES)
                if [ -d "$TMP_DIR" ]; then
                    run_cmd "rm -rf \"$TMP_DIR\""
                fi
                ;;
            *)
                echo "Aborted."
                exit 0
                ;;
        esac
    fi
fi

run_cmd "mkdir -p \"$HOST_KEY_DIR\""
run_cmd "ssh-keygen -t ed25519 -f \"$HOST_KEY_PATH\" -N \"\""

echo
echo "Public key:"
cat "${HOST_KEY_PATH}.pub"
echo
echo "Add the public key to ssh-keys.nix, then re-encrypt the secrets:"
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

