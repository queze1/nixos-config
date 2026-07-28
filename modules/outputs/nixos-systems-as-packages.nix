{self, ...}: {
  perSystem = {
    system,
    lib,
    ...
  }: let
    # Helper to retrieve host architecture lazily
    getHostSystem = hostname: nixos:
      if nixos ? _system
      then nixos._system
      else
        lib.warn
        "NixOS configuration '${hostname}' is missing '_system' helper attribute. Falling back to 'pkgs.stdenv.hostPlatform.system', which evaluates the system."
        nixos.pkgs.stdenv.hostPlatform.system;

    # Find all NixOS configurations matching the current architecture
    matchingNixosConfigurations =
      lib.filterAttrs (
        hostname: nixos: (getHostSystem hostname nixos) == system
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
