{self, ...}: {
  perSystem = {
    system,
    lib,
    ...
  }: let
    # Find all NixOS configurations matching the current architecture
    matchingNixosConfigurations =
      lib.filterAttrs (
        _: nixos: nixos.pkgs.stdenv.hostPlatform.system == system
      )
      self.nixosConfigurations;

    nixosSystems =
      lib.mapAttrs' (
        hostname: nixos:
          lib.nameValuePair "${hostname}-system" nixos.config.system.build.toplevel
      )
      matchingNixosConfigurations;
  in {
    # Export as packages so CI can find them
    packages = nixosSystems;
  };
}
