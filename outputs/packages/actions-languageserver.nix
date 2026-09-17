{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
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
        outputHash = "sha256-tApLjSS/5ZPXjQy+CgTR/hRkCVcrq+bhTA3Dv8NX2fE=";
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
      src = patchedSrc;
      inherit version;

      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

      npmWorkspace = "languageserver";
      npmDepsFetcherVersion = 2;
      npmDepsHash = lib.fakeHash;
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
