{ self, ... }:
{
  flake.nixosModules.standardSystem = {
    imports = [ self.nixosModules.minimalSystem ];
  };
}
