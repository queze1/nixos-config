{self, ...}: let
  musicDir = "/srv/music";
  musicGid = 986;
in {
  flake.nixosModules.musicStack = {
    imports = [
      self.nixosModules.navidrome
      self.nixosModules.onTheSpot
      self.nixosModules.yubal
    ];

    # Create group with shared access to the music directory
    users.groups.music = {
      gid = musicGid;
    };

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
      group = "music";
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
        description = "User ID under which yubal runs.";
      };
    };

    config = {
      # Create a system user for yubal
      users.users.yubal = {
        isSystemUser = true;
        uid = cfg.uid;
        group = "music";
      };

      # Preserve yubal data
      my.preservation.extraDirectories = [
        {
          directory = cfg.configDir;
          user = "yubal";
          group = "music";
          mode = "0700";
        }
      ];

      # Run Yubal through Podman
      virtualisation.oci-containers = {
        containers.yubal = {
          image = "ghcr.io/guillevc/yubal:latest";
          autoStart = true;
          ports = ["${toString cfg.port}:8000"];

          environment = {
            PUID = toString cfg.uid;
            PGID = toString musicGid;
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

  flake.nixosModules.onTheSpot = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.onthespot;
  in {
    options.services.onthespot = {
      port = lib.mkOption {
        type = lib.types.int;
        default = 8083;
        description = "Port to run OnTheSpot on.";
      };
      configDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/onthespot";
        description = "Directory where OnTheSpot stores its config.";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        default = 981;
        description = "User ID under which OnTheSpot runs.";
      };
    };

    config = {
      # Create a system user for OnTheSpot
      users.users.onthespot = {
        isSystemUser = true;
        uid = cfg.uid;
        group = "music";
      };

      # Preserve OnTheSpot data
      my.preservation.extraDirectories = [
        {
          directory = cfg.configDir;
          user = "onthespot";
          group = "music";
          mode = "0700";
        }
      ];

      # Run dockerised OnTheSpot through Podman
      virtualisation.oci-containers = {
        containers.onthespot = {
          image = "ghcr.io/jayrez/onthespot-docker:latest";
          autoStart = true;
          ports = ["${toString cfg.port}:5000"];

          environment = {
            HOME = "/config";
            OTS_CONFIG_PATH = "/config";
          };

          volumes = [
            "${musicDir}:/downloads" # download into shared music dir
            "${cfg.configDir}:/config"
          ];
        };
      };
    };
  };
}
