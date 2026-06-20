{self, ...}: {
  flake.nixosModules.sharedModules = {
    imports = [
      self.nixosModules.agenix
      self.nixosModules.disko
      self.nixosModules.preservation

      self.nixosModules.boot
      self.nixosModules.hypervisor
      self.nixosModules.localisation
      self.nixosModules.nix
    ];

    config = {
      zramSwap.enable = true;
    };
  };
}
