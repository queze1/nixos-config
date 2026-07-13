{
  flake.nixosModules.pihole = {
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

    # TODO: Put on Caddy
  };
}
