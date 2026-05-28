{ self, ... }:
{
  flake.nixosModules.minimalSystem = {
    imports = [
      self.nixosModules.homeManager

      # Libraries
      self.nixosModules.agenix
      self.nixosModules.disko
      self.nixosModules.preservation

      # Features
      self.nixosModules.boot
      self.nixosModules.hypervisor
      self.nixosModules.localisation
      self.nixosModules.networking
      self.nixosModules.nix
    ];

    home-manager.sharedModules = [
      self.homeModules.shellAliases
    ];

    # Compress RAM to save memory
    zramSwap.enable = true;
  };
}
