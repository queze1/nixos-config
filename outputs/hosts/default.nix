{
  inputs,
  lib,
  ...
}: {
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
    nixpkgs.lib.nixosSystem
    {
      inherit pkgs;
      modules = modules ++ [(inputs.import-tree ../../modules)];
      specialArgs = lib.mapAttrs (_: nixpkgs: import nixpkgs pkg-args) extraPkgs;
    };
}
