{
  config,
  lib,
  ...
}: let
  myCfg = config.my.apps.picard;
  musicDir = "/srv/music";
in {
  options.my.apps.picard = {
    enable = lib.mkEnableOption "Picard" // {default = config.my.apps.music-stack.enable;};
    domain = lib.mkOption {
      type = lib.types.str;
      default = "picard.osipol.uk";
      description = "Domain to host Picard on.";
    };
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

  config = lib.mkIf myCfg.enable {
    # Create a system user to run Picard
    users.users.picard = {
      isSystemUser = true;
      group = "music";
      linger = true;
      createHome = true;
      home = myCfg.dataDir;
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
        directory = myCfg.dataDir;
        user = "picard";
        group = "music";
        mode = "0700";
      }
    ];

    # Run dockerised Picard with rootless Podman
    virtualisation.oci-containers = {
      containers.picard = {
        image = "docker.io/mikenye/picard:latest";
        ports = ["${toString myCfg.port}:5800"];
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
          "${myCfg.dataDir}:/config"
        ];
      };
    };

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      ${myCfg.domain} = {
        extraConfig = ''
          import cloudflare_dns

          # No health endpoint, so we create our own
          # Reverse proxy to / and return its status code
          handle_path /ping {
            reverse_proxy 127.0.0.1:${toString myCfg.port} {
              handle_response {
                respond "{rp.status_code}"
              }
            }
          }

          handle {
            import tailscale_auth
            reverse_proxy 127.0.0.1:${toString myCfg.port}
          }
        '';
      };
    };
    services.ddclient.domains = [myCfg.domain];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
