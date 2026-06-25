{
  inputs,
  lib,
  ...
}: {
  imports = [
    # Integrate home-manager with flake-parts
    inputs.home-manager.flakeModules.home-manager
  ];

  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
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

    perSystem = {system, ...}: {
      # pkgs-stable: Nixpkgs at the latest LTS version
      legacyPackages.pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    };
  };
}
