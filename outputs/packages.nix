{inputs, ...}: {
  # Applications which need to be manually packaged into Nix
  perSystem = {pkgs, ...}: {
    packages.filebrowser-quantum = pkgs.buildGo127Module (let
      version = "unstable-${inputs.filebrowser-quantum.lastModifiedDate}";
      frontend = pkgs.buildNpmPackage {
        pname = "filebrowser-quantum-frontend";
        inherit version;
        src = inputs.filebrowser-quantum;
        sourceRoot = "source/frontend";
        npmDepsHash = "sha256-pF524vtMXXmgmgncKD84yUVJhPVX/fqMQmdBACfsG/Q=";
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
      vendorHash = "sha256-GfeKD/VtUfp2ld3irRkBxGWO2ixcuU0ODjtwgzGFOv8=";
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
    });

    tumblr-utils = let
      workspace = inputs.uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};
    in
      workspace;
  };
}
