{
  flake.nixosModules.resticDefaults = {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.my.restic;
  in {
    options.my.restic.backups = lib.mkOption {
      type = options.services.restic.backups.type;
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

      # For every backup, set defaults
      services.restic.backups =
        lib.mapAttrs (
          name: backup:
            lib.recursiveUpdate
            {
              initialize = true;
              environmentFile = config.sops.secrets."restic-${name}-env".path;
              timerConfig = {
                OnCalendar = "daily";
                Persistent = true;
              };
            }
            backup
        )
        cfg.backups;
    };
  };
}
