{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    version = "unstable-${inputs.filebrowser-quantum.lastModifiedDate}";
    frontend = pkgs.buildNpmPackage {
      pname = "filebrowser-quantum-frontend";
      inherit version;
      src = inputs.filebrowser-quantum;
      sourceRoot = "source/frontend";
      npmDepsHash = "sha256-ZJZtHaeNpHV7n3cT0m7YmBuIGM8CObp3IdQWdSiqbKc=";
      postPatch = ''
        chmod -R u+w ../backend
      '';
      installPhase = ''
        install -d $out
        cp -r ../backend/internal/web/embed/. $out
      '';
    };
  in {
    myPackages.filebrowser-quantum = pkgs.buildGo127Module {
      pname = "filebrowser-quantum";
      inherit version;
      src = inputs.filebrowser-quantum;

      sourceRoot = "source/backend";
      vendorHash = "sha256-P3H5kESEd1X5tl0EQyIm680fKz/18KegoPBp1jb69vo=";
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

      meta.mainProgram = "filebrowser-quantum";
      passthru = {inherit frontend;};
    };
  };
}
