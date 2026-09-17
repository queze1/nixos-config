{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: let
    src = inputs.actions-languageservices;
    version = (builtins.fromJSON (builtins.readFile "${src}/languageserver/package.json")).version;
  in {
    myPackages.actions-languageserver = pkgs.buildNpmPackage {
      pname = "actions-languageserver";
      inherit version src;

      npmWorkspace = "languageserver";
      npmDepsFetcherVersion = 2;
      npmDepsHash = "sha256-7ZsnU7aGT/OCEmuy2ndSmN27mwpOUKd1zG07oQjhc7c=";
      npmFlags = ["--loglevel" "verbose"];

      # postPatch = ''
      #   find . -name package-lock.json -type f -exec sed -i \
      #     -e 's#git+ssh://git@github.com/#https://github.com/#g' \
      #     -e 's#ssh://git@github.com/#https://github.com/#g' \
      #     -e 's#git@github.com:#https://github.com/#g' \
      #     {} +
      # '';

      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = lib.fakeHash;
    };
  };
}
