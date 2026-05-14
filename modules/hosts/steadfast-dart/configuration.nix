{ self, ... }:
{
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.minimalSystem
      self.nixosModules.queze
    ];
    host.profile = "home-server";

    networking.hostName = "steadfast-dart";
    system.stateVersion = "25.11";
  };
}
