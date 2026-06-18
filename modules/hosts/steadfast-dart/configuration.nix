{self, ...}: {
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.coreFeatures
      self.nixosModules.minimalPrograms
      self.nixosModules.commander
    ];

    networking.hostName = "steadfast-dart";
    system.stateVersion = "25.11";
  };
}
