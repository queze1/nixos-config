{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    src = inputs.actions-languageservices;
    version = (builtins.fromJSON (builtins.readFile "${src}/languageserver/package.json")).version;
    patchedSrc =
      pkgs.runCommand "actions-languageservices-patched" {
        nativeBuildInputs = [pkgs.nodejs];
      } ''
        cp -R ${src}/. $out
        chmod -R u+w $out
        npm install --package-lock-only --ignore-scripts --no-audit --no-fund --prefix $out
      '';
  in {
    myPackages.patchedSrc = patchedSrc;
    myPackages.actions-languageserver = pkgs.buildNpmPackage {
      pname = "actions-languageserver";
      inherit version;
      src = patchedSrc;

      npmWorkspace = "languageserver";
      npmDepsHash = "sha256-7ZsnU7aGT/OCEmuy2ndSmN27mwpOUKd1zG07oQjhc7c=";
      npmDepsFetcherVersion = 2;
    };
  };
}
