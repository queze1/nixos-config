{self, ...}: {
  flake.nixosModules.steadfastDartConfiguration = {
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

    networking.hostName = "steadfast-dart";
    system.stateVersion = "25.11";
  };
}
