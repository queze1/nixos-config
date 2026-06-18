{self, ...}: {
  # For ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    imports = [
      self.nixosModules.coreFeatures
      self.nixosModules.minimalPrograms
      self.nixosModules.commander
    ];

    hardware.facter.reportPath = ./facter.json;

    host = {
      profiles.server.enable = true;
      disko.profile = "hybrid-tmpfs-on-root";
      preservation.enable = true;
    };

    networking.hostName = "steadfast-defender";
    system.stateVersion = "25.11";
  };
}
