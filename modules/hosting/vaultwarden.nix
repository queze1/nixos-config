{
  config,
  lib,
  pkgs,
  ...
}: let
  myCfg = config.my.apps.vaultwarden;
  dataDir = "/var/lib/vaultwarden";
  localTlsDir = "/var/lib/vaultwarden-local-tls";
in {
  options.my.apps.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden";
    runLocally = lib.mkEnableOption "running Vaultwarden locally with Nginx";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "vaultwarden.osipol.uk";
      description = "Domain to host Vaultwarden on.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8007;
      description = "Port to run Vaultwarden on.";
    };
  };

  config = lib.mkIf myCfg.enable (lib.mkMerge [
    {
      services.vaultwarden = {
        enable = true;
        domain =
          if myCfg.runLocally
          then "localhost"
          else myCfg.domain;
        configureNginx = myCfg.runLocally;
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = myCfg.port;
          SIGNUPS_ALLOWED = myCfg.runLocally;
        };
      };

      # Preserve Vaultwarden data
      my.preservation.extraDirectories = [
        {
          directory = dataDir;
          user = "vaultwarden";
          group = "vaultwarden";
          mode = "0700";
        }
      ];

      # Backup Vaultwarden data
      my.restic.extraPaths = [dataDir];
    }

    (lib.mkIf (!myCfg.runLocally) {
      # Reverse proxy
      services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
        import cloudflare_dns
        @protected not path /alive
        import tailscale_auth @protected
        reverse_proxy 127.0.0.1:${toString myCfg.port}
      '';
      services.ddclient.domains = [myCfg.domain];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [myCfg.port];
    })

    (lib.mkIf myCfg.runLocally {
      # Listen on ports 80 and 443, use certs
      services.nginx.virtualHosts.localhost = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 80;
          }
          {
            addr = "127.0.0.1";
            port = 443;
            ssl = true;
          }
        ];
        sslCertificate = "${localTlsDir}/cert.pem";
        sslCertificateKey = "${localTlsDir}/key.pem";
      };

      # Generate a self-signed certificate
      systemd.services.vaultwarden-local-certificate = {
        before = ["nginx.service"];
        requiredBy = ["nginx.service"];
        path = [pkgs.openssl];
        script = ''
          if [ ! -e "$STATE_DIRECTORY/cert.pem" ] || [ ! -e "$STATE_DIRECTORY/key.pem" ]; then
            openssl req -x509 -newkey rsa:4096 -nodes -days 3650 \
              -keyout "$STATE_DIRECTORY/key.pem" \
              -out "$STATE_DIRECTORY/cert.pem" \
              -subj "/CN=localhost" \
              -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:::1"
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          StateDirectory = "vaultwarden-local-tls";
          StateDirectoryMode = "0700";
          User = "nginx";
          Group = "nginx";
          UMask = "0077";
        };
      };

      my.preservation.extraDirectories = [
        {
          directory = localTlsDir;
          user = "nginx";
          group = "nginx";
          mode = "0700";
        }
      ];
    })
  ]);
}
