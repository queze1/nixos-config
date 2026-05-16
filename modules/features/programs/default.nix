{ self, ... }:
{
  flake.nixosModules.allPrograms = {
    # Extend minimalPrograms
    imports = [ self.nixosModules.minimalPrograms ];

    home-manager.sharedModules = [ self.homeModules.allPrograms ];
  };

  flake.homeModules.allPrograms = {
    imports = [
      self.homeModules.firefox
      self.homeModules.vesktop
      self.homeModules.qutebrowser
    ];
  };

  flake.nixosModules.minimalPrograms = {
    imports = [ self.nixosModules.fish ];

    home-manager.sharedModules = [ self.homeModules.minimalPrograms ];
  };

  flake.homeModules.minimalPrograms = [
    self.homeModules.git
    self.homeModules.nvf
  ];
}
