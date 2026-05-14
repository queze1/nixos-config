{ self, ... }:
{
  # For ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    imports = [
      self.nixosModules.minimalSystem
      self.nixosModules.quezeUser
    ];

    networking.hostName = "steadfast-defender";
    system.stateVersion = "25.11";
  };
}
