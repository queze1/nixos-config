{
  config,
  lib,
  ...
}: let
  myCfg = config.my.apps._4get;
in {
  options.my.apps._4get = {
    enable = lib.mkEnableOption "4get";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "4get.osipol.uk";
      description = "Domain to host 4get on.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to run 4get on.";
    };
  };

  config = lib.mkIf myCfg.enable {
    # Reverse proxy
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      reverse_proxy localhost:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
