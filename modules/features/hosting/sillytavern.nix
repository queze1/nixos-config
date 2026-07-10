{
  flake.nixosModules.sillytavern = {
    services.sillytavern = {
      enable = true;
      # port = 8045;
      # TODO: Create config file, whitelist to only Tailscale IPs
    };
  };
}
