{
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    # Read from package.json
    version = (builtins.fromJSON (builtins.readFile "${inputs.actions-languageservices}/languageserver/package.json")).version;
  in {
    myPackages.actions-languageserver = pkgs.buildNpmPackage {
      pname = "actions-languageserver";
      inherit version;
      src = inputs.actions-languageservices;
      npmWorkspace = "languageserver";
      npmDepsHash = lib.fakeHash;
    };
  };
}
