{self, ...}: {
  # Base configuration for home servers
  flake.nixosModules.steadfastBase = {
    imports = [
      self.nixosModules.myOptions
      self.nixosModules.sharedModules

      (self.factory.diskoTmpfsOnRoot
        {device = "/dev/nvme0n1";})

      self.nixosModules.serverNetworking
      self.nixosModules.commander
    ];

    system.stateVersion = "25.11";
  };
}
