{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.my.shortcuts;

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
      self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
      nrs
      nrb
    ];

    environment.shellAliases = {
      nfc = "nix flake check";
      nix-flake-init = "nix flake new -t github:queze1/nixos-config .";
    };
  };
}
