{self, ...}: {
  # For ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    imports = [
      self.nixosModules.coreFeatures
      self.nixosModules.minimalPrograms
      self.nixosModules.commander
    ];

    host = {
      profile.server = true;
      disko.profile = "hybrid-tmpfs-on-root";
      preservation.enable = true;
    };

    networking.hostName = "steadfast-defender";
    system.stateVersion = "25.11";
  };
}
