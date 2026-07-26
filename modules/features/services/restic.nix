{
  flake.nixosModules.restic = {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.my.restic;
  in {
    options.my.restic = {
      addDefaults = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Add initialize=True, environmentFile=config.sops.secrets."restic-''${name}-env".path and other defaults to all backups."
        '';
      };

      backups = lib.mkOption {
        type = options.services.restic.backups.type;
        default = {};
        description = "Periodic backups to create with Restic.";
      };
    };

    config = {
      sops.secrets = lib.mkIf cfg.addDefaults (
        lib.mapAttrs' (
          name: _:
            lib.nameValuePair "restic-${name}-env" {}
        )
        cfg.backups
      );

      services.restic.backups = lib.mapAttrs (name: backup:
        backup
        // lib.mkIf cfg.addDefaults {
          initialize = true;
          environmentFile = config.sops.secrets."restic-${name}-env".path;
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
          };
        })
      cfg.backups;
    };
  };
}
