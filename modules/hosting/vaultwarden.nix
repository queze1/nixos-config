{
  config,
  lib,
  ...
}: let
  myCfg = config.my.apps.vaultwarden;
  dataDir = "/var/lib/vaultwarden";
in {
  options.my.apps.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden";
    runLocally = lib.mkEnableOption "running Vaultwarden locally without reverse proxy";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "vaultwarden.osipol.uk";
      description = "Domain to host Vaultwarden on.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8007;
      description = "Port to run Vaultwarden on.";
    };
  };

  config = lib.mkIf myCfg.enable (lib.mkMerge [
    {
      services.vaultwarden = {
        enable = true;
        domain =
          if myCfg.runLocally
          then "http://localhost:${toString myCfg.port}"
          else myCfg.domain;
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = myCfg.port;
          SIGNUPS_ALLOWED = myCfg.runLocally;
        };
      };

      # Preserve Vaultwarden data
      my.preservation.extraDirectories = [
        {
          directory = dataDir;
          user = "vaultwarden";
          group = "vaultwarden";
          mode = "0700";
        }
      ];

      # Backup Vaultwarden data
      my.restic.extraPaths = [dataDir];
    }

    (lib.mkIf (!myCfg.runLocally) {
      services.vaultwarden.environmentFile = config.sops.secrets.vaultwarden-env.path;

      sops.secrets.vaultwarden-env = {
        restartUnits = ["vaultwarden.service"];
      };

      # Reverse proxy
      services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
        import cloudflare_dns
        reverse_proxy 127.0.0.1:${toString myCfg.port}
      '';
      services.ddclient.domains = [myCfg.domain];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = [myCfg.port];
    })
  ]);
}
