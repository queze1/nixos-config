{
  inputs,
  lib,
  ...
}: {
  imports = [
    # Integrate home-manager with flake-parts
    inputs.home-manager.flakeModules.home-manager
  ];

  options.flake = {
    factory = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = {};
    };

    # Since there is no flake-parts module for nix-darwin, specify custom options
    darwinConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
    };

    darwinModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
    };
  };

  config = {
    # For nixd hints
    debug = true;

    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = {
      pkgs,
      self',
      system,
      ...
    }: {
      # pkgs-stable: Nixpkgs at the latest LTS version
      legacyPackages.pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      packages = {
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

        # deploy-nix-on-droid: Deploy Nix-on-Droid config with deploy-rs
        deploy-nix-on-droid = pkgs.writeShellScriptBin "deploy-nix-on-droid" ''
          set -e

          ${self'.packages.flake-update}/bin/flake-update nix-on-droid-repo

          cd ~/etc/nixos

          echo "Rebuilding system..."
          sudo nixos-rebuild switch --flake ~/etc/nixos#

          echo "Deploying to server..."
          nix run github:serokell/deploy-rs -- --targets '.#nix-on-droid-server' -- --impure
        '';
      };
    };
  };
}
