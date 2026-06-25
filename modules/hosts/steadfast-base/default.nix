{self, ...}: {
  # Base configuration for home servers
  flake.nixosModules.steadfastBase = {
    imports = [
      self.nixosModules.myOptions

      # Basic libraries
      self.nixosModules.agenix
      self.nixosModules.preservation
      (self.factory.diskoTmpfsOnRoot
        {device = "/dev/vda";})

      self.nixosModules.sharedModules
      self.nixosModules.serverNetworking
      self.nixosModules.commander
    ];

    system.stateVersion = "25.11";
  };
}
