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
        default = "uptime.osipol.uk";
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
          endpoints = let
            responseTimeLimit = "500"; # 500 ms
          in [
            {
              name = "Actual Budget";
              url = "https://actual.osipol.uk/health";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
            }
            {
              name = "Navidrome";
              url = "https://navidrome.osipol.uk/ping";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
            }
            {
              name = "MeTube";
              url = "https://metube.osipol.uk/version";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
            }
            {
              name = "Yubal";
              url = "https://yubal.osipol.uk/api/health";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
                "[BODY].status == healthy"
              ];
            }
            {
              name = "Picard";
              url = "https://picard.osipol.uk/ping";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
            }
            {
              name = "SillyTavern";
              url = "https://sillytavern.osipol.uk/ping";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
            }
            {
              name = "ARK RP Visualisation";
              url = "https://ark-rp-visualisation.osipol.uk/";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
            }
            {
              name = "Pi-Hole Web Interface";
              url = "https://pi-hole.osipol.uk/api/info/client";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
            }
            {
              name = "Pi-Hole DNS";
              url = "100.68.90.10"; # steadfast-dart
              dns.query-name = "one.one.one.one";
              dns.query-type = "A";
              conditions = [
                "[BODY] == any(1.1.1.1, 1.0.0.1)"
                "[DNS_RCODE] == NOERROR"
              ];
            }
            {
              name = "restic-server";
              url = "https://restic-server.osipol.uk:8443";
              conditions = [
                "[STATUS] == 403"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
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
