{
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: {
    myPackages.actions-languageserver = pkgs.buildNpmPackage {
      pname = "actions-languageserver";
      version = (builtins.fromJSON (builtins.readFile "${inputs.actions-languageservices}/languageserver/package.json")).version;
      src = inputs.actions-languageservices;
      npmDepsHash = lib.fakeHash;
      npmBuildScript = "build --workspace @actions/languageserver";
      nativeBuildInputs = [pkgs.makeWrapper];
      installPhase = ''
        runHook preInstall
        install -d $out/lib/actions-languageserver $out/bin
        cp -r languageserver/dist $out/lib/actions-languageserver/
        cp -r languageserver/bin $out/lib/actions-languageserver/
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/actions-languageserver \
          --add-flags "$out/lib/actions-languageserver/bin/actions-languageserver"
        runHook postInstall
      '';
    };
  };
}
