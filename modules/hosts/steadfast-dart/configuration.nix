{ self, ... }:
{
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.minimalSystem
      self.nixosModules.queze
    ];

    networking.hostName = "steadfast-dart";
    system.stateVersion = "25.11";
  };
}
