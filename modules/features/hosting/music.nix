{self, ...}: let
  musicDir = "/srv/music";
  musicGid = 986;
in {
  flake.nixosModules.musicStack = {
    imports = [
      self.nixosModules.navidrome
      self.nixosModules.metube
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

  flake.nixosModules.navidrome = {config, ...}: let
    cfg = config.services.navidrome;
  in {
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
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      }
    ];

    # Make Navidrome privately accessible through Tailscale
    services.caddy.virtualHosts = {
      "new.navidrome.osipol.uk" = {
        extraConfig = ''
          import cloudflare_dns
          import tailscale_auth
          reverse_proxy localhost:${toString cfg.settings.Port}
        '';
      };
    };
    services.ddclient.domains = ["new.navidrome.osipol.uk"]; # dynamically update IP
  };

  flake.nixosModules.metube = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.metube;
  in {
    options.services.metube = {
      port = lib.mkOption {
        type = lib.types.int;
        default = 8081;
        description = "Port to run MeTube on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/metube";
        description = "Directory where MeTube stores its data.";
      };
    };

    config = {
      # Create a system user to run MeTube
      users.users.metube = {
        isSystemUser = true;
        group = "music";
        linger = true;
        createHome = true;
        home = cfg.dataDir;

        # https://github.com/podman-container-tools/podman/blob/main/docs/tutorials/rootless_tutorial.md
        autoSubUidGidRange = true;
      };

      # Preserve MeTube data
      my.preservation.extraDirectories = [
        {
          directory = cfg.dataDir;
          user = "metube";
          group = "music";
          mode = "0700";
        }
      ];

      # Run MeTube with rootless Podman
      virtualisation.oci-containers = {
        containers.metube = {
          image = "ghcr.io/alexta69/metube";
          ports = ["${toString cfg.port}:8081"];
          autoStart = true;
          podman.user = "metube";

          environment = {
            PUID = "0";
            PGID = "0";
            DOWNLOAD_DIR = "/downloads";
            STATE_DIR = "/state";
          };

          volumes = [
            "${musicDir}:/downloads"
            "${cfg.dataDir}:/state"
          ];
        };
      };

      # Make MeTube accessible through Tailscale
      services.caddy.virtualHosts = {
        "metube.osipol.uk" = {
          extraConfig = ''
            import cloudflare_dns
            import tailscale_auth

            # https://github.com/podman-container-tools/podman/issues/25674 "Podman accepts but does not forward ipv6 traffic in rootless mode by default"
            # Workaround is to use 127.0.0.1 instead of localhost
            reverse_proxy 127.0.0.1:${toString cfg.port}
          '';
        };
      };
      services.ddclient.domains = ["metube.osipol.uk"]; # dynamically update IP
    };
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
      # Create a system user to run yubal
      users.users.yubal = {
        isSystemUser = true;
        uid = cfg.uid;
        group = "music";
        linger = true;
        createHome = true;
        home = cfg.configDir;

        # https://github.com/podman-container-tools/podman/blob/main/docs/tutorials/rootless_tutorial.md
        autoSubUidGidRange = true;
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

      # Run yubal with rootless Podman
      virtualisation.oci-containers = {
        containers.yubal = {
          image = "ghcr.io/guillevc/yubal:latest";
          ports = ["${toString cfg.port}:8000"];
          autoStart = true;
          podman.user = "yubal";

          environment = {
            # "If your container runs with the root user, then root in the container is actually your user on the host."
            PUID = "0";
            PGID = "0";

            YUBAL_SCHEDULER_CRON = "0 0 * * *";
            YUBAL_DOWNLOAD_UGC = "true";
            YUBAL_TZ = "UTC";
          };

          volumes = [
            "${musicDir}:/app/data" # download into shared music dir
            "${cfg.configDir}:/app/config"
          ];
        };
      };

      # Make Yubal accessible through Tailscale
      services.caddy.virtualHosts = {
        "yubal.osipol.uk" = {
          extraConfig = ''
            import cloudflare_dns
            import tailscale_auth

            # https://github.com/podman-container-tools/podman/issues/25674 "Podman accepts but does not forward ipv6 traffic in rootless mode by default"
            # Workaround is to use 127.0.0.1 instead of localhost
            reverse_proxy 127.0.0.1:${toString config.services.yubal.port}
          '';
        };
      };
      services.ddclient.domains = ["yubal.osipol.uk"]; # dynamically update IP
    };
  };
}
