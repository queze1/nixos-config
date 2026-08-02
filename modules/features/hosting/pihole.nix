{
  flake.nixosModules.pihole = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.pihole-ftl;
    cfg-web = config.services.pihole-web;
  in {
    services.pihole-ftl = {
      enable = true;
      settings = {
        dns = {
          upstreams = [
            # Cloudflare DNS
            "1.1.1.1"
            "1.0.0.1"
            # 2606:4700:4700::1111"
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

    # Configure secrets
    systemd.services.pihole-ftl.serviceConfig.EnvironmentFile = config.sops.secrets.pihole-env.path;
    sops.secrets.pihole-env = {
      restartUnits = ["pihole-ftl.service"];
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

    # Open firewall for DNS server on Tailscale only
    networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
      allowedUDPPorts = [53];
      allowedTCPPorts = [53];
    };

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      "pihole.osipol.uk" = {
        extraConfig = ''
          import cloudflare_dns
          reverse_proxy localhost:${toString cfg-web.ports}
        '';
      };
    };
    services.ddclient.domains = ["pihole.osipol.uk"];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = [(lib.toIntBase10 cfg-web.ports)];
  };
}
