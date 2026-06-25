{self, ...}: {
  flake.nixosModules.syncthing = {
    my.preservation.extraUserDirectories = [
      ".local/state/syncthing"
    ];
    home-manager.sharedModules = [self.homeModules.syncthing];
  };

  flake.homeModules.syncthing = {
    services.syncthing.enable = true;
  };
}
