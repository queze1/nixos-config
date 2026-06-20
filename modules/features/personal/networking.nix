{
  flake.nixosModules.networking = {
    networking.networkmanager.enable = true;
    networking.nftables.enable = true;

    # Micro-optimisations I don't fully understand
    systemd.network.wait-online.enable = true;
    boot.initrd.systemd.network.wait-online.enable = true;

    # Tailscale
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };
    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];
    networking.firewall = {
      trustedInterfaces = ["tailscale0"];
    };
  };
}
