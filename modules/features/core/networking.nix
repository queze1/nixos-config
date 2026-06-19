{
  flake.nixosModules.networking = {
    config,
    lib,
    ...
  }: let
    isServer = config.host.profiles.server.enable;
  in {
    networking.networkmanager.enable = ! isServer;

    # Use iwctl to connect on headless servers
    networking.wireless.iwd.enable = isServer;

    networking.nftables.enable = true;

    # Don't wait for network to come online on desktops
    systemd.network.wait-online.enable = ! isServer;
    boot.initrd.systemd.network.wait-online.enable = ! isServer;

    # Tailscale
    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = lib.mkIf isServer config.age.secrets.tailscale-auth-key.path;
    };
    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];
    networking.firewall = {
      trustedInterfaces = ["tailscale0"];
    };

    # OpenSSH
    services.openssh = lib.mkIf isServer {
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
