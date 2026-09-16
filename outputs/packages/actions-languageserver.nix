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
        packageSourceOverrides = {
          "node_modules/rest-api-description" = pkgs.fetchFromGitHub {
            owner = "github";
            repo = "rest-api-description";
            rev = "5e28810649ba41b5483753ba74f976f83856a504";
            hash = "sha256-cf5Bww0aT8ftBcHaX6ST17DbXEqlUsMKhxkl6z4yy5c=";
          };
        };
      };
      npmConfigHook = pkgs.importNpmLock.npmConfigHook;
    };
  };
}
