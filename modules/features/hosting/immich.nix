{
  flake.nixosModules.immich = {
    config,
    lib,
    ...
  }: let
    myCfg = config.my.apps.immich;
  in {
    options.my.apps.immich = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "immich.osipol.uk";
        description = "Domain to host Immich on.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 2283;
        description = "Port to run Immich on.";
      };
      mediaDir = lib.mkOption {
        type = lib.types.str;
        default = "/srv/immich";
        description = "Directory where Immich stores media.";
      };
    };

    config = {
      services.immich = {
        enable = true;
        port = myCfg.port;
        mediaLocation = myCfg.mediaDir;
        machine-learning.enable = false;
        settings.server.externalDomain = "https://${myCfg.domain}";
      };

      # Preserve Immich directories and database
      my.preservation.extraDirectories = [
        {
          directory = myCfg.mediaDir;
          user = config.services.immich.user;
          group = config.services.immich.group;
          mode = "0700";
        }
        {
          directory = config.services.postgresql.dataDir;
          user = "postgres";
          group = "postgres";
          mode = "0700";
        }
      ];

      # Backup Immich media
      my.restic.extraPaths = [
        myCfg.mediaDir
      ];

      # Reverse proxy
      services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
        import cloudflare_dns
        reverse_proxy 127.0.0.1:${toString myCfg.port}
      '';
      services.ddclient.domains = [myCfg.domain];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [myCfg.port];
    };
  };
}
