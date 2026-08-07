{
  flake.nixosModules.gatus = {
    config,
    lib,
    ...
  }: let
    cfg = config.my.apps.gatus;
  in {
    options.my.apps.gatus = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "gatus.osipol.uk";
        description = "Domain to host Gatus on.";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 8080;
        description = "Port to run Gatus on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/gatus";
        description = "Directory where Gatus stores its data.";
      };
    };

    config = {
      services.gatus = {
        enable = true;
        settings = {
          web.address = "127.0.0.1";
          web.port = cfg.port;
          storage.type = "sqlite";
          storage.path = "${cfg.dataDir}/data.db";
          endpoints = [
            {
              name = "website";
              url = "https://twin.sh/health";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[BODY].status == UP"
                "[RESPONSE_TIME] < 300"
              ];
            }
            {
              name = "Navidrome";
              url = "https://navidrome.osipol.uk/ping";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 500"
              ];
            }
          ];
        };
      };

      # Use a static user instead of dynamic user
      users.users.gatus = {
        isSystemUser = true;
        group = "gatus";
      };
      users.groups.gatus = {};
      systemd.services.gatus.serviceConfig.DynamicUser = lib.mkForce false;

      # Preserve Gatus data
      my.preservation.extraDirectories = [
        {
          directory = cfg.dataDir;
          user = "gatus";
          group = "gatus";
          mode = "700";
        }
      ];

      # Reverse proxy with Tailscale auth
      services.caddy.virtualHosts = {
        ${cfg.domain} = {
          extraConfig = ''
            import cloudflare_dns
            import tailscale_auth
            reverse_proxy localhost:${toString cfg.port}
          '';
        };
      };
      services.ddclient.domains = [cfg.domain];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [cfg.port];
    };
  };
}
