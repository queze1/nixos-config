{
  flake.nixosModules.nextcloud = {
    config,
    lib,
    pkgs,
    ...
  }: let
    myCfg = config.my.apps.nextcloud;
    dataDir = "/var/lib/nextcloud";
  in {
    options.my.apps.nextcloud = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "nextcloud.osipol.uk";
        description = "Domain to host Nextcloud on.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8008;
        description = "Port to run the Nextcloud web server on.";
      };
    };

    config = {
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud33;
        hostName = myCfg.domain;
        config = {
          adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
          dbtype = "sqlite";
        };
        settings = {
          log_type = "systemd";
        };
      };

      sops.secrets.nextcloud-admin-password = {};

      # Preserve Nextcloud data
      my.preservation.extraDirectories = [
        {
          directory = dataDir;
          user = "nextcloud";
          group = "nextcloud";
          mode = "0700";
        }
      ];

      # Backup Nextcloud data
      my.restic.extraPaths = [dataDir];

      # Don't use nginx for reverse proxy
      services.nginx.enable = false;

      # Reverse proxy with Tailscale auth
      services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
        import cloudflare_dns
        @protected not path /status.php /remote.php/dav* /.well-known/carddav /.well-known/caldav
        import tailscale_auth @protected
        reverse_proxy 127.0.0.1:${toString myCfg.port}
      '';
      services.ddclient.domains = [myCfg.domain];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [myCfg.port];
    };
  };
}
