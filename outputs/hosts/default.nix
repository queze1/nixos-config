{
  inputs,
  lib,
  self,
  ...
}: let
  commonModules = inputs.import-tree ../../modules;
in {
  flake.factory.mkNixosSystem = {
    nixpkgs,
    system,
    modules,
    extraPkgs ? {},
  }: let
    pkg-args = {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = import nixpkgs pkg-args;
  in
    nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = modules ++ [commonModules];
      specialArgs =
        {
          inherit inputs self;
          sources = import ../../npins;
        }
        // lib.mapAttrs (_: nixpkgs: import nixpkgs pkg-args) extraPkgs;
    };
}
