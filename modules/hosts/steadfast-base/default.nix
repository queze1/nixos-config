{
  inputs,
  self,
  ...
}: let
  sshKeys = import "${inputs.secrets}/ssh-keys.nix";
in {
  # Base configuration for home servers
  flake.nixosModules.steadfastBase = {config, ...}: {
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

    # Allow Colmena to SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    # Automatically auth into Tailscale as a server
    age.secrets.tailscale-auth-key.file = "${inputs.secrets}/tailscale-auth-key.age";
    services.tailscale = {
      authKeyFile = config.age.secrets.tailscale-auth-key.path;
    };

    system.stateVersion = "25.11";
  };
}
