{self, ...}: {
  flake.nixosModules.sharedModules = {
    imports = [
      self.nixosModules.boot
      self.nixosModules.localisation
      self.nixosModules.nix
    ];

    config = {
      zramSwap.enable = true;
    };
  };
}
