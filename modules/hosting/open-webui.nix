{
  config,
  lib,
  ...
}: let
  cfg = config.services.open-webui;
  myCfg = config.my.apps.open-webui;
in {
  options.my.apps.open-webui = {
    enable = lib.mkEnableOption "Open WebUI";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "openwebui.osipol.uk";
      description = "Domain to host Open WebUI on.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to run Open WebUI on.";
    };
  };

  config = lib.mkIf myCfg.enable {
    services.open-webui = {
      enable = true;
      host = "127.0.0.1";
      port = myCfg.port;
      environment = {
        ENABLE_SIGNUP = false;
        WEBUI_URL = "https://${myCfg.domain}";
      };
      environmentFile = config.sops.secrets.open-webui-env.path;
    };

    # Force Open WebUI to use a static user
    users.users.open-webui = {
      isSystemUser = true;
      group = "open-webui";
    };
    users.groups.open-webui = {};
    systemd.services.open-webui.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "open-webui";
      Group = "open-webui";
    };

    sops.secrets.open-webui-env = {
      owner = "open-webui";
      group = "open-webui";
      restartUnits = ["open-webui.service"];
    };

    # Preserve Open WebUI data
    my.preservation.extraDirectories = [
      {
        directory = cfg.stateDir;
        user = "open-webui";
        group = "open-webui";
        mode = "0700";
      }
    ];

    # Backup Open WebUI data
    my.restic.extraPaths = [cfg.stateDir];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      import tailscale_auth
      reverse_proxy localhost:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
