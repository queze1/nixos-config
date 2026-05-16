{ pkgs, ... }:
let
  # update-flake: Update and commit NixOS config flake
  update-flake = pkgs.writeShellScriptBin "update-flake" ''
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
      git stash pop || echo "Warning: Stash pop resulted in conflicts. Please resolve manually."
    fi
  '';

  deploy-nix-on-droid = pkgs.writeShellScriptBin "deploy-nix-on-droid" ''
    set -e

    ${update-flake}/bin/update-flake nix-on-droid-repo

    cd ~/etc/nixos

    echo "Rebuilding system..."
    sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch --flake ~/etc/nixos#

    echo "Deploying to server..."
    nix run github:serokell/deploy-rs -- --targets '.#nix-on-droid-server' -- --impure
  '';
in
{
  programs = {
    bash.enable = true;
    btop = {
      enable = true;
      settings = {
        theme_background = false;
      };
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
    nix-index-database.comma.enable = true;
  };

  home.shellAliases = {
    nrs = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch --flake ~/etc/nixos#";
    nrb = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild boot --flake ~/etc/nixos#";
    # Not portable at all, fix sometime
    noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/home/modules/desktop/noctalia.json";
    nix-direnv-init = "nix flake new -t github:nix-community/nix-direnv .";
  };

  home.packages = [
    update-flake
    deploy-nix-on-droid
  ];
}
