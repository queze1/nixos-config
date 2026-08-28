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
      exporter.enable = true;
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

    # Backup Paperless backups
    my.restic.extraPaths = [cfg.exporter.directory];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns

      # /ping: reverse proxy to / and return its status code
      handle_path /ping {
        reverse_proxy localhost:${toString myCfg.port} {
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
    services.ddclient.domains = [myCfg.domain];
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
