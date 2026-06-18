{self, ...}: {
  flake.nixosModules.steadfastDartConfiguration = {
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

    networking.hostName = "steadfast-dart";
    system.stateVersion = "25.11";
  };
}
