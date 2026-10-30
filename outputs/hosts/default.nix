{
  inputs,
  lib,
  self,
  ...
}: let
  commonModules = inputs.import-tree ../../modules;

  # Helper function to create a nixpkgs instance
  mkPkgs = {
    nixpkgs,
    system,
  }:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (_: prev: {
          pythonPackagesExtensions =
            prev.pythonPackagesExtensions
            ++ [
              (_: python-prev: {
                fpdf2 = python-prev.fpdf2.overridePythonAttrs (old: {
                  disabledTests = (old.disabledTests or []) ++ ["test_image_with_explicit_dimensions"];
                });
              })
            ];
        })
      ];
    };
in {
  flake.factory = {
    inherit mkPkgs;

    mkNixosSystem = {
      nixpkgs,
      system,
      modules,
      extraPkgs ? {},
    }: let
      pkgs = mkPkgs {inherit nixpkgs system;};
    in
      nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = modules ++ [commonModules];
        specialArgs =
          {
            inherit inputs self;
            sources = import ../../npins;
          }
          // lib.mapAttrs (_: nixpkgs: mkPkgs {inherit nixpkgs system;}) extraPkgs;
      };
  };
}
