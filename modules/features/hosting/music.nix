{self, ...}: let
  musicDir = "/srv/music";
  musicGid = 986;
in {
  flake.nixosModules.musicStack = {
    imports = [
      self.nixosModules.navidrome
      self.nixosModules.metube
      self.nixosModules.yubal
      self.nixosModules.picard
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

    # Back up music directory
    my.restic.extraPaths = [musicDir];

    # Ensure any new files are accessible by the music group
    systemd.tmpfiles.settings.music = {
      "/srv/music"."a+" = {
        argument = "default:group:music:rwx";
      };
    };
  };

  flake.nixosModules.navidrome = {config, ...}: let
    cfg = config.services.navidrome;
    dataDir = "/var/lib/navidrome";
    socketPath = "/run/navidrome/navidrome.sock";
  in {
    services.navidrome = {
      enable = true;
      settings = {
        "Address" = "unix:${socketPath}";
        "MusicFolder" = musicDir;
        "Scanner.Schedule" = "0 * * * *";
        "CoverArtPriority" = "embedded, cover.*, folder.*, front.*, external";
        "PID.Album" = "musicbrainz_albumid|album";
        "Backup.Path" = "${dataDir}/backup";
        "Backup.Schedule" = "0 0 * * *";
        "Backup.Count" = 7;
      };
    };

    # Give access to the music dir
    users.users.${cfg.user}.extraGroups = ["music"];

    # Preserve Navidrome data
    my.preservation.extraDirectories = [
      {
        directory = dataDir;
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      }
    ];

    # Back up Navidrome data
    my.restic.extraPaths = [dataDir];
    my.restic.extraExclude = ["${dataDir}/cache"];

    # Give Caddy access to the socket
    users.users.${config.services.caddy.user}.extraGroups = [cfg.group];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      "new.navidrome.osipol.uk" = {
        extraConfig = ''
          import cloudflare_dns
          import tailscale_auth
          reverse_proxy unix/${socketPath}
        '';
      };
    };
    services.ddclient.domains = ["new.navidrome.osipol.uk"];
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
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
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

      # Run with rootless Podman
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
            YTDL_OPTIONS = builtins.toJSON {
              embed-metadata = true;
            };
          };

          volumes = [
            "${musicDir}:/downloads"
            "${cfg.dataDir}:/state"
          ];
        };
      };

      # Reverse proxy with Tailscale auth
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
      services.ddclient.domains = ["metube.osipol.uk"];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [cfg.port];
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
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/yubal";
        description = "Directory where yubal stores its data.";
      };
    };

    config = {
      # Create a system user to run yubal
      users.users.yubal = {
        isSystemUser = true;
        group = "music";
        linger = true;
        createHome = true;
        home = cfg.dataDir;
        subUidRanges = [
          {
            startUid = 200000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 200000;
            count = 65536;
          }
        ];
      };

      # Preserve yubal data
      my.preservation.extraDirectories = [
        {
          directory = cfg.dataDir;
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
            PUID = "0";
            PGID = "0";
            YUBAL_SCHEDULER_CRON = "0 0 * * *";
            YUBAL_DOWNLOAD_UGC = "true";
            YUBAL_TZ = "UTC";
          };

          volumes = [
            "${musicDir}:/app/data"
            "${cfg.dataDir}:/app/config"
          ];
        };
      };

      # Reverse proxy with Tailscale auth
      services.caddy.virtualHosts = {
        "yubal.osipol.uk" = {
          extraConfig = ''
            import cloudflare_dns
            import tailscale_auth

            # https://github.com/podman-container-tools/podman/issues/25674 "Podman accepts but does not forward ipv6 traffic in rootless mode by default"
            # Workaround is to use 127.0.0.1 instead of localhost
            reverse_proxy 127.0.0.1:${toString cfg.port}
          '';
        };
      };
      services.ddclient.domains = ["yubal.osipol.uk"];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [cfg.port];
    };
  };

  flake.nixosModules.picard = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.picard;
  in {
    options.services.picard = {
      port = lib.mkOption {
        type = lib.types.int;
        default = 5800;
        description = "Port to run Picard on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/picard";
        description = "Directory where Picard stores its data.";
      };
    };

    config = {
      # Create a system user to run Picard
      users.users.picard = {
        isSystemUser = true;
        group = "music";
        linger = true;
        createHome = true;
        home = cfg.dataDir;
        subUidRanges = [
          {
            startUid = 300000;
            count = 65536;
          }
        ];
        subGidRanges = [
          {
            startGid = 300000;
            count = 65536;
          }
        ];
      };

      # Preserve Picard data
      my.preservation.extraDirectories = [
        {
          directory = cfg.dataDir;
          user = "picard";
          group = "music";
          mode = "0700";
        }
      ];

      # Run dockerised Picard with rootless Podman
      virtualisation.oci-containers = {
        containers.picard = {
          image = "docker.io/mikenye/picard:latest";
          ports = ["${toString cfg.port}:5800"];
          autoStart = true;
          podman.user = "picard";

          environment = {
            USER_ID = "0";
            GROUP_ID = "0";
            DISPLAY_WIDTH = "1920";
            DISPLAY_HEIGHT = "1080";
            KEEP_APP_RUNNING = "1";
          };

          volumes = [
            "${musicDir}:/storage"
            "${cfg.dataDir}:/config"
          ];
        };
      };

      # Reverse proxy with Tailscale auth
      services.caddy.virtualHosts = {
        "picard.osipol.uk" = {
          extraConfig = ''
            import cloudflare_dns
            import tailscale_auth

            # https://github.com/podman-container-tools/podman/issues/25674 "Podman accepts but does not forward ipv6 traffic in rootless mode by default"
            # Workaround is to use 127.0.0.1 instead of localhost
            reverse_proxy 127.0.0.1:${toString cfg.port}
          '';
        };
      };
      services.ddclient.domains = ["picard.osipol.uk"];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [cfg.port];
    };
  };
}
