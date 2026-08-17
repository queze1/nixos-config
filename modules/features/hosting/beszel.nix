{
  flake.nixosModules.beszel = {lib, ...}: {
    options.my.beszel = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "beszel.osipol.uk";
        description = "Domain to host Beszel Hub on.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8090;
        description = "Port to run Beszel Hub on.";
      };
    };
  };

  flake.nixosModules.beszelHub = {config, ...}: let
    myCfg = config.my.beszel;
  in {
    services.beszel.hub = {
      enable = true;
      dataDir = "/var/lib/beszel";
      host = "127.0.0.1";
      port = myCfg.port;
      environment = {
        APP_URL = "https://${myCfg.domain}";
        TRUSTED_AUTH_HEADER = "X-Webauth-User";
      };
    };

    # Preserve Beszel state
    my.preservation.extraDirectories = [
      {
        directory = "/var/lib/private/beszel";
        user = "beszel-hub";
        group = "beszel-hub";
        mode = "0700";
      }
      {
        directory = "/var/lib/beszel";
        user = "beszel-hub";
        group = "beszel-hub";
        mode = "0700";
      }
    ];

    # Back up Beszel data
    my.restic.extraPaths = [
      "/var/lib/private/beszel"
      "/var/lib/beszel"
    ];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      @protected not path /api/health /api/beszel/agent-connect
      import tailscale_auth @protected
      reverse_proxy localhost:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = [myCfg.port];
  };

  flake.nixosModules.beszelAgent = {config, ...}: let
    myCfg = config.my.beszel;
  in {
    services.beszel.agent = {
      enable = true;
      smartmon.enable = true;
      environmentFile = config.sops.secrets.beszel-agent-env.path;
      environment = {
        HUB_URL = "https://${myCfg.domain}";
        DISABLE_SSH = "true";
      };
    };

    sops.secrets.beszel-agent-env.restartUnits = ["beszel-agent.service"];
  };
}
