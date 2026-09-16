{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    src = inputs.actions-languageservices;
    version = (builtins.fromJSON (builtins.readFile "${src}/languageserver/package.json")).version;
  in {
    myPackages.actions-languageserver = pkgs.buildNpmPackage {
      pname = "actions-languageserver";
      inherit src version;

      nativeBuildInputs = [pkgs.git];

      npmWorkspace = "languageserver";
      npmDeps = pkgs.importNpmLock {
        npmRoot = src;
        fetcherOpts = {
          # Rewrite SSH to HTTPS
          "node_modules/rest-api-description" = {
            url = "https://github.com/github/rest-api-description.git";
          };
        };
      };
      npmConfigHook = pkgs.importNpmLock.npmConfigHook;
    };
  };
}
