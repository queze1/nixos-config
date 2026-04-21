{ pkgs, ... }:
let
  # nixify: Initialise nix-direnv for shell.nix
  nixify = pkgs.writeShellScriptBin "nixify" ''
    if [ ! -f .envrc ]; then
      echo "use nix" > .envrc
      ${pkgs.direnv}/bin/direnv allow
    elif ! grep -q "use nix" .envrc; then
      echo "use nix" >> .envrc
      ${pkgs.direnv}/bin/direnv allow
    fi
  '';

  # update-flake: Update and commit NixOS config flake
  update-flake = pkgs.writeShellScriptBin "update-flake" ''
    set -e
    cd ~/etc/nixos

    # Stash changes
    echo "Stashing changes..."
    STASHED=$(git stash push -m "pre-update-automated-stash" --include-untracked)

    # Update flake inputs 
    echo "Updating flake input(s): $@"
    nix flake update nix-on-droid-repo "$@"

    # Commit the lock file
    if ! git diff --quiet flake.lock; then
      echo "Committing lockfile..."
      git add flake.lock
      git commit -m "chore: update flake ($*)" -- flake.lock
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
    sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch

    echo "Deploying to server..."
    nix run github:serokell/deploy-rs -- --targets '.#nix-on-droid-server' -- --impure
  '';
in
{
  programs = {
    bash.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
    foot = {
      enable = true;
      settings = {
        main = {
          shell = "${pkgs.fish}/bin/fish";
          font = "Liberation Mono:size=12";
        };
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "foot.desktop" ];
    };
  };

  home.shellAliases = {
    nrs = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch";
    nrb = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild boot";
    # Not portable at all, fix sometime
    noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/home/modules/desktop/noctalia.json";
  };

  home.packages = [
    nixify
    update-flake
    deploy-nix-on-droid
  ];
}
