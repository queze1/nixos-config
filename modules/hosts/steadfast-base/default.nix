{self, ...}: {
  # Base configuration for home servers
  flake.nixosModules.steadfastBase = {
    imports = [
      self.nixosModules.sharedModules
      self.nixosModules.serverNetworking
      self.nixosModules.commander
    ];

    host = {
      disko.profile = "hybrid-tmpfs-on-root";
      preservation.enable = true;
    };

    system.stateVersion = "25.11";
  };
}
