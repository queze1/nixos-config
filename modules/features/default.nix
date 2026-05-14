{ self, ... }:
{
  flake.nixosModules.allFeatures = {
    imports = with self.nixosModules; [
      hostOptions

      # /core
      agenix
      boot
      localisation
      networking
      nix
      swap
    ];
  };
}
