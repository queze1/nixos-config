{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.my.shellAliases;

  mkPrettyNixosRebuild = name: cmd:
    pkgs.writeShellScriptBin name ''
      sudo -v &&
      sudo nixos-rebuild ${cmd} "$@" |&
      ${lib.getExe pkgs.nix-output-monitor}
    '';
  nrs = mkPrettyNixosRebuild "nrs" "switch --flake ~/etc/nixos#";
  nrb = mkPrettyNixosRebuild "nrb" "boot --flake ~/etc/nixos#";
in {
  options.my.shellAliases.enable = lib.mkEnableOption "shell aliases";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
      nrs
      nrb

      pkgs.nix-output-monitor # prettier nix builds
    ];

    environment.shellAliases = {
      nfc = "nix flake check";
      nix-flake-init = "nix flake new -t github:queze1/nixos-config .";
    };
  };
}
