{self, ...}: {
  flake.nixosModules.personalCore = {
    imports = [
      self.nixosModules.homeManager
      self.nixosModules.networking
    ];
  };

  # -- Override shared modules here --
}
