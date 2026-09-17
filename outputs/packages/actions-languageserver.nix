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
