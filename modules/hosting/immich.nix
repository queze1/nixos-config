{
  config,
  lib,
  ...
}: let
  cfg = config.services.immich;
  myCfg = config.my.apps.immich;
in {
  options.my.apps.immich = {
    enable = lib.mkEnableOption "Immich";
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
  };

  config = lib.mkIf myCfg.enable {
    services.immich = {
      enable = true;
      host = "127.0.0.1";
      port = myCfg.port;
      settings.server.externalDomain = "https://${myCfg.domain}";
    };

    # Preserve Immich data and Postgres
    my.preservation.extraDirectories = [
      {
        directory = cfg.mediaLocation;
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      }
      {
        directory = config.services.postgresql.dataDir;
        user = "postgres";
        group = "postgres";
        mode = "0700";
      }
    ];

    # Backup Immich data
    my.restic.extraPaths = [
      cfg.mediaLocation
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
}
