{
  flake.nixosModules.sillytavern = {config, ...}: {
    services.sillytavern = {
      enable = false;
      # port = 8045;
      # TODO: Create config file, whitelist to only Tailscale IPs
    };

    # Make SillyTavern privately accessible through Tailscale
    services.caddy.virtualHosts = {
      "new.sillytavern.osipol.uk" = {
        extraConfig = ''
          import cloudflare_dns
          import tailscale_auth
          respond "Not yet implemented"
          # reverse_proxy localhost:${toString config.services.sillytavern.port}
        '';
      };
    };
    services.ddclient.domains = ["new.sillytavern.osipol.uk"]; # dynamically update IP
  };
}
