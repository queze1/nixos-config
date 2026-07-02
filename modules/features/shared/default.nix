{self, ...}: {
  flake.nixosModules.sharedModules = {
    imports = [
      self.nixosModules.boot
      self.nixosModules.localisation
      self.nixosModules.nix
    ];

    config = {
      networking.nftables.enable = true;

      # Set Vim as default editor
      environment.variables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };

      zramSwap.enable = true;
    };
  };
}
