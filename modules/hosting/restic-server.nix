{
  config,
  lib,
  ...
}: let
  cfg = config.services.restic.server;
  myCfg = config.my.apps.restic-server;
in {
  options.my.apps.restic-server = {
    enable = lib.mkEnableOption "Restic server";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "${config.networking.hostName}.restic-server.osipol.uk";
      description = "Domain to host rest-server on.";
    };
    socketPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/restic/restic.sock";
      description = "Socket to run rest-server on.";
    };
  };
  config = lib.mkIf myCfg.enable {
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
    services.caddy.virtualHosts = {
      ${myCfg.domain} = {
        extraConfig = ''
          import cloudflare_dns
          reverse_proxy unix/${myCfg.socketPath}
        '';
      };
    };
    services.ddclient.domains = [myCfg.domain];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = map lib.toIntBase10 myCfg.ports;
  };
}
