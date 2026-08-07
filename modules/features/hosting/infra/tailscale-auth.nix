{
  flake.nixosModules.tailscaleAuth = {config, ...}: {
    services.tailscaleAuth.enable = true;

    # Allow Caddy to authenticate requests with Tailscale
    users.users.${config.services.caddy.user}.extraGroups = ["tailscale-nginx-auth"];

    # Create helper Caddy snippet
    services.caddy = {
      extraConfig = ''
        (tailscale_auth) {
          # e.g. import tailscale_auth @protected to filter forward_auth to @protected
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
      '';
    };
  };
}
