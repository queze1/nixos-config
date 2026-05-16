{ self, ... }:
{
  flake.nixosModules.allPrograms = {
    # Extend minimalPrograms
    imports = [ self.nixosModules.minimalPrograms ];

    home-manager.sharedModules = [ self.homeModules.allPrograms ];
  };

  flake.homeModules.allPrograms = {
    imports = [ self.homeModules.vesktop ];
  };

  flake.nixosModules.minimalPrograms = {
    imports = [ self.nixosModules.fish ];

    home-manager.sharedModules = [ self.homeModules.minimalPrograms ];
  };

  flake.homeModules.minimalPrograms = { };
}
