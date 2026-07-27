{
  flake.nixosModules.resticDefaults = {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.my.restic;

    # Extract the services.restic.backups.<name> submodule
    resticBackupSubmodule = options.services.restic.backups.type.nestedTypes.elemType.getSubModules;

    # Define a submodule which sets new defaults (pre-evaluation)
    myResticSubmodule = lib.types.submodule [
      (
        {name, ...}: {
          imports = resticBackupSubmodule;

          # Recursively set lib.mkDefault, overrides option defaults but is overridden by normal definitions
          config = lib.mapAttrsRecursive (_: value: lib.mkDefault value) {
            initialize = true;
            environmentFile = config.sops.secrets."restic-${name}-env".path;
            timerConfig = {
              OnCalendar = "daily";
              Persistent = true;
            };
          };
        }
      )
    ];
  in {
    options.my.restic.backups = lib.mkOption {
      type = lib.types.attrsOf myResticSubmodule;
      default = {};
      description = "Periodic backups to create with Restic.";
    };

    config = {
      # For every backup, define an environment file secret
      sops.secrets =
        lib.mapAttrs' (
          name: _:
            lib.nameValuePair "restic-${name}-env" {}
        )
        cfg.backups;

      services.restic.backups = cfg.backups;
    };
  };
}
