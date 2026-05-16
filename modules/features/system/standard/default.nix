{ self, ... }:
{
  flake.nixosModules.standardSystem = {
    imports = [
      self.nixosModules.minimalSystem

      self.nixosModules.docker
      self.nixosModules.fonts
      self.nixosModules.printing
      self.nixosModules.sound
      self.nixosModules.virtualisation
    ];

    # Run unpackaged binaries
    programs.nix-ld.enable = true;
    environment.localBinInPath = true;
  };
}
