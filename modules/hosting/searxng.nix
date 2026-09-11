{
  config,
  lib,
  ...
}: let
  myCfg = config.my.apps.searxng;
in {
  options.my.apps.searxng = {
    enable = lib.mkEnableOption "SearXNG";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "searxng.osipol.uk";
      description = "Domain to host SearXNG on.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8888;
      description = "Port to run SearXNG on.";
    };
  };

  config = lib.mkIf myCfg.enable {
    services.searx = {
      enable = true;
      environmentFile = config.sops.secrets.searxng-env.path;
      settings = {
        server = {
          bind_address = "127.0.0.1";
          port = myCfg.port;
          base_url = "https://${myCfg.domain}";
          secret_key = "$SEARX_SECRET_KEY";
        };
        engines = [
          {
            name = "braveapi";
            api_key = "$BRAVE_API_KEY";
            inactive = false;
          }
          {
            name = "brave";
            disabled = true;
          }
          {
            name = "duckduckgo";
            disabled = true;
          }
          {
            name = "google";
            disabled = true;
          }
          {
            name = "startpage";
            disabled = true;
          }
        ];
      };
    };

    sops.secrets.searxng-env = {
      owner = "searx";
      group = "searx";
      restartUnits = [
        "searx-init.service"
        "searx.service"
      ];
    };

    # Reverse proxy
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      reverse_proxy localhost:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
