{
  flake.nixosModules.attic = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.atticd;
    myCfg = config.my.apps.attic;
  in {
    options.my.apps.attic = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "attic.osipol.uk";
        description = "Domain to host Attic on.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port to run Attic on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/atticd";
        description = "Path where Attic stores its data.";
      };
    };

    config = {
      services.atticd = {
        enable = true;
        environmentFile = config.sops.secrets.atticd-env.path;
        settings = {
          listen = "127.0.0.1:${toString myCfg.port}";
          allowed-hosts = [myCfg.domain];
          api-endpoint = "https://${myCfg.domain}/";
          storage = {
            type = "local";
            path = "${myCfg.dataDir}/storage";
          };
        };
      };

      sops.secrets.atticd-env.restartUnits = ["atticd.service"];

      # Use a static user instead of dynamic user
      users.users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };
      users.groups.${cfg.group} = {};
      systemd.services.atticd.serviceConfig.DynamicUser = lib.mkForce false;

      # Preserve Attic data
      my.preservation.extraDirectories = [
        {
          directory = myCfg.dataDir;
          user = "atticd";
          group = "atticd";
          mode = "0700";
        }
      ];

      # Reverse proxy
      services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
        import cloudflare_dns
        reverse_proxy 127.0.0.1:${toString myCfg.port}
      '';
      services.ddclient.domains = [myCfg.domain];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [myCfg.port];
    };
  };
}
