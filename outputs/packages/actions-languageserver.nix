{inputs, ...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    src = inputs.actions-languageservices;
    version = (builtins.fromJSON (builtins.readFile "${src}/languageserver/package.json")).version;
    patchedSrc =
      pkgs.runCommand "actions-languageservices-patched" {
        nativeBuildInputs = [
          pkgs.nodejs
          pkgs.git
          pkgs.writableTmpDirAsHomeHook
        ];

        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = lib.fakeHash;
      } ''
        cp -R ${src}/. $out
        chmod -R u+w $out

        # Regenerate the lock file
        rm -f $out/package-lock.json
        npm install --package-lock-only \
                    --prefix $out \
                    --ignore-scripts --no-audit --no-fund \
                    --loglevel verbose
      '';
  in {
    myPackages.actions-languageservices-patched-src = patchedSrc;

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
