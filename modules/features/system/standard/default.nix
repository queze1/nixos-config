{self, ...}: {
  flake.nixosModules.standardSystem = {
    imports = [
      self.nixosModules.minimalSystem

      # Home Manager
      self.nixosModules.homeManager

      # Features
      self.nixosModules.docker
      self.nixosModules.fonts
      self.nixosModules.hypervisor
      self.nixosModules.printing
      self.nixosModules.sound
    ];
  };
}
