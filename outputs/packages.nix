{inputs, ...}: {
  # Applications which need to be manually packaged into Nix
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
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

    packages.tumblr-backup = let
      inherit (pkgs.callPackages inputs.pyproject-nix.build.util {}) mkApplication;

      workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
        workspaceRoot = inputs.tumblr-backup;
      };
      overlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel";
      };

      python = lib.head (inputs.pyproject-nix.lib.util.filterPythonInterpreters {
        inherit (workspace) requires-python;
        inherit (pkgs) pythonInterpreters;
      });
      pythonBase = pkgs.callPackage inputs.pyproject-nix.build.packages {
        inherit python;
      };
      boostPython = pkgs.boost.override {
        enablePython = true;
        inherit python;
      };

      pythonSet = pythonBase.overrideScope (
        lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.wheel
          overlay

          # Add missing build requirements
          (final: prev: {
            quickjs = prev.quickjs.overrideAttrs (old: {
              nativeBuildInputs =
                old.nativeBuildInputs
                ++ final.resolveBuildSystem {
                  setuptools = [];
                };
            });

            py3exiv2 = prev.py3exiv2.overrideAttrs (old: {
              buildInputs =
                (old.buildInputs or [])
                ++ [boostPython pkgs.exiv2];

              nativeBuildInputs =
                old.nativeBuildInputs
                ++ [pkgs.exiv2]
                ++ final.resolveBuildSystem {
                  setuptools = [];
                };
            });
          })
        ]
      );

      venv = pythonSet.mkVirtualEnv "tumblr-backup" workspace.deps.all;
    in
      mkApplication {
        inherit venv;
        package = pythonSet.tumblr-backup;
      };
  };
}
