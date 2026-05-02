{ config, pkgs, ... }:

{
  # https://web.archive.org/web/20260224055712/https://wiki.nixos.org/wiki/Tailscale
  services.tailscale.enable = true;
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  # https://discourse.nixos.org/t/how-to-configure-and-use-proton-vpn-on-nixos/65837
  networking.firewall.checkReversePath = false;
  environment.systemPackages = with pkgs; [
    wireguard-tools
    proton-vpn
  ];
}
