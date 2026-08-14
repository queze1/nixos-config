{
  flake.nixosModules.resticServer = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.restic.server;
    myCfg = config.my.apps.resticServer;
  in {
    options.my.apps.resticServer = {
      port = lib.mkOption {
        type = lib.types.int;
        default = 8000;
        description = "Port to host rest-server on.";
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

      # Reverse proxy on Tailscale MagicDNS
      services.caddy.virtualHosts = {
        "${config.networking.hostName}.${config.my.constants.tailnetDomain}:${myCfg.port}" = {
          extraConfig = ''
            reverse_proxy unix/${myCfg.socketPath}
          '';
        };
      };
    };
  };
}
