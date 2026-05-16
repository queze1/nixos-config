{ self, ... }:
{
  flake.nixosModules.standardSystem = {
    imports = [ self.nixosModules.minimalSystem ];
  };

  # Run unpackaged binaries
  programs.nix-ld.enable = true;
  environment.localBinInPath = true;
}
