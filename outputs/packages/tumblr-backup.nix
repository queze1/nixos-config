{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    packages.creamlinux-installer = import inputs.creamlinux-installer {inherit pkgs;};

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
