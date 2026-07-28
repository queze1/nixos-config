{
  flake.nixosModules.tailscaleAuth = {
    services.tailscaleAuth.enable = true;

    # Allow Cadddy to authenticate requests with Tailscale
    users.users.caddy.extraGroups = ["tailscale-nginx-auth"];
  };
}
