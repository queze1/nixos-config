{ self, ... }:
{
  flake.nixosModules.allFeatures = {
    imports = with self.nixosModules; [
      hostOptions

      # /core
      boot
      localisation
      networking
      nix
      swap

      # /lib
      agenix
      disko
    ];
  };
}
