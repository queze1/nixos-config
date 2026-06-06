{self, ...}: {
  flake.nixosModules.minimalSystem = {
    imports = [
      # Libraries
      self.nixosModules.agenix
      self.nixosModules.disko
      self.nixosModules.preservation

      # Features
      self.nixosModules.boot
      self.nixosModules.localisation
      self.nixosModules.networking
      self.nixosModules.nix
      self.nixosModules.shellAliases
    ];

    # Compress RAM to save memory
    zramSwap.enable = true;

    # Set Vim as default editor
    environment.variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
