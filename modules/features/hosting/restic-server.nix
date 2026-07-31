{
  flake.nixosModules.resticServer = {config, ...}: let
    cfg = config.services.restic.server;
    socketPath = "/run/restic/restic.sock";
    port = 8433; # host on a non-standard port to whitelist in Tailscale access controls
  in {
    services.restic.server = {
      enable = true;
      listenAddress = socketPath;
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

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      "restic-server.osipol.uk:${port}" = {
        extraConfig = ''
          import cloudflare_dns
          import tailscale_auth
          reverse_proxy unix/${socketPath}
        '';
      };
    };
    services.ddclient.domains = ["restic-server.osipol.uk"];
  };
}
