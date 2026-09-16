{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    src = inputs.actions-languageservices;
    version = (builtins.fromJSON (builtins.readFile "${src}/languageserver/package.json")).version;
    patchedSrc =
      pkgs.runCommand "actions-languageservices-patched" {
        nativeBuildInputs = [pkgs.nodejs];

        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-hfdOtTQaMb7xy398EuB0Emoe27rn5AF1s/zg0vgVlu0=";
      } ''
        cp -R ${src}/. $out
        chmod -R u+w $out

        # Regenerate the lock file
        rm -f $out/package-lock.json
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
