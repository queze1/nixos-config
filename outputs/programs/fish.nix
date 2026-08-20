{self, ...}: {
  flake.nixosModules.fish = {
    programs.fish.enable = true;
    home-manager.sharedModules = [
      self.homeModules.fish
    ];
  };

  flake.homeModules.fish = {
    # Preserve fish command history
    my.home.preservation.extraDirectories = [
      ".local/share/fish"
    ];

    programs.fish = {
      enable = true;
    };
  };
}
