{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    nixosAnywhere = inputs.nixos-anywhere.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # flake-update: Update and commit NixOS config flake
      flake-update = pkgs.writeShellScriptBin "flake-update" ''
        set -e
        cd ~/etc/nixos

        # Stash changes
        echo "Stashing changes..."
        STASHED=$(git stash push -m "pre-update-automated-stash" --include-untracked)

        # Update flake inputs
        echo "Updating flake input(s): $@"
        nix flake update "$@"

        # Commit and push the lock file
        if ! git diff --quiet flake.lock; then
          echo "Committing lockfile..."
          git add flake.lock
          git commit -m "chore: update flake ($*)" -- flake.lock
          echo "Pushing changes..."
          git push
        else
          echo "flake.lock is already up to date. Skipping commit."
        fi

        # Unstash changes
        if [[ "$STASHED" != "No local changes to save" ]]; then
          echo "Restoring stashed changes..."
          git stash pop || echo "Stash pop resulted in conflicts. Please resolve manually."
        fi
      '';

      install = pkgs.writeShellApplication {
        name = "install";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.nix
          pkgs.openssh
          pkgs.ssh-to-age
          nixosAnywhere
        ];
        text = ''
          if [ "$#" -lt 2 ]; then
            echo "Usage: $0 <target-ip> <hostname>"
            echo "Example: $0 192.168.1.100 able-archer"
            exit 1
          fi

          TARGET_IP=$1
          HOSTNAME=$2
          USER_RUN_DIR="/run/user/$(id -u)"
          TMP_DIR=$(mktemp -d "$USER_RUN_DIR/nixos-anywhere-deploy.XXXXXX")

          cleanup() {
            if [ -d "$TMP_DIR" ]; then
              rm -rf "$TMP_DIR"
            fi
          }
          trap cleanup EXIT

          PERSISTENT_ETC_SSH_DIR="$TMP_DIR/persistent/etc/ssh"
          HOST_KEY_PATH="$PERSISTENT_ETC_SSH_DIR/ssh_host_ed25519_key"
          PERSISTENT_FACTER_PATH="$TMP_DIR/persistent/facter.json"

          echo "========================================================="
          echo "Generating SSH host keys..."
          echo "========================================================="

          mkdir -p "$PERSISTENT_ETC_SSH_DIR"
          ssh-keygen -t ed25519 -f "$HOST_KEY_PATH" -N "" -q

          echo
          echo "========================================================="
          echo "Generating age public key..."
          echo "========================================================="
          AGE_PUBLIC_KEY=$(ssh-to-age -i "$HOST_KEY_PATH.pub")
          echo "Key: $AGE_PUBLIC_KEY"
          echo "Configure secrets for this key in the secrets repo and push the changes."
          echo

          deploy_cmd=(
            nixos-anywhere
            --flake ".#$HOSTNAME"
            --extra-files "$TMP_DIR"
            --generate-hardware-config nixos-facter "$PERSISTENT_FACTER_PATH"
            --build-on remote
            "root@$TARGET_IP"
          )

          while true; do
            while true; do
              read -r -p "Update secrets input? (y/n): " choice_update
              case "$choice_update" in
                [Yy]*)
                  nix flake update secrets
                  break
                  ;;
                [Nn]*)
                  echo "Please configure your secrets first."
                  ;;
                *)
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
            echo "  ''${deploy_cmd[*]}"
            echo

            while true; do
              read -r -p "Start deploy? (y/n): " choice_deploy
              case "$choice_deploy" in
                [Yy]*)
                  "''${deploy_cmd[@]}"
                  break 2
                  ;;
                [Nn]*)
                  break
                  ;;
                *)
                  echo "Please answer y or n."
                  ;;
              esac
            done
          done
        '';
      };
    };
  };
}
