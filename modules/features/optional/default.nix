{self, ...}: {
  flake.nixosModules.optionalFeatures = {
    imports = [
      # Home Manager
      self.nixosModules.homeManager

      # Features
      self.nixosModules.caches
      self.nixosModules.docker
      self.nixosModules.fonts
      self.nixosModules.hypervisor
      self.nixosModules.printing
      self.nixosModules.shellAliases
      self.nixosModules.sound
    ];
  };
}
