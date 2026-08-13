{
  flake.nixosModules.gatus = {
    config,
    lib,
    ...
  }: let
    myCfg = config.my.apps.gatus;
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
        environmentFile = config.sops.secrets.gatus-env.path;
        settings = {
          web.address = "127.0.0.1";
          web.port = myCfg.port;
          storage.type = "sqlite";
          storage.path = "${myCfg.dataDir}/data.db";
          storage.maximum-number-of-results = 480; # 60 mins * 8 hours
          alerting.discord = {
            webhook-url = "$DISCORD_WEBHOOK_URL";
            message-content = "<@&1326330605113315358>";
            default-alert = {
              enabled = true;
              send-on-resolved = true;
              failure-threshold = 3;
              success-threshold = 3;
            };
          };
          endpoints = let
            responseTimeLimit = "500"; # 500 ms
          in [
            {
              name = "Actual Budget";
              group = "Private Apps";
              url = "https://actual.osipol.uk/health";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Immich";
              group = "Private Apps";
              url = "https://immich.osipol.uk/api/server/ping";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
                "[BODY].res == pong"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "MeTube";
              group = "Private Apps";
              url = "https://metube.osipol.uk/version";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Navidrome";
              group = "Private Apps";
              url = "https://navidrome.osipol.uk/ping";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Picard";
              group = "Private Apps";
              url = "https://picard.osipol.uk/ping";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "SillyTavern";
              group = "Private Apps";
              url = "https://sillytavern.osipol.uk/ping";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Vaultwarden";
              group = "Private Apps";
              url = "https://vaultwarden.osipol.uk/alive";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Yubal";
              group = "Private Apps";
              url = "https://yubal.osipol.uk/api/health";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
                "[BODY].status == healthy"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Beszel Hub";
              group = "Private Services";
              url = "https://beszel.osipol.uk/api/health";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Pi-Hole DNS";
              group = "Private Services";
              url = "100.68.90.10"; # steadfast-dart
              dns.query-name = "one.one.one.one";
              dns.query-type = "A";
              conditions = [
                "[BODY] == any(1.1.1.1, 1.0.0.1)"
                "[DNS_RCODE] == NOERROR"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Pi-Hole Web";
              group = "Private Services";
              url = "https://pi-hole.osipol.uk/api/info/client";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "Restic Server";
              group = "Private Services";
              url = "https://restic-server.osipol.uk";
              conditions = [
                "[STATUS] == 401"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
            {
              name = "ARK RP Visualisation";
              group = "Public Websites";
              url = "https://ark-rp-visualisation.osipol.uk/";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < ${responseTimeLimit}"
              ];
              alerts = [{type = "discord";}];
            }
          ];
        };
      };

      sops.secrets.gatus-env.restartUnits = ["gatus.service"];

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
          directory = myCfg.dataDir;
          user = "gatus";
          group = "gatus";
          mode = "700";
        }
      ];

      # Networking with Cloudflare tunnel
      services.cloudflared = {
        tunnels = {
          "e33aff4b-47a8-411f-a7de-f01fa3e3c6b5" = {
            credentialsFile = "${config.sops.secrets.gatus-cloudflare-creds.path}";
            default = "http_status:404";
            ingress = {
              ${myCfg.domain} = "http://127.0.0.1:${toString myCfg.port}";
            };
          };
        };
      };
      sops.secrets.gatus-cloudflare-creds = {};
    };
  };
}
