{
  flake.nixosModules.yubal = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.yubal;
  in {
    options.services.yubal = {
      port = lib.mkOption {
        type = lib.types.int;
        default = 8000;
        description = "Port to run yubal on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/yubal";
        description = "Directory where yubal stores its data.";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 980;
        description = "UID for the yubal system user.";
      };
      gid = lib.mkOption {
        type = lib.types.int;
        default = 980;
        description = "GID for the yubal system group.";
      };
    };

    config = {
      # Create a system user and group for yubal
      users.users.yubal = {
        isSystemUser = true;
        uid = cfg.uid;
        group = "yubal";
      };
      users.groups.yubal = {
        gid = cfg.gid;
      };

      # Preserve yubal data
      my.preservation.extraDirectories = [
        {
          directory = cfg.dataDir;
          user = "yubal";
          group = "yubal";
          mode = "0750";
        }
      ];

      # Create yubal directories
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir}/data   0750 yubal yubal -"
        "d ${cfg.dataDir}/config 0750 yubal yubal -"
      ];

      # Allow Navidrome to access files downloaded by Yubal
      users.users.${config.services.navidrome.user}.extraGroups = ["yubal"];

      # Run Yubal through Podman
      virtualisation.oci-containers = {
        backend = "podman";
        containers.yubal = {
          image = "ghcr.io/guillevc/yubal:latest";
          autoStart = true;
          ports = ["${cfg.port}:8000"];

          environment = {
            PUID = toString cfg.uid;
            PGID = toString cfg.gid;
            YUBAL_SCHEDULER_CRON = "0 0 * * *";
            YUBAL_DOWNLOAD_UGC = "false";
            YUBAL_TZ = "UTC";
          };

          volumes = [
            "${cfg.dataDir}/data:/app/data"
            "${cfg.dataDir}/config:/app/config"
          ];
        };
      };
    };
  };
}
