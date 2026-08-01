{
  flake.nixosModules.resticDefaults = {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.my.restic;

    # Extract the services.restic.backups.<name> submodule
    backupSubmodule = options.services.restic.backups.type.nestedTypes.elemType.getSubModules;

    # Define a submodule which sets pre-evaluation defaults
    myBackupSubmodule = lib.types.submodule [
      (
        {name, ...}: {
          imports = backupSubmodule;

          # Recursively set lib.mkDefault, overrides option defaults but is overridden by normal definitions
          config = lib.mapAttrsRecursive (_: value: lib.mkDefault value) {
            initialize = true;
            environmentFile = config.sops.secrets."restic-${name}-env".path;
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

      # Append extraPaths to every backup
      services.restic.backups = lib.mkMerge [
        cfg.backups
        (lib.mapAttrs (_: _: {paths = cfg.extraPaths;}) cfg.backups)
      ];
    };
  };
}
