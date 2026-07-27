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
      sops.secrets =
        lib.mapAttrs' (
          name: _:
            lib.nameValuePair "restic-${name}-env" {}
        )
        cfg.backups;

      services.restic.backups = lib.mapAttrs (name: backup:
        backup
        // {
          initialize = lib.mkDefault true;
          environmentFile = lib.mkDefault config.sops.secrets."restic-${name}-env".path;
          timerConfig = {
            OnCalendar = lib.mkDefault "daily";
            Persistent = lib.mkDefault true;
          };
        })
      cfg.backups;
    };
  };
}
