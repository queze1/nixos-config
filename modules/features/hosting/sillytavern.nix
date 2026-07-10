{
  flake.nixosModules.sillytavern = {
    services.sillytavern = {
      enable = false;
      # port = 8045;
      # TODO: Create config file, whitelist to only Tailscale IPs
    };
  };
}
