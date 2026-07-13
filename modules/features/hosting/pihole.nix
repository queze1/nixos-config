{
  flake.nixosModules.pihole = {config, ...}: {
    services.pihole-ftl = {
      enable = true;
      settings = {
        # quad9 and Cloudflare
        dns.upstreams = ["9.9.9.9" "1.1.1.1"];
      };
    };

    services.pihole-web = {
      enable = true;
    };

    services.caddy.virtualHosts = {
      "pihole.osipol.uk" = {
        extraConfig = ''
          import cloudflare_dns
          import tailscale_auth
          # Not sure how this works when ports should be a list
          reverse_proxy localhost:${toString config.services.pihole-web.ports}
        '';
      };
    };
    services.ddclient.domains = ["pihole.osipol.uk"]; # dynamically update IP
  };
}
