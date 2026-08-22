{
  pkgs,
  config,
  lib,
  ...
}: let
  myCfg = config.my.apps.metube;
  musicDir = "/srv/music";

  metubeImage = pkgs.dockerTools.pullImage {
    imageName = "ghcr.io/alexta69/metube";
    imageDigest = "sha256:c2920f86f888b5398e5a964e135417fe11418823988399e6ec230293dcc0bb31";
    hash = "sha256-y2n7e52QbFMaqkTmYEDIkOcHbQlsfGueFc4MwVE2234=";
    finalImageName = "ghcr.io/alexta69/metube";
    finalImageTag = "latest";
  };
in {
  options.my.apps.metube = {
    enable = lib.mkEnableOption "MeTube" // {default = config.my.apps.music-stack.enable;};
    domain = lib.mkOption {
      type = lib.types.str;
      default = "metube.osipol.uk";
      description = "Domain to host MeTube on.";
    };
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

  config = lib.mkIf myCfg.enable {
    # Create a system user to run MeTube
    users.users.metube = {
      isSystemUser = true;
      group = "music";
      linger = true;
      createHome = true;
      home = myCfg.dataDir;
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
        directory = myCfg.dataDir;
        user = "metube";
        group = "music";
        mode = "0700";
      }
    ];

    # Run with rootless Podman
    virtualisation.oci-containers = {
      containers.metube = {
        image = "ghcr.io/alexta69/metube:latest";
        imageFile = metubeImage;
        ports = ["${toString myCfg.port}:8081"];
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
          "${myCfg.dataDir}:/state"
        ];
      };
    };

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      ${myCfg.domain} = {
        extraConfig = ''
          import cloudflare_dns
          @protected not path /version
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
