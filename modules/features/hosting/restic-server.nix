{
  flake.nixosModules.resticServer = {config, ...}: let
    cfg = config.services.restic.server;
    socketPath = "/run/restic/restic.sock";
  in {
    services.restic.server = {
      enable = true;
      appendOnly = true;
      listenAddress = "unix:${socketPath}";
      privateRepos = true;
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
      "restic-server.osipol.uk" = {
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
