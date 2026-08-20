{
  flake.nixosModules.actual = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.actual;
    myCfg = config.my.apps.actual;
  in {
    options.my.apps.actual = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "actual.osipol.uk";
        description = "Domain to host Actual Budget on.";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 3000;
        description = "Port to run Actual Budget on.";
      };
    };

    config = {
      services.actual = {
        enable = true;
        user = "actual";
        group = "actual";
        settings = {
          hostname = "127.0.0.1";
          port = myCfg.port;
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
        # Nixpkgs option doesn't create subdirs automatically, oversight?
        {
          directory = cfg.settings.serverFiles;
          user = "actual";
          group = "actual";
          mode = "700";
        }
        {
          directory = cfg.settings.userFiles;
          user = "actual";
          group = "actual";
          mode = "700";
        }
      ];

      # Back up Actual data
      my.restic.extraPaths = [cfg.settings.dataDir];

      # Reverse proxy with Tailscale auth
      services.caddy.virtualHosts = {
        ${myCfg.domain} = {
          extraConfig = ''
            import cloudflare_dns
            @protected not path /health
            import tailscale_auth @protected
            reverse_proxy localhost:${toString myCfg.port}
          '';
        };
      };
      services.ddclient.domains = [myCfg.domain];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [myCfg.port];
    };
  };
}
