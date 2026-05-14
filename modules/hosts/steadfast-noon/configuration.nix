{ self, ... }:
{
  # For home server with medium speed
  flake.nixosModules.steadfastNoonConfiguration = {
    imports = [
      self.nixosModules.allFeatures
      self.nixosModules.queze
    ];

    networking.hostName = "steadfast-noon";
    system.stateVersion = "25.11";
  };
}
