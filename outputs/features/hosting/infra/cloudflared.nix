{
  flake.nixosModules.cloudflared = {
    services.cloudflared.enable = true;
  };
}
