{ self, ... }:
{
  # For ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    imports = [
      self.nixosModules.allFeatures
      self.nixosModules.queze
    ];
    host.profile = "home-server";

    networking.hostName = "steadfast-defender";
    system.stateVersion = "25.11";
  };
}
