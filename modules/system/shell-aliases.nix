{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.my.shellAliases;
in {
  options.my.shellAliases.enable = lib.mkEnableOption "shell aliases";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
      self.packages.${pkgs.stdenv.hostPlatform.system}.nrs
      self.packages.${pkgs.stdenv.hostPlatform.system}.nrb

      pkgs.nix-output-monitor # prettier nix builds
    ];

    environment.shellAliases = {
      nfc = "nix flake check";
      nix-flake-init = "nix flake new -t github:queze1/nixos-config .";
    };
  };
}
