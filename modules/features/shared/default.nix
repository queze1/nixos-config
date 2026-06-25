{self, ...}: {
  flake.nixosModules.sharedModules = {
    imports = [
      self.nixosModules.boot
      self.nixosModules.localisation
      self.nixosModules.nix
    ];

    config = {
      networking.nftables.enable = true;
      zramSwap.enable = true;
    };
  };
}
