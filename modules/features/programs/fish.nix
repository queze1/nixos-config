{ self, ... }:
{
  flake.nixosModules.fish = {
    programs.fish.enable = true;
    home-manager.sharedModules = [
      self.homeModules.fish
    ];
  };

  flake.homeModules.fish = {
    programs.fish.enable = true;
  };
}
