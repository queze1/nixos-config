{ self, ... }:
{
  flake.nixosModules.allPrograms = { };

  flake.homeModules.allPrograms = {
    imports = [ self.homeModules.vesktop ];
  };
}
