{
  flake.nixosModules.networking = {
    config,
    lib,
    ...
  }: let
    isServer = config.host.profiles.server.enable;
  in {
    networking.networkmanager.enable = ! isServer;
    networking.nftables.enable = true;

    # Don't wait for network to come online on desktops
    systemd.network.wait-online.enable = ! isServer;
    boot.initrd.systemd.network.wait-online.enable = ! isServer;

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

    # Server wifi
    networking.wireless = {
      enable = isServer;
      # TODO: Use agenix secret
      secretsFile = "/var/lib/secrets/wireless.env";

      networks = {
        "wlan-5G" = {
          authDefs = "ext:wlan-5G";
        };
      };
    };
  };
}
