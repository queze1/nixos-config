{ self, ... }:
{
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.minimalSystem
      self.nixosModules.quezeUser
    ];

    networking.hostName = "steadfast-dart";
    system.stateVersion = "25.11";
  };
}
