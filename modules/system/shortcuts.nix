{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.shortcuts;

  # Script to update and commit NixOS config flake
  flake-update = let
    git = lib.getExe pkgs.git;
  in
    pkgs.writeShellScriptBin "flake-update" ''
      set -e
      cd ~/etc/nixos

      # Stash changes
      echo "Stashing changes..."
      STASHED=$(${git} stash push -m "pre-update-automated-stash" --include-untracked)

      # Update flake inputs
      echo "Updating flake input(s): $@"
      nix flake update "$@"

      # Commit and push the lock file
      if ! ${git} diff --quiet flake.lock; then
        echo "Committing lockfile..."
        ${git} add flake.lock
        ${git} commit -m "chore: update flake ($*)" -- flake.lock
        echo "Pushing changes..."
        ${git} push
      else
        echo "flake.lock is already up to date. Skipping commit."
      fi

      # Unstash changes
      if [[ "$STASHED" != "No local changes to save" ]]; then
        echo "Restoring stashed changes..."
        ${git} stash pop || echo "Stash pop resulted in conflicts. Please resolve manually."
      fi
    '';

  mkPrettyNixosRebuild = name: cmd:
    pkgs.writeShellScriptBin name ''
      sudo -v &&
      sudo nixos-rebuild ${cmd} "$@" |&
      ${lib.getExe pkgs.nix-output-monitor}
    '';
  nrs = mkPrettyNixosRebuild "nrs" "switch --flake ~/etc/nixos#";
  nrb = mkPrettyNixosRebuild "nrb" "boot --flake ~/etc/nixos#";
in {
  options.my.shortcuts.enable = lib.mkEnableOption "shortcuts";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      flake-update
      nrs
      nrb
    ];

    environment.shellAliases = {
      nfc = "nix flake check";
      nix-flake-init = "nix flake new -t github:queze1/nixos-config .";
    };
  };
}
