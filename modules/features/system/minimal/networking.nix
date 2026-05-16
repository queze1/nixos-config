{
  flake.nixosModules.minimalSystem =
    { config, ... }:
    {
      # TODO: Options for Tailscale SSH, hardening
      networking.networkmanager.enable = true;
      systemd.network.wait-online.enable = false; # unnecessary if network manager is enabled
      boot.initrd.systemd.network.wait-online.enable = false;

      # Configure Tailscale
      services.tailscale = {
        enable = true;
        openFirewall = true;
      };
      systemd.services.tailscaled.serviceConfig.Environment = [
        "TS_DEBUG_FIREWALL_MODE=nftables"
      ];
      networking.firewall = {
        trustedInterfaces = [ "tailscale0" ];
      };
    };
}
