{ self, ... }:
{
  flake.nixosModules.minimalSystem = {
    imports = [
      self.nixosModules.agenix
      self.nixosModules.disko
    ];
  };
}
