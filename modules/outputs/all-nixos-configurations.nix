{self, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    nixosToplevels = lib.mapAttrs (_: nixos: nixos.config.system.build.toplevel) self.nixosConfigurations;
  in {
    packages = lib.optionalAttrs pkgs.stdenv.isLinux {
      all-nixos-configurations = pkgs.linkFarm "all-nixos-configurations" nixosToplevels;
    };
  };
}
