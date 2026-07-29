{
  flake.nixosModules.sillytavern = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.sillytavern;
  in {
    services.sillytavern = {
      enable = true;
      listen = true;
      configFile = import ./config.nix {inherit config pkgs;};
    };

    # Preserve SillyTavern data
    my.preservation.extraDirectories = [
      {
        directory = "/var/lib/SillyTavern";
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      }
    ];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      "new.sillytavern.osipol.uk" = {
        extraConfig = ''
          import cloudflare_dns
          import tailscale_auth
          reverse_proxy localhost:${toString cfg.port}
        '';
      };
    };
    services.ddclient.domains = ["new.sillytavern.osipol.uk"];
  };
}
