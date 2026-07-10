{self, ...}: let
  musicDir = "/srv/music";
in {
  flake.nixosModules.musicStack = {config, ...}: {
    imports = [
      self.nixosModules.navidrome
      self.nixosModules.yubal
    ];

    # Create group with shared access to the music directory
    users.groups.music = {};
    users.users.yubal.extraGroups = ["music"];
    users.users.${config.services.navidrome.user}.extraGroups = ["music"];

    # Preserve music directory
    my.preservation.extraDirectories = [
      {
        directory = musicDir;
        user = "root";
        group = "music";
        mode = "2770";
      }
    ];
  };

  flake.nixosModules.navidrome = {config, ...}: {
    services.navidrome = {
      enable = true;
      settings = {
        "MusicFolder" = musicDir;
        "Scanner.Schedule" = "0 * * * *";
      };
    };

    # Preserve Navidrome data
    my.preservation.extraDirectories = [
      {
        directory = "/var/lib/navidrome";
        user = config.services.navidrome.user;
        group = config.services.navidrome.group;
        mode = "0700";
      }
    ];
  };

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
      configDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/yubal";
        description = "Directory where yubal stores its config.";
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
          directory = cfg.configDir;
          user = "yubal";
          group = "yubal";
          mode = "0700";
        }
      ];

      # Run Yubal through Podman
      virtualisation.oci-containers = {
        backend = "podman";
        containers.yubal = {
          image = "ghcr.io/guillevc/yubal:latest";
          autoStart = true;
          ports = ["${toString cfg.port}:8000"];

          environment = {
            PUID = toString cfg.uid;
            PGID = toString cfg.gid;
            YUBAL_SCHEDULER_CRON = "0 0 * * *";
            YUBAL_DOWNLOAD_UGC = "false";
            YUBAL_TZ = "UTC";
          };

          volumes = [
            "${musicDir}:/app/data" # download into shared music dir
            "${cfg.configDir}:/app/config"
          ];
        };
      };
    };
  };
}
