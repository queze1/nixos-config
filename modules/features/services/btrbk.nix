{
  flake.nixosModules.btrbk = {config, ...}: {
    assertions = [
      {
        assertion = config.preservation.enable or false;
        message = "This module requires the preservation module to function. This may be changed in the future.";
      }
    ];

    # Snapshot /persistent hourly
    services.btrbk.instances."persistent" = {
      onCalendar = "hourly";
      settings = {
        timestamp_format = "long-iso";
        snapshot_preserve_min = "latest";
        snapshot_preserve = "24h";

        volume."/persistent" = {
          subvolume = ".";
          snapshot_dir = "snapshots"; # -> /persistent/snapshots
        };
      };
    };

    # btrbk does not create the snapshot directory itself
    systemd.tmpfiles.settings.btrbk."/persistent/snapshots".d = {
      user = "root";
      group = "root";
      mode = "0700";
    };
  };
}
