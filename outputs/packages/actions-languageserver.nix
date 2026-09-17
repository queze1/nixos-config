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
        outputHash = "sha256-HaxXf4pY01NVJDtZXGgcIJYcYjWVqabguaX6KY46f6I=";
      } ''
        cp -R ${src}/. $out
        chmod -R u+w $out

        npm pkg set --prefix $out \
          'languageserver.dependencies.@actions/languageservice=file:../languageservice' \
          'languageserver.dependencies.@actions/workflow-parser=file:../workflow-parser' \
          'languageservice.dependencies.@actions/expressions=file:../expressions' \
          'languageservice.dependencies.@actions/workflow-parser=file:../workflow-parser' \
          'workflow-parser.dependencies.@actions/expressions=file:../expressions'

        npm install --package-lock-only \
          --prefix $out \
          --install-links \
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
    };
  };
}
