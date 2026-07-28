{
  flake.nixosModules.tailscaleAuth = {config, ...}: {
    services.tailscaleAuth.enable = true;

    # Allow Cadddy to authenticate requests with Tailscale
    users.users.${config.services.caddy.user}.extraGroups = ["tailscale-nginx-auth"];
  };
}
