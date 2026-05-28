{ self, ... }:
{
  flake.nixosModules.standardSystem = {
    imports = [
      self.nixosModules.minimalSystem

      self.nixosModules.docker
      self.nixosModules.fonts
      self.nixosModules.printing
      self.nixosModules.sound
    ];

    # Run unpackaged binaries
    programs.nix-ld.enable = true;
    environment.localBinInPath = true;
  };
}
