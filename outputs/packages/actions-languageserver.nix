{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    # Read from package.json
    version = (builtins.fromJSON (builtins.readFile "${inputs.actions-languageservices}/languageserver/package.json")).version;
  in {
    myPackages.actions-languageserver = pkgs.buildNpmPackage {
      pname = "actions-languageserver";
      inherit version;
      src = inputs.actions-languageservices;
      npmWorkspace = "languageserver";
      npmDepsHash = "sha256-1MT3sOpWFc/QVFe83eEnNtKXsOeghzhRRVYarM1sdKk=";
    };
  };
}
