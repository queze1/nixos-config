{ self, ... }:
{
  flake.nixosModules.allFeatures = {
    imports = with self.nixosModules; [
      hostOptions

      # /system
      boot
      localisation
      networking
      nix
      swap
      virtualisation

      # /lib
      agenix
      disko
    ];
  };

  flake.homeModules.allFeatures = {
    imports = with self.homeModules; [ xdgUserDirs ];
  };
}
