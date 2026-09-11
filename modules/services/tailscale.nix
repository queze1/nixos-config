{
  config,
  lib,
  ...
}: let
  cfg = config.my.tailscale;
in {
  imports = [
    (lib.mkAliasOptionModule
      ["my" "tailscale" "extraUpFlags"]
      ["services" "tailscale" "extraUpFlags"])
  ];

  options.my.tailscale = {
    enable = lib.mkEnableOption "Tailscale";
    useAuthKey = lib.mkEnableOption "using an auth key";
    setHostname = lib.mkEnableOption "explicitly setting the Tailscale hostname to the hostname defined in Nix";
    ssh = lib.mkEnableOption "using Tailscale SSH";
    openSSHOnlyOnTailscale = lib.mkEnableOption "opening OpenSSH ports only on the Tailscale interface";
    exitNode = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        The IP address of the exit node to use. When null, no exit node is used.
      '';
    };
    advertiseExitNode = lib.mkEnableOption "advertising this device as an exit node";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.ssh || !cfg.openSSHOnlyOnTailscale;
        message = "my.tailscale.openSSHOnlyOnTailscale is redundant with Tailscale SSH";
      }
    ];

    services.tailscale = {
      enable = true;
      authKeyFile = lib.mkIf cfg.useAuthKey config.sops.secrets.tailscale-auth-key.path;
      useRoutingFeatures =
        if cfg.exitNode && cfg.advertiseExitNode
        then "both"
        else if cfg.exitNode
        then "client"
        else if cfg.advertiseExitNode
        then "server"
        else "none";
      extraUpFlags =
        []
        ++ lib.optional cfg.setHostname "--hostname=${config.networking.hostName}"
        ++ lib.optional cfg.ssh "--ssh"
        ++ lib.optional cfg.exitNode "--exit-node=${cfg.exitNode}"
        ++ lib.optional cfg.advertiseExitNode "--advertise-exit-node";
    };

    sops.secrets = lib.mkIf cfg.useAuthKey {
      tailscale-auth-key = {};
    };

    services.openssh.openFirewall = lib.mkIf cfg.openSSHOnlyOnTailscale false;
    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = lib.mkIf cfg.openSSHOnlyOnTailscale config.services.openssh.ports;

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
