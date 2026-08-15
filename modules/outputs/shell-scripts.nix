{
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    # Generate a script which wraps a nixos-rebuild command with nom
    mkPrettyNixosRebuild = name: cmd:
      pkgs.writeShellScriptBin name ''
        sudo -v &&
        sudo nixos-rebuild ${cmd} "$@" |&
        ${lib.getExe pkgs.nix-output-monitor}
      '';
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

      # nrs/nrb: prettified nixos-rebuild
      nrs = mkPrettyNixosRebuild "nrs" "switch --flake ~/etc/nixos#";
      nrb = mkPrettyNixosRebuild "nrb" "boot --flake ~/etc/nixos#";
    };
  };
}
