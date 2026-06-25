{
  flake.nixosModules.syncthing = {config, ...}: {
    services.syncthing.enable = true;

    my.preservation.extraDirectories = [
      config.services.syncthing.dataDir
      config.services.syncthing.configDir
    ];
  };
}
