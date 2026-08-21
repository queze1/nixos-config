{
  config,
  lib,
  ...
}: let
  cfg = config.services.beszel.hub;
  myCfg = config.my.apps.beszel-hub;
in {
  options.my.apps.beszel-hub = {
    enable = lib.mkEnableOption "Beszel Hub";
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

  config = lib.mkIf myCfg.enable {
    services.beszel.hub = {
      enable = true;
      host = "127.0.0.1";
      port = myCfg.port;
      environment = {
        APP_URL = "https://${myCfg.domain}";
        TRUSTED_AUTH_HEADER = "X-Webauth-User";
      };
    };

    # Use a static user instead of dynamic user
    users.users.beszel-hub = {
      isSystemUser = true;
      group = "beszel-hub";
    };
    users.groups.beszel-hub = {};
    systemd.services.beszel-hub.serviceConfig = {
      DynamicUser = lib.mkForce false;
      RemoveIPC = true;
    };

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
      @protected not path /api/health /api/beszel/agent-connect
      import tailscale_auth @protected
      reverse_proxy localhost:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
