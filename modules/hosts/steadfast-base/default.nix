{self, ...}: {
  # Base configuration for home servers
  flake.nixosModules.steadfastBase = {
    imports = [
      self.nixosModules.coreFeatures
      self.nixosModules.minimalPrograms
      self.nixosModules.commander
    ];

    host = {
      profiles.server.enable = true;
      disko.profile = "hybrid-tmpfs-on-root";
      preservation.enable = true;
    };

    system.stateVersion = "25.11";
  };
}
