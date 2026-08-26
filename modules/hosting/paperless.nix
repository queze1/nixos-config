{
  config,
  lib,
  ...
}: let
  cfg = config.services.paperless;
  myCfg = config.my.apps.paperless;
in {
  options.my.apps.paperless = {
    enable = lib.mkEnableOption "Paperless-ngx";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "paperless.osipol.uk";
      description = "Domain to host Paperless-ngx on.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8010;
      description = "Port to run Paperless-ngx on.";
    };
  };

  config = lib.mkIf myCfg.enable {
    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = myCfg.port;
      domain = myCfg.domain;
      database.createLocally = true;
    };

    # Preserve Paperless data and Postgres database
    my.preservation.extraDirectories =
      map (directory: {
        inherit directory;
        user = cfg.user;
        group = config.users.users.${cfg.user}.group;
        mode = "0700";
      }) [cfg.dataDir cfg.consumptionDir cfg.mediaDir]
      ++ [
        {
          directory = config.services.postgresql.dataDir;
          user = "postgres";
          group = "postgres";
          mode = "0700";
        }
      ];

    # TODO: Set up document exporter instead
    # my.restic.extraPaths = [cfg.dataDir];

    # TODO: Find health endpoint and exclude that

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      import tailscale_auth
      reverse_proxy 127.0.0.1:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
