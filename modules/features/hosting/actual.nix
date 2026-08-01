{
  flake.nixosModules.actual = {config, ...}: let
    cfg = config.services.actual;
  in {
    services.actual = {
      enable = true;
      user = "actual";
      group = "actual";
      settings = {
        hostname = "127.0.0.1";
      };
    };

    # Create a system user to run Actual Budget
    users.users.actual = {
      isSystemUser = true;
      group = "actual";
    };
    users.groups.actual = {};

    # Preserve Actual Budget data
    my.preservation.extraDirectories = [
      {
        directory = cfg.settings.dataDir;
        user = "actual";
        group = "actual";
        mode = "700";
      }
    ];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      "new.actual.osipol.uk" = {
        extraConfig = ''
          import cloudflare_dns
          import tailscale_auth
          reverse_proxy localhost:${toString cfg.port}
        '';
      };
    };
    services.ddclient.domains = ["new.actual.osipol.uk"];
  };
}
