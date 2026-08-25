{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.filebrowser-quantum = pkgs.buildGoModule (let
      version = "unstable-2026-08-25";
      frontend = pkgs.buildNpmPackage {
        pname = "filebrowser-quantum-frontend";
        inherit version;
        src = inputs.filebrowser-quantum;
        sourceRoot = "source/frontend";
        npmDepsHash = "sha256-9UMr7Lm2Z0NSmeFdYEoeUo0/ASzWGke5swAOyyecV30=";
        postPatch = ''
          chmod -R u+w ../backend
        '';
        installPhase = ''
          install -d $out
          cp -r ../backend/internal/web/embed/. $out
        '';
      };
    in {
      pname = "filebrowser-quantum";
      inherit version;
      src = inputs.filebrowser-quantum;
      sourceRoot = "source/backend";
      vendorHash = "sha256-d0YY7FovQeMlxoNL1wz2pSiWeGd3l05L6MOSuX0FT4U=";
      subPackages = ["."];
      doCheck = false;
      nativeBuildInputs = [pkgs.makeWrapper];

      preBuild = ''
        cp -r ${frontend}/. internal/web/embed
      '';

      postInstall = ''
        mv $out/bin/backend $out/bin/filebrowser-quantum
      '';

      postFixup = ''
        wrapProgram $out/bin/filebrowser-quantum \
          --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.ffmpeg]}
      '';
    });
  };
}
