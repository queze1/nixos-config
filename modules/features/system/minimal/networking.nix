{
  flake.nixosModules.minimalSystem =
    { ... }:
    {
      # TODO: Handle firewall, Tailscale SSH, depending on profile
      networking.networkmanager.enable = true;
    };
}
