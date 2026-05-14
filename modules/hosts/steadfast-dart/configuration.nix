{ self, ... }:
{
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.allFeatures
      self.nixosModules.queze
    ];
    host.profile = "home-server";

    networking.hostName = "steadfast-dart";
    system.stateVersion = "25.11";
  };
}
