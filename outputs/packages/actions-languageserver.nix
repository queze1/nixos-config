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
            "node_modules/yocto-queue" =
              lock.packages."node_modules/yocto-queue"
              // {
                resolved = "https://registry.npmjs.org/yocto-queue/-/yocto-queue-0.1.0.tgz";
                integrity = "sha512-rVksvsnNCdJ/ohGc6xgPwyN8eheCxsiLM8mxuE/t/mOVqJewPuO1miLpTHQiRgTKCLexL4MeAFVagts7HmNZ2Q==";
              };
            "node_modules/yn" =
              lock.packages."node_modules/yn"
              // {
                resolved = "https://registry.npmjs.org/yn/-/yn-3.1.1.tgz";
                integrity = "sha512-Ux4ygGWsu2c7isFWe8Yu1YluJmqVhxqK2cLXNQA5AcC3QfbGNpM7fu0Y8b/z16pXLnFxZYvWhd3fhBY9DLmC6Q==";
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
