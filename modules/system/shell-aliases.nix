{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.shellAliases;
in {
  options.my.shellAliases.enable = lib.mkEnableOption "shell aliases";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nrs
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nrb

      pkgs.nix-output-monitor # prettier nix builds
    ];

    environment.shellAliases = {
      nfc = "nix flake check";
      nix-flake-init = "nix flake new -t github:queze1/nixos-config .";
    };
  };
}
