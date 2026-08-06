{
  flake.nixosModules.resticServer = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.restic.server;
    myCfg = config.my.apps.resticServer;
    port = 8443; # host on whitelisted port as servers need access
  in {
    options.my.apps.resticServer = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "restic-server.osipol.uk";
        description = "Domain to host rest-server on.";
      };
      socketPath = lib.mkOption {
        type = lib.types.str;
        default = "/run/restic/restic.sock";
        description = "Socket to run rest-server on.";
      };
    };
    config = {
      services.restic.server = {
        enable = true;
        listenAddress = myCfg.socketPath;
        htpasswd-file = config.sops.secrets.restic-server-htpasswd.path;
        appendOnly = true;
        privateRepos = true;
      };

      sops.secrets.restic-server-htpasswd = {
        owner = "restic";
        group = "restic";
      };

      # Preserve restic repository
      my.preservation.extraDirectories = [
        {
          directory = cfg.dataDir;
          user = "restic";
          group = "restic";
          mode = "0700";
        }
      ];

      # Give Caddy access to the socket
      users.users.${config.services.caddy.user}.extraGroups = ["restic"];

      # Reverse proxy
      # NOTE: Don't use tailscale_auth for any service which needs to be reachable by a server, it automatically rejects tagged devices
      services.caddy.virtualHosts = {
        "${myCfg.domain}:${toString port}" = {
          extraConfig = ''
            import cloudflare_dns
            reverse_proxy unix/${myCfg.socketPath}
          '';
        };
      };
      services.ddclient.domains = [myCfg.domain];
    };
  };
}
