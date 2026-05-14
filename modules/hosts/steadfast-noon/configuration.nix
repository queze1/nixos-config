{ self, ... }:
{
  # For home server with medium speed
  flake.nixosModules.steadfastNoonConfiguration = {
    imports = [
      self.nixosModules.minimalSystem
      self.nixosModules.quezeUser
    ];

    networking.hostName = "steadfast-noon";
    system.stateVersion = "25.11";
  };
}
