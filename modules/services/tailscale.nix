{
  config,
  lib,
  ...
}: let
  cfg = config.my.tailscale;
in {
  options.my.tailscale = {
    enable = lib.mkEnableOption "Tailscale";
    autoAuth = lib.mkEnableOption "automatic authentication using a Tailscale auth key";
    setHostname = lib.mkEnableOption "explicitly setting the Tailscale hostname to the hostname defined in Nix";
    openSSHOnTailscale = lib.mkEnableOption "opening OpenSSH ports on the Tailscale interface";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      authKeyFile = lib.mkIf cfg.autoAuth config.sops.secrets.tailscale-auth-key.path;
      extraUpFlags = lib.mkIf cfg.setHostname ["--hostname=${config.networking.hostName}"];
    };

    sops.secrets = lib.mkIf cfg.autoAuth {
      tailscale-auth-key = {};
    };

    services.openssh.openFirewall = lib.mkIf cfg.openSSHOnTailscale false;
    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = lib.mkIf cfg.openSSHOnTailscale config.services.openssh.ports;

    # Preserve Tailscale data
    my.preservation.extraDirectories = [
      {
        directory = "/var/lib/tailscale";
        mode = "0700";
      }
    ];

    # Ensure Tailscale waits for preservation
    systemd.services.tailscaled = {
      after = ["preservation.target"];
      wants = ["preservation.target"];
    };
  };
}
