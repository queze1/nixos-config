{
  flake.nixosModules.resticDefaults = {
    pkgs,
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.my.restic;
    toSubpath = p: lib.path.removePrefix /. (/. + p);
    backupSubmodule = options.services.restic.backups.type.nestedTypes.elemType.getSubModules;

    # Wrapper that cds into the latest snapshot before executing restic
    resticWrapper = pkgs.writeShellScriptBin "restic" ''
      set -e
      latest=$(${lib.getExe' pkgs.coreutils "ls"} -1 ${lib.escapeShellArg cfg.snapshotsDir} 2>/dev/null \
        | ${lib.getExe' pkgs.coreutils "sort"} | ${lib.getExe' pkgs.coreutils "tail"} -n1)
      if [ -n "$latest" ]; then
        cd "${cfg.snapshotsDir}/$latest"
      fi
      echo "Working directory: $(${lib.getExe' pkgs.coreutils "pwd"})"
      exec ${lib.getExe pkgs.restic} "$@"
    '';

    # Define a submodule which sets pre-evaluation defaults
    myBackupSubmodule = lib.types.submodule [
      (
        {name, ...}: {
          imports = backupSubmodule;

          config = {
            initialize = lib.mkDefault true;
            environmentFile = lib.mkDefault config.sops.secrets."restic-${name}-env".path;
            package = lib.mkIf (cfg.snapshotsDir != null) (lib.mkDefault resticWrapper);
          };
        }
      )
    ];
  in {
    options.my.restic = {
      backups = lib.mkOption {
        type = lib.types.attrsOf myBackupSubmodule;
        default = {};
        description = "Periodic backups to create with Restic.";
      };
      extraPaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          Which paths to back up. This applies to all backup targets.
        '';
      };
      snapshotsDir = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          If set, paths are backed up relative to the newest (lexicographically last) directory found in this directory.
          Every path is turned into a subpath and a wrapper is generated that `cd`s into that directory before restic runs.
        '';
      };
    };

    config = {
      assertions = [
        {
          assertion = cfg.extraPaths == [] || cfg.backups != {};
          message = "my.restic.extraPaths is set, but no my.restic.backups are defined.";
        }
      ];

      # For every backup, define an environment file secret
      sops.secrets =
        lib.concatMapAttrs (name: _: {
          "restic-${name}-env" = {};
        })
        cfg.backups;

      services.restic.backups = lib.mapAttrs (_: backup:
        backup
        // {
          paths = let
            # Append extraPaths to every backup
            allPaths = backup.paths ++ cfg.extraPaths;
          in
            # Turn every path into a subpath if snapshotsDir was set
            if cfg.snapshotsDir != null
            then map toSubpath allPaths
            else allPaths;
        })
      cfg.backups;

      # Give each restic service ambient capacities instead of running as root
      # https://restic.readthedocs.io/en/latest/080_examples.html#backing-up-your-system-without-running-restic-as-root
      systemd.services = lib.mapAttrs' (name: _:
        lib.nameValuePair "restic-backups-${name}" {
          serviceConfig = {
            DynamicUser = true;
            User = lib.mkForce "restic-${name}";
            AmbientCapabilities = "CAP_DAC_READ_SEARCH";
            CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
          };
        })
      cfg.backups;
    };
  };
}
