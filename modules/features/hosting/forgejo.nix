{
  flake.nixosModules.forgejo = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.forgejo;
    myCfg = config.my.apps.forgejo;
  in {
    options.my.apps.forgejo = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "forgejo.osipol.uk";
        description = "Domain to host Forgejo on.";
      };
      socketPath = lib.mkOption {
        type = lib.types.str;
        default = "/run/forgejo/forgejo.sock";
        description = "Socket to run Forgejo on.";
      };
    };

    config = {
      services.forgejo = {
        enable = true;
        settings = {
          server = {
            DOMAIN = myCfg.domain;
            ROOT_URL = "https://${myCfg.domain}/";
            PROTOCOL = "http+unix";
            HTTP_ADDR = myCfg.socketPath;
            UNIX_SOCKET_PERMISSION = "660";
          };
          service = {
            REQUIRE_SIGNIN_VIEW = true;
            ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
            ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = true;
          };
        };
      };

      # Preserve Forgejo data
      my.preservation.extraDirectories = [
        {
          directory = cfg.stateDir;
          user = cfg.user;
          group = cfg.group;
          mode = "0700";
        }
      ];

      # https://forgejo.org/docs/latest/admin/upgrade/
      # The reliable way to perform a backup is with a synchronized point-in-time snapshot of all the storage used by Forgejo.
      my.restic.extraPaths = [cfg.stateDir];

      # Give Caddy access to socket
      users.users.${config.services.caddy.user}.extraGroups = [cfg.group];

      # Reverse proxy with Tailscale Auth
      services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
        import cloudflare_dns
        import tailscale_auth
        reverse_proxy unix/${myCfg.socketPath}
      '';
      services.ddclient.domains = [myCfg.domain];
    };
  };
}
