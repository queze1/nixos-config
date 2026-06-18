{self, ...}: {
  # For home server with medium speed
  flake.nixosModules.steadfastNoonConfiguration = {
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

    networking.hostName = "steadfast-noon";
    system.stateVersion = "25.11";
  };
}
