{
  inputs,
  self,
  ...
}: let
  sshKeys = import "${inputs.secrets}/ssh-keys.nix";
in {
  # Base configuration for home servers
  flake.nixosModules.steadfastBase = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.myOptions
      self.nixosModules.sharedModules
      self.nixosModules.networkmanager

      # Basic libraries
      self.nixosModules.agenix
      self.nixosModules.preservation
      (self.factory.diskoTmpfsOnRoot
        {device = "/dev/nvme0n1";})

      # Services
      self.nixosModules.openssh
      self.nixosModules.tailscale

      self.nixosModules.commander
    ];

    # Convenience programs
    environment.systemPackages = [
      pkgs.htop
      pkgs.tree
    ];

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    # Automatically auth into Tailscale as a server
    age.secrets.tailscale-auth-key.file = "${inputs.secrets}/tailscale-auth-key.age";
    services.tailscale = {
      authKeyFile = config.age.secrets.tailscale-auth-key.path;
    };

    # Only allow SSH via Tailscale
    services.openssh.openFirewall = false;
    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = config.services.openssh.ports;

    # Don't sleep on lid close
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };

    # Preserve battery health
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    system.stateVersion = "25.11";
  };
}
