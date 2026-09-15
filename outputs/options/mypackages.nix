{
  flake-parts-lib,
  lib,
  ...
}:
flake-parts-lib.mkTransposedPerSystemModule {
  name = "myPackages";
  option = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.package;
    default = {};
    description = "An attribute set of custom packages.";
  };
  file = ./mypackages.nix;
}
