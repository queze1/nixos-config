{
  flake.nixosModules.caddy = {
    services.caddy = {
      enable = true;
    };
  };
}
