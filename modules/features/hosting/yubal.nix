{
  flake.nixosModules.yubal = {config, ...}: let
    yubalUid = 980;
    yubalGid = 980;
    yubalDir = "/var/lib/yubal";
  in {
    # Create a system user and group for yubal
    users.users.yubal = {
      isSystemUser = true;
      uid = yubalUid;
      group = "yubal";
    };
    users.groups.yubal = {
      gid = yubalGid;
    };

    # Preserve yubal data
    my.preservation.extraDirectories = [
      {
        directory = yubalDir;
        user = "yubal";
        group = "yubal";
        mode = "0750";
      }
    ];

    # Create yubal directories
    systemd.tmpfiles.rules = [
      "d ${yubalDir}/data   0750 yubal yubal -"
      "d ${yubalDir}/config 0750 yubal yubal -"
    ];

    # Allow Navidrome to access files downloaded by Yubal
    users.users.${config.services.navidrome.user}.extraGroups = ["yubal"];

    # Run Yubal through Podman
    virtualisation.oci-containers = {
      backend = "podman";
      containers.yubal = {
        image = "ghcr.io/guillevc/yubal:latest";
        autoStart = true;
        ports = ["8000:8000"];

        environment = {
          PUID = toString yubalUid;
          PGID = toString yubalGid;
          YUBAL_SCHEDULER_CRON = "0 0 * * *"; # every midnight
          YUBAL_DOWNLOAD_UGC = "false";
          YUBAL_TZ = "UTC";
        };

        volumes = [
          "${yubalDir}/data:/app/data"
          "${yubalDir}/config:/app/config"
        ];
      };
    };
  };
}
