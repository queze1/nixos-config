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
    sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch

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
    fish.enable = true;
    foot = {
      enable = true;
      settings = {
        main = {
          shell = "${pkgs.fish}/bin/fish";
          font = "Liberation Mono:size=12";
        };
        colors-dark = {
          alpha = 0.92;
          blur = true;

          # https://github.com/catppuccin/foot/blob/main/themes/catppuccin-mocha.ini
          cursor = "11111b f5e0dc";
          foreground = "cdd6f4";
          background = "1e1e2e";

          regular0 = "45475a";
          regular1 = "f38ba8";
          regular2 = "a6e3a1";
          regular3 = "f9e2af";
          regular4 = "89b4fa";
          regular5 = "f5c2e7";
          regular6 = "94e2d5";
          regular7 = "bac2de";

          bright0 = "585b70";
          bright1 = "f38ba8";
          bright2 = "a6e3a1";
          bright3 = "f9e2af";
          bright4 = "89b4fa";
          bright5 = "f5c2e7";
          bright6 = "94e2d5";
          bright7 = "a6adc8";

          "16" = "fab387";
          "17" = "f5e0dc";

          selection-foreground = "cdd6f4";
          selection-background = "414356";

          search-box-no-match = "11111b f38ba8";
          search-box-match = "cdd6f4 313244";

          jump-labels = "11111b fab387";
          urls = "89b4fa";
        };
      };
    };
    nix-index-database.comma.enable = true;
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
