{ inputs, ... }:
{
  imports = [
    # Integrate home-manager with flake-parts
    # Defines flake.homeModules and flake.homeConfigurations
    inputs.home-manager.flakeModules.home-manager
  ];

  systems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  perSystem =
    { system, ... }:
    {
      # pkgs-stable: Nixpkgs at the latest LTS version
      legacyPackages.pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    };
}
