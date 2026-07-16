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
          	dns cloudflare {file.${config.sops.secrets.osipol-cloudflare-api-token.path}}
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
    };

    sops.secrets.osipol-cloudflare-api-token = {
      sopsFile = "${inputs.secrets}/secrets/server.yaml";
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };

    # Preserve Caddy data
    my.preservation.extraDirectories = [
      {
        directory = config.services.caddy.dataDir;
        user = config.services.caddy.user;
        group = config.services.caddy.group;
        mode = "0700";
      }
    ];
  };
}
