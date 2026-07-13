{
  flake.nixosModules.pihole = {config, ...}: let
    cfg = config.services.pihole-ftl;
  in {
    services.pihole-ftl = {
      enable = true;
      settings = {
        dns = {
          upstreams = [
            # Cloudflare DNS
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
          listeningMode = "SINGLE";
          interface = config.services.tailscale.interfaceName;
        };
      };
      # Has bug where setup service will try to add a list even if it already exists, causing an error
      # lists = [
      #   {
      #     url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
      #   }
      # ];
    };

    services.pihole-web = {
      enable = true;
    };

    # Open firewall for DNS server on Tailscale only
    networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [53];
    };

    # Preserve PiHole state
    my.preservation.extraDirectories = [
      {
        directory = cfg.stateDirectory;
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      }
    ];

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

    services.ddclient.domains = [
      "pihole.osipol.uk"
    ];
  };
}
