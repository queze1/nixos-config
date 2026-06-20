{self, ...}: {
  flake.nixosModules.personalBase = {
    imports = [
      self.nixosModules.caches
      self.nixosModules.docker
      self.nixosModules.fonts
      self.nixosModules.homeManager
      self.nixosModules.networking
      self.nixosModules.printing
      self.nixosModules.shellAliases
      self.nixosModules.sound
    ];
  };
}
