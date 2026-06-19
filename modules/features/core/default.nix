{self, ...}: {
  flake.nixosModules.coreFeatures = {lib, ...}: {
    options.host.profiles.server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to configure this machine as a headless server.";
      };
    };

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
    ];

    config = {
      # Compress RAM to save memory
      zramSwap.enable = true;
    };
  };
}
