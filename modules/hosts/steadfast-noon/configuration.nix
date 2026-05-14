{ self, ... }:
{
  # For home server with medium speed
  flake.nixosModules.steadfastNoonConfiguration = {
    imports = [
      self.nixosModules.minimalSystem
      self.nixosModules.queze
    ];
    host.profile = "home-server";

    networking.hostName = "steadfast-noon";
    system.stateVersion = "25.11";
  };
}
