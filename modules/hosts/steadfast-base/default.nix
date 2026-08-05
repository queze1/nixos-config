{self, ...}: let
  sshKeys = import "${self}/ssh-keys.nix";
in {
  # Base configuration for servers
  flake.nixosModules.steadfastBase = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixModules.myOptions
      self.nixosModules.sharedModules

      # Basic libraries
      self.nixosModules.preservation
      self.nixosModules.sopsNix

      # System config
      self.nixosModules.networkmanager

      # Nix-related
      self.nixosModules.setupAccessTokens

      # Services
      self.nixosModules.comin
      self.nixosModules.openssh
      self.nixosModules.resticDefaults
      self.nixosModules.tailscale

      self.nixosModules.commander
    ];

    # Convenience programs
    environment.systemPackages = [
      pkgs.btop
      pkgs.tree
    ];

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    # Automatically auth into Tailscale as a server
    sops.secrets.tailscale-auth-key = {};
    services.tailscale = {
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    };

    # Only allow SSH via Tailscale
    services.openssh.openFirewall = false;
    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = config.services.openssh.ports;

    system.stateVersion = "25.11";
  };
}
