{ self, ... }:
{
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.allFeatures
      self.nixosModules.queze
    ];

    networking.hostName = "steadfast-dart";
    system.stateVersion = "25.11";
  };
}
