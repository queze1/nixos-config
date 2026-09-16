{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    src = inputs.actions-languageservices;
    version = (builtins.fromJSON (builtins.readFile "${src}/languageserver/package.json")).version;
  in {
    myPackages.actions-languageserver = pkgs.buildNpmPackage {
      pname = "actions-languageserver";
      inherit src version;
      npmWorkspace = "languageserver";
      npmDeps = pkgs.importNpmLock {npmRoot = src;};
      npmConfigHook = pkgs.importNpmLock.npmConfigHook;
    };
  };
}
