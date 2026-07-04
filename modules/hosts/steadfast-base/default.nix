{self, ...}: {
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
    services.tailscale = {
      authKeyFile = config.age.secrets.tailscale-auth-key.path;
    };

    system.stateVersion = "25.11";
  };
}
