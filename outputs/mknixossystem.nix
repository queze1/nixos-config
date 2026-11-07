{
  inputs,
  lib,
  self,
  ...
}: let
  commonModules = inputs.import-tree ../modules;
in {
  flake.factory.mkNixosSystem = {
    nixpkgs,
    system,
    modules,
    extraPkgs ? {},
  }: let
    pkgs = self.factory.mkPkgs {inherit nixpkgs system;};
  in
    nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = modules ++ [commonModules];
      specialArgs =
        {
          inherit inputs self;
          sources = import ../npins;
        }
        // lib.mapAttrs (_: nixpkgs: self.factory.mkPkgs {inherit nixpkgs system;}) extraPkgs;
    };
}
