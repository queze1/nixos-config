{
  flake.nixosModules.tailscaleAuth = {config, ...}: {
    services.tailscaleAuth.enable = true;

    # Allow Caddy to authenticate requests with Tailscale
    users.users.${config.services.caddy.user}.extraGroups = ["tailscale-nginx-auth"];

    # Create helper Caddy snippet
    services.caddy = {
      extraConfig = ''
        (tailscale_auth) {
          route {
            # Strip untrusted headers
            request_header -X-Webauth-User
            request_header -X-Webauth-Name
            request_header -X-Webauth-Login
            request_header -X-Webauth-Tailnet
            request_header -X-Webauth-Profile-Picture

            forward_auth {args[:]} unix//${config.services.tailscaleAuth.socketPath} {
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
        }
      '';
    };
  };
}
