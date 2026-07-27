{self, ...}: {
  perSystem = {
    system,
    lib,
    ...
  }: let
    # Find all NixOS configurations with the same system
    matchingNixosConfigurations = lib.filterAttrs (_: nixos: nixos.pkgs.stdenv.hostPlatform.system == system) self.nixosConfigurations;
    nixosDerivations = lib.mapAttrs (_: nixos: nixos.config.system.build.toplevel) matchingNixosConfigurations;
  in {
    packages = nixosDerivations;
  };
}
