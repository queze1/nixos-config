{inputs, ...}: {
  perSystem = {pkgs, ...}: let
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
        outputHash = "sha256-klZ6quUVC1RZRG9wP9gDrTAeHEPvXxrFmpPuiVu/bEI=";
      } ''
        cp -R ${src}/. $out
        chmod -R u+w $out

        # Force git to use HTTPS instead of SSH
        git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"
        git config --global url."https://github.com/".insteadOf "git@github.com:"
        git config --global url."https://github.com/".insteadOf "git+ssh://git@github.com/"

        # Regenerate the lock file
        rm -f $out/package-lock.json
        npm install --package-lock-only --ignore-scripts --no-audit --no-fund --loglevel verbose --prefix $out
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
