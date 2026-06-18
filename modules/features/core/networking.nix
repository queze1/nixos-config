{
  flake.nixosModules.networking = {
    config,
    lib,
    ...
  }: let
    cfg = config.host.profiles.server;
  in {
    networking.networkmanager.enable = true;
    systemd.network.wait-online.enable = false;
    boot.initrd.systemd.network.wait-online.enable = false;
    networking.nftables.enable = true;

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

    # OpenSSH for servers
    # TODO: Set up Tailscale SSH
    services.openssh = lib.mkIf cfg.enable {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        UsePAM = false;
      };
    };
  };
}
