{inputs, ...}: {
  flake.nixosModules.caddy = {
    config,
    pkgs,
    ...
  }: {
    services.caddy = {
      enable = true;
      openFirewall = true; # open ports 80 and 443
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.4"
        ];
        hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
      };

      extraConfig = ''
        (cloudflare_dns) {
          tls {
          	dns cloudflare {file.${config.age.secrets.osipol-cloudflare-api-token.path}}
            propagation_timeout -1
            propagation_delay 15s
          }
        }

        (tailscale_auth) {
          forward_auth unix//${config.services.tailscaleAuth.socketPath} {
            uri /auth
            header_up Remote-Addr {remote_host}
            header_up Remote-Port {remote_port}
            header_up Original-URI {uri}
            copy_headers {
              Tailscale-User>X-Webauth-User
              Tailscale-Name>X-Webauth-Name
              Tailscale-Login>X-Webauth-Login
              Tailscale-Tailnet>X-Webauth-Tailnet
              Tailscale-Profile-Picture>X-Webauth-Profile-Picture
            }
          }
        }
      '';

      virtualHosts = {
        "new.navidrome.osipol.uk" = {
          extraConfig = ''
            import cloudflare_dns
            import tailscale_auth
            reverse_proxy localhost:${toString config.services.navidrome.settings.Port}
          '';
        };
        "new.sillytavern.osipol.uk" = {
          extraConfig = ''
            import cloudflare_dns
            import tailscale_auth
            respond "Not yet implemented"
            # reverse_proxy localhost:${toString config.services.sillytavern.port}
          '';
        };
        "yubal.osipol.uk" = {
          extraConfig = ''
            import cloudflare_dns
            import tailscale_auth
            reverse_proxy localhost:${toString config.services.yubal.port}
          '';
        };
      };
    };

    age.secrets.osipol-cloudflare-api-token = {
      file = "${inputs.secrets}/osipol-cloudflare-api-token.age";
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };

    # Required to authenticate requests with Tailscale
    services.tailscaleAuth.enable = true;
    users.users.caddy.extraGroups = ["tailscale-nginx-auth"];

    # Preserve Caddy data
    my.preservation.extraDirectories = [
      {
        directory = config.services.caddy.dataDir;
        user = config.services.caddy.user;
        group = config.services.caddy.group;
        mode = "0700";
      }
    ];

    # Configure ddclient to update Cloudflare DNS with Tailscale IP
    services.ddclient = {
      enable = true;
      usev4 = "ifv4, ifv4=tailscale0";
      protocol = "cloudflare";
      zone = "osipol.uk";
      domains = [
        "new.navidrome.osipol.uk"
        "new.sillytavern.osipol.uk"
        "yubal.osipol.uk"
      ];
      passwordFile = config.age.secrets.osipol-cloudflare-api-token.path;
      username = "token";
    };
  };
}
