{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    src = inputs.actions-languageservices;
    version = (builtins.fromJSON (builtins.readFile "${src}/languageserver/package.json")).version;
    restApiDescription = pkgs.fetchFromGitHub {
      owner = "github";
      repo = "rest-api-description";
      rev = "5e28810649ba41b5483753ba74f976f83856a504";
      hash = "sha256-cf5Bww0aT8ftBcHaX6ST17DbXEqlUsMKhxkl6z4yy5c=";
    };
    packageLock = let
      lock = builtins.fromJSON (builtins.readFile "${src}/package-lock.json");
    in
      lock
      // {
        packages =
          lock.packages
          // {
            "languageservice" =
              lock.packages.languageservice
              // {
                devDependencies =
                  lock.packages.languageservice.devDependencies
                  // {
                    "rest-api-description" = "file:${restApiDescription}";
                  };
              };
            "node_modules/rest-api-description" =
              lock.packages."node_modules/rest-api-description"
              // {
                resolved = "file:${restApiDescription}";
              };
          };
      };
    npmDeps = pkgs.importNpmLock {
      npmRoot = src;
      inherit packageLock;
      packageSourceOverrides."node_modules/rest-api-description" = restApiDescription;
    };
  in {
    myPackages.actions-languageserver = pkgs.buildNpmPackage {
      pname = "actions-languageserver";
      inherit src version;

      nativeBuildInputs = [pkgs.git pkgs.openssh];

      npmWorkspace = "languageserver";
      inherit npmDeps;
      npmConfigHook = pkgs.importNpmLock.npmConfigHook;

      prePatch = ''
        substituteInPlace languageservice/package.json \
          --replace-fail \
            'github:github/rest-api-description' \
            'file:${restApiDescription}'
      '';
    };
  };
}
