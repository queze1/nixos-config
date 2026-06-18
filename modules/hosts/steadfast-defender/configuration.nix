{self, ...}: {
  # For ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    imports = [
      self.nixosModules.coreFeatures
      self.nixosModules.minimalPrograms
      self.nixosModules.commander
    ];

    networking.hostName = "steadfast-defender";
    system.stateVersion = "25.11";
  };
}
