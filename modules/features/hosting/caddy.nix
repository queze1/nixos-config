{inputs, ...}: {
  flake.nixosModules.caddy = {
    config,
    lib,
    pkgs,
    ...
  }: {
    age.secrets.osipol-cloudflare-api-token = {
      file = "${inputs.secrets}/osipol-cloudflare-api-token.age";
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };

    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.4"
        ];
        hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
      };

      logFormat = lib.mkForce "level INFO";

      globalConfig = ''
        acme_dns cloudflare {file.${config.age.secrets.osipol-cloudflare-api-token.path}}
      '';

      extraConfig = ''
        (tailscale_auth) {
          forward_auth unix//run/tailscale.nginx-auth.sock {
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
            import tailscale_auth
            reverse_proxy localhost:4533
            tls {
              resolvers 1.1.1.1
            }
          '';
        };
      };
    };
  };
}
