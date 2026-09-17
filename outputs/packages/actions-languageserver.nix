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

      nativeBuildInputs = [
        pkgs.git
      ];
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

      npmWorkspace = "languageserver";
      npmDepsHash = lib.fakeHash;
      npmFlags = ["--loglevel" "verbose"];

      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = lib.fakeHash;
    };
  };
}
