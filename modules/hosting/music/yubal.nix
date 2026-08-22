{
  config,
  lib,
  pkgs,
  ...
}: let
  myCfg = config.my.apps.yubal;
  musicDir = "/srv/music";

  yubalImage = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/guillevc/yubal";
    imageDigest = "sha256:1447663d19eb69e4c6c6d274e979a99c4013a7d0a7666ca1bf2127612cd639eb";
    hash = "sha256-QLbHn9CqQ7iV/q5QzQHHfPWkEETO3ETmwX86WN/+uZo=";
    finalImageName = "ghcr.io/guillevc/yubal";
    finalImageTag = "latest";
  };
in {
  options.my.apps.yubal = {
    enable = lib.mkEnableOption "Yubal" // {default = config.my.apps.music-stack.enable;};
    domain = lib.mkOption {
      type = lib.types.str;
      default = "yubal.osipol.uk";
      description = "Domain to host yubal on.";
    };
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

  config = lib.mkIf myCfg.enable {
    # Create a system user to run yubal
    users.users.yubal = {
      isSystemUser = true;
      group = "music";
      linger = true;
      createHome = true;
      home = myCfg.dataDir;
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
        directory = myCfg.dataDir;
        user = "yubal";
        group = "music";
        mode = "0700";
      }
    ];

    # Run yubal with rootless Podman
    virtualisation.oci-containers = {
      containers.yubal = {
        image = "ghcr.io/guillevc/yubal:latest";
        imageFile = yubalImage;
        ports = ["${toString myCfg.port}:8000"];
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
          "${myCfg.dataDir}:/app/config"
        ];
      };
    };

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      ${myCfg.domain} = {
        extraConfig = ''
          import cloudflare_dns
          @protected not path /api/health
          import tailscale_auth @protected
          reverse_proxy 127.0.0.1:${toString myCfg.port}
        '';
      };
    };
    services.ddclient.domains = [myCfg.domain];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
