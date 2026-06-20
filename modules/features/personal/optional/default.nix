{self, ...}: {
  flake.nixosModules.personalOptional = {
    imports = [
      self.nixosModules.caches
      self.nixosModules.docker
      self.nixosModules.fonts
      self.nixosModules.printing
      self.nixosModules.shellAliases
      self.nixosModules.sound
    ];
  };
}
