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

  flake.nixosModules.beszelHub = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.beszel.hub;
    myCfg = config.my.beszel;
  in {
    services.beszel.hub = {
      enable = true;
      host = "127.0.0.1";
      port = myCfg.port;
      environment = {
        APP_URL = "https://${myCfg.domain}";
        TRUSTED_AUTH_HEADER = "X-Webauth-User";
      };
    };

    users.users.beszel-hub = {
      isSystemUser = true;
      group = "beszel-hub";
    };
    users.groups.beszel-hub = {};
    systemd.services.beszel-hub.serviceConfig.DynamicUser = lib.mkForce false;

    # Preserve Beszel state
    my.preservation.extraDirectories = [
      {
        directory = cfg.dataDir;
        user = "beszel-hub";
        group = "beszel-hub";
        mode = "0700";
      }
    ];

    # Back up Beszel data
    my.restic.extraPaths = [cfg.dataDir];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      @protected not path /api/health

      route @protected {
        request_header -X-Webauth-User
        import tailscale_auth
      }

      reverse_proxy localhost:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = [myCfg.port];
  };

  flake.nixosModules.beszelClient = {config, ...}: let
    myCfg = config.my.beszel;
  in {
    services.beszel.agent = {
      enable = true;
      environment = {
        HUB_URL = "https://${myCfg.domain}";
        KEY_FILE = config.sops.secrets.beszel-agent-key.path;
        TOKEN_FILE = config.sops.secrets.beszel-agent-token.path;
        DISABLE_SSH = true;
      };
    };

    sops.secrets = {
      beszel-agent-key.restartUnits = "beszel-agent.service";
      beszel-agent-token.restartUnits = "beszel-agent.service";
    };
  };
}
